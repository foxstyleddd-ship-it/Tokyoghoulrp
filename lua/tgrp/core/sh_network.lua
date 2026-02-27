--[[
    Tokyo Ghoul RP — Core : Framework Networking
    Optimisé pour 120 joueurs : compression, batching, PVS, rate limiting.

    CONVENTION DE NOMS :
    Tous les messages réseau commencent par "tgrp_" suivi du module.
    Exemple : "tgrp_rc_update", "tgrp_combat_hit", "tgrp_inv_sync"
]]

TGRP.Net = TGRP.Net or {}

-- ============================================================
-- ENREGISTREMENT DES MESSAGES RÉSEAU
-- ============================================================

-- Table de tous les messages réseau enregistrés
TGRP.Net.Messages = {}

--- Enregistre un message réseau
--- @param nom string Nom du message (sera préfixé par "tgrp_")
--- @param taille number Taille estimée en bits (pour le pool de strings)
function TGRP.Net.Enregistrer(nom, taille)
    local nomComplet = "tgrp_" .. nom
    if SERVER then
        util.AddNetworkString(nomComplet)
    end
    TGRP.Net.Messages[nom] = {
        NomComplet = nomComplet,
        Taille = taille or 0,
    }
    TGRP.LogDebug("Network", "Message enregistré : " .. nomComplet)
end

--- Retourne le nom complet d'un message réseau
--- @param nom string Nom court du message
--- @return string Le nom complet ("tgrp_xxx")
function TGRP.Net.Nom(nom)
    local msg = TGRP.Net.Messages[nom]
    if msg then return msg.NomComplet end
    return "tgrp_" .. nom
end

-- ============================================================
-- SÉRIALISATION OPTIMISÉE (pas de net.WriteTable)
-- ============================================================

--- Écrit un entier avec le minimum de bits nécessaires
--- @param valeur number La valeur à écrire
--- @param bits number Nombre de bits (par défaut auto-calculé)
function TGRP.Net.WriteInt(valeur, bits)
    bits = bits or TGRP.Net.BitsNecessaires(valeur)
    net.WriteUInt(valeur, bits)
end

--- Calcule le nombre de bits nécessaires pour un nombre
--- @param max number La valeur maximum possible
--- @return number Le nombre de bits nécessaires
function TGRP.Net.BitsNecessaires(max)
    if max <= 0 then return 1 end
    return math.max(1, math.ceil(math.log(max + 1, 2)))
end

--- Écrit une chaîne compressée (longueur + contenu)
--- @param str string La chaîne à écrire
function TGRP.Net.WriteString(str)
    local len = #str
    net.WriteUInt(len, 16)
    net.WriteData(str, len)
end

--- Lit une chaîne compressée
--- @return string La chaîne lue
function TGRP.Net.ReadString()
    local len = net.ReadUInt(16)
    return net.ReadData(len)
end

--- Écrit une table sérialisée en JSON compressé
--- Utiliser UNIQUEMENT quand la structure est dynamique et variable
--- @param tbl table La table à écrire
function TGRP.Net.WriteTableCompresse(tbl)
    local json = util.TableToJSON(tbl)
    local compresse = util.Compress(json)
    local taille = #compresse
    net.WriteUInt(taille, 16)
    net.WriteData(compresse, taille)
end

--- Lit une table sérialisée en JSON compressé
--- @return table La table lue
function TGRP.Net.ReadTableCompresse()
    local taille = net.ReadUInt(16)
    local compresse = net.ReadData(taille)
    local json = util.Decompress(compresse)
    if not json then return {} end
    return util.JSONToTable(json) or {}
end

-- ============================================================
-- RATE LIMITING (serveur uniquement)
-- ============================================================

if SERVER then

    -- Stockage des timestamps par joueur et par message
    TGRP.Net.RateLimits = {}

    --- Vérifie si un joueur peut envoyer un message (rate limiting)
    --- @param ply Player Le joueur
    --- @param nomMessage string Le nom du message
    --- @param intervalle number Intervalle minimum en secondes entre deux messages
    --- @return boolean true si le message est autorisé
    function TGRP.Net.PeutEnvoyer(ply, nomMessage, intervalle)
        intervalle = intervalle or 0.1

        local steamid = ply:SteamID()
        local cle = steamid .. "_" .. nomMessage

        local maintenant = CurTime()
        local dernierEnvoi = TGRP.Net.RateLimits[cle] or 0

        if maintenant - dernierEnvoi < intervalle then
            return false
        end

        TGRP.Net.RateLimits[cle] = maintenant
        return true
    end

    -- Nettoyage périodique du rate limiter (éviter les fuites mémoire)
    timer.Create("TGRP_NettoyerRateLimits", 60, 0, function()
        local maintenant = CurTime()
        for cle, temps in pairs(TGRP.Net.RateLimits) do
            if maintenant - temps > 30 then
                TGRP.Net.RateLimits[cle] = nil
            end
        end
    end)

