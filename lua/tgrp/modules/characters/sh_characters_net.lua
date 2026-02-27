--[[
    Tokyo Ghoul RP — Module Personnages : Networking
    Messages réseau pour la création, sélection, suppression, et sync des persos.
]]

-- ============================================================
-- ENREGISTREMENT DES MESSAGES RÉSEAU
-- ============================================================

TGRP.Net.Enregistrer("perso_liste", 2048)       -- Serveur → Client : liste des persos du joueur
TGRP.Net.Enregistrer("perso_creer", 512)         -- Client → Serveur : demande de création
TGRP.Net.Enregistrer("perso_selectionner", 32)   -- Client → Serveur : sélection d'un perso
TGRP.Net.Enregistrer("perso_supprimer", 32)      -- Client → Serveur : suppression d'un perso
TGRP.Net.Enregistrer("perso_ouvrir_menu", 8)     -- Serveur → Client : ouvrir le menu de sélection

-- ============================================================
-- SERVEUR : Handlers des requêtes client
-- ============================================================

if SERVER then

    --- Envoie la liste des personnages au client
    --- @param ply Player Le joueur
    function TGRP.Persos.EnvoyerListe(ply)
        if not IsValid(ply) then return end

        local steamid = ply:SteamID()
        local persos = TGRP.Persos.Cache[steamid] or {}

        -- Construire la liste simplifiée pour le client
        local liste = {}
        for slot, perso in pairs(persos) do
            liste[slot] = {
                Slot = perso.Slot,
                Nom = perso.Nom,
                Faction = perso.Faction,
                Model = perso.Model,
                RC = perso.RC,
                HP = perso.HP,
                Faim = perso.Faim,
                RangCCG = perso.RangCCG,
                KaguneType = perso.KaguneType,
                QuinqueType = perso.QuinqueType,
            }
        end

        net.Start(TGRP.Net.Nom("perso_liste"))
        TGRP.Net.WriteTableCompresse(liste)
        net.Send(ply)
    end

    --- Demande au client d'ouvrir le menu de sélection de personnage
    --- @param ply Player Le joueur
    function TGRP.Persos.OuvrirMenu(ply)
        if not IsValid(ply) then return end

        -- Envoyer la liste puis ouvrir le menu
        TGRP.Persos.EnvoyerListe(ply)

        net.Start(TGRP.Net.Nom("perso_ouvrir_menu"))
        net.Send(ply)
    end

    -- Réception : demande de création
    net.Receive(TGRP.Net.Nom("perso_creer"), function(len, ply)
        if not IsValid(ply) then return end

        -- Rate limiting
        if not TGRP.Net.PeutEnvoyer(ply, "perso_creer", 2) then
            TGRP.Net.Notification(ply, "Veuillez patienter avant de créer un personnage.", "avertissement")
            return
        end

        local nom = net.ReadString()
        local faction = net.ReadString()
        local model = net.ReadString()

        TGRP.Persos.Creer(ply, nom, faction, model, function(perso)
            if perso then
                -- Sélectionner automatiquement le nouveau perso
                TGRP.Persos.Selectionner(ply, perso.Slot)
            end
        end)
    end)

    -- Réception : sélection de personnage
    net.Receive(TGRP.Net.Nom("perso_selectionner"), function(len, ply)
        if not IsValid(ply) then return end

        if not TGRP.Net.PeutEnvoyer(ply, "perso_selectionner", 1) then return end

        local slot = net.ReadUInt(4) -- Max 15 slots (largement suffisant)

        TGRP.Persos.Selectionner(ply, slot)
    end)

    -- Réception : suppression de personnage
    net.Receive(TGRP.Net.Nom("perso_supprimer"), function(len, ply)
        if not IsValid(ply) then return end

        if not TGRP.Net.PeutEnvoyer(ply, "perso_supprimer", 3) then
            TGRP.Net.Notification(ply, "Veuillez patienter.", "avertissement")
            return
        end

        local slot = net.ReadUInt(4)

        TGRP.Persos.Supprimer(ply, slot, function(succes)
            if succes then
                TGRP.Persos.EnvoyerListe(ply)
            end
        end)
    end)

end

-- ============================================================
-- CLIENT : Réception des données
-- ============================================================

if CLIENT then

    -- Cache client des personnages
    TGRP.Persos = TGRP.Persos or {}
    TGRP.Persos.MesPersos = {}

    -- Réception de la liste des personnages
    net.Receive(TGRP.Net.Nom("perso_liste"), function()
        TGRP.Persos.MesPersos = TGRP.Net.ReadTableCompresse()
        TGRP.LogDebug("Personnages", "Liste des personnages reçue : " .. table.Count(TGRP.Persos.MesPersos) .. " perso(s)")

        -- Hook pour mettre à jour l'UI si ouverte
        hook.Run("TGRP_PersosReçus", TGRP.Persos.MesPersos)
    end)

    -- Réception : ouvrir le menu
    net.Receive(TGRP.Net.Nom("perso_ouvrir_menu"), function()
        TGRP.LogDebug("Personnages", "Ouverture du menu de personnages")
        hook.Run("TGRP_OuvrirMenuPersos")
    end)

    --- Envoie une demande de création de personnage au serveur
    --- @param nom string Le nom du personnage
    --- @param faction string L'ID de la faction
    --- @param model string Le model choisi
    function TGRP.Persos.DemanderCreation(nom, faction, model)
        net.Start(TGRP.Net.Nom("perso_creer"))
        net.WriteString(nom)
        net.WriteString(faction)
        net.WriteString(model)
        net.SendToServer()
    end

    --- Envoie une demande de sélection de personnage au serveur
    --- @param slot number Le slot du personnage
    function TGRP.Persos.DemanderSelection(slot)
        net.Start(TGRP.Net.Nom("perso_selectionner"))
        net.WriteUInt(slot, 4)
        net.SendToServer()
    end

    --- Envoie une demande de suppression de personnage au serveur
    --- @param slot number Le slot du personnage
    function TGRP.Persos.DemanderSuppression(slot)
        net.Start(TGRP.Net.Nom("perso_supprimer"))
        net.WriteUInt(slot, 4)
        net.SendToServer()
    end

end