end

-- ============================================================
-- ENVOI OPTIMISÉ (serveur uniquement)
-- ============================================================

if SERVER then

    --- Envoie un message réseau uniquement aux joueurs dans le PVS d'une position
    --- Utile pour le combat, les effets, les interactions locales
    --- @param nomMessage string Nom du message réseau
    --- @param position Vector Position de référence pour le PVS
    --- @param rayon number Rayon maximum (filtrage supplémentaire)
    function TGRP.Net.EnvoyerPVS(nomMessage, position, rayon)
        if rayon then
            -- Filtrer par distance en plus du PVS
            local joueurs = {}
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(position) <= rayon * rayon then
                    table.insert(joueurs, ply)
                end
            end
            net.Send(joueurs)
        else
            net.SendPVS(position)
        end
    end

    --- Envoie un message réseau à tous les joueurs d'une faction
    --- @param faction string L'ID de la faction ("ghoul", "ccg", "civil")
    function TGRP.Net.EnvoyerFaction(faction)
        local joueurs = {}
        for _, ply in ipairs(player.GetAll()) do
            if ply.tgrpFaction == faction then
                table.insert(joueurs, ply)
            end
        end
        if #joueurs > 0 then
            net.Send(joueurs)
        end
    end

end

-- ============================================================
-- BATCHING (regroupement de messages)
-- ============================================================

if SERVER then

    TGRP.Net.Batch = {}
    TGRP.Net.BatchTimer = nil

    --- Ajoute des données au batch pour un joueur
    --- Les données seront envoyées groupées au prochain tick
    --- @param ply Player Le joueur destinataire
    --- @param canal string Nom du canal de batch
    --- @param donnees table Les données à envoyer
    function TGRP.Net.AjouterBatch(ply, canal, donnees)
        local steamid = ply:SteamID()
        TGRP.Net.Batch[steamid] = TGRP.Net.Batch[steamid] or {}
        TGRP.Net.Batch[steamid][canal] = TGRP.Net.Batch[steamid][canal] or {}
        table.insert(TGRP.Net.Batch[steamid][canal], donnees)

        -- Démarrer le timer de flush si pas déjà actif
        if not TGRP.Net.BatchTimer then
            local intervalle = 0.1
            if TGRP.Config and TGRP.Config.Performance then
                intervalle = TGRP.Config.Performance.IntervalNetworking or 0.1
            end

            TGRP.Net.BatchTimer = timer.Simple(intervalle, function()
                TGRP.Net.FlushBatch()
                TGRP.Net.BatchTimer = nil
            end)
        end
    end

    --- Envoie tous les messages en batch
    function TGRP.Net.FlushBatch()
        for steamid, canaux in pairs(TGRP.Net.Batch) do
            -- Trouver le joueur par SteamID
            local ply = nil
            for _, p in ipairs(player.GetAll()) do
                if p:SteamID() == steamid then
                    ply = p
                    break
                end
            end

            if IsValid(ply) then
                for canal, donneesList in pairs(canaux) do
                    local nomMsg = TGRP.Net.Nom("batch_" .. canal)
                    net.Start(nomMsg)
                    TGRP.Net.WriteTableCompresse(donneesList)
                    net.Send(ply)
                end
            end
        end

        TGRP.Net.Batch = {}
    end

end

-- ============================================================
-- MESSAGES RÉSEAU DE BASE
-- ============================================================

-- Enregistrement des messages core (les modules enregistreront les leurs)
TGRP.Net.Enregistrer("notification", 256)
TGRP.Net.Enregistrer("erreur", 256)

if SERVER then
    --- Envoie une notification à un joueur
    --- @param ply Player Le joueur
    --- @param message string Le message
    --- @param type string Type de notification ("info", "succes", "erreur", "avertissement")
    --- @param duree number Durée d'affichage en secondes
    function TGRP.Net.Notification(ply, message, typeNotif, duree)
        net.Start(TGRP.Net.Nom("notification"))
        net.WriteString(message)
        net.WriteString(typeNotif or "info")
        net.WriteUInt(duree or 5, 8)
        net.Send(ply)
    end
end

if CLIENT then
    net.Receive(TGRP.Net.Nom("notification"), function()
        local message = net.ReadString()
        local typeNotif = net.ReadString()
        local duree = net.ReadUInt(8)

        -- Affichage basique pour l'instant (sera remplacé par PixelUI dans le Sprint 7)
        chat.AddText(
            Color(255, 200, 50), "[TGRP] ",
            Color(255, 255, 255), message
        )
    end)
end
