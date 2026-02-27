--[[
    Tokyo Ghoul RP — Module Personnages (Serveur)
    CRUD base de données, chargement, sauvegarde, création, suppression.
]]

TGRP.Persos = TGRP.Persos or {}

-- Cache des personnages chargés en mémoire par SteamID
-- Structure : TGRP.Persos.Cache[steamid] = { [slot] = données, ... }
TGRP.Persos.Cache = {}

-- ============================================================
-- CHARGEMENT DEPUIS LA DB
-- ============================================================

--- Charge tous les personnages d'un joueur depuis la DB
--- @param ply Player Le joueur
--- @param callback function Appelée avec la table des personnages
function TGRP.Persos.Charger(ply, callback)
    if not IsValid(ply) then return end

    local steamid = ply:SteamID()

    TGRP.DB.Preparer(
        "SELECT * FROM tgrp_personnages WHERE steamid = ? ORDER BY slot ASC",
        { steamid },
        function(donnees)
            TGRP.Persos.Cache[steamid] = {}

            if donnees then
                for _, row in ipairs(donnees) do
                    local perso = TGRP.Persos.RowVersPerso(row)
                    TGRP.Persos.Cache[steamid][perso.Slot] = perso
                end
            end

            local nbPersos = table.Count(TGRP.Persos.Cache[steamid])
            TGRP.Log("Personnages", ply:Nick() .. " : " .. nbPersos .. " personnage(s) chargé(s)", "info")

            if callback then
                callback(TGRP.Persos.Cache[steamid])
            end
        end,
        function(err)
            TGRP.LogErreur("Personnages", "Impossible de charger les personnages de " .. ply:Nick() .. " : " .. tostring(err))
            if callback then callback({}) end
        end
    )
end

--- Convertit une row SQL en table de personnage exploitable
--- @param row table La row SQL brute
--- @return table Le personnage formaté
function TGRP.Persos.RowVersPerso(row)
    return {
        ID = tonumber(row.id),
        SteamID = row.steamid,
        Slot = tonumber(row.slot),
        Nom = row.nom,
        Faction = row.faction,
        Model = row.model,
        RC = tonumber(row.rc) or 100,
        Faim = tonumber(row.faim) or 80,
        HP = tonumber(row.hp) or 100,
        KaguneType = row.kagune_type,
        QuinqueType = row.quinque_type,
        RangCCG = row.rang_ccg or "academie",
        Inventaire = row.inventaire and util.JSONToTable(row.inventaire) or {},
        Equipement = row.equipement and util.JSONToTable(row.equipement) or {},
        Cosmetique = row.cosmetique and util.JSONToTable(row.cosmetique) or {},
        Hotbar = row.hotbar and util.JSONToTable(row.hotbar) or {},
        SkillsDebloquees = row.skills_debloquees and util.JSONToTable(row.skills_debloquees) or {},
        DateCreation = row.date_creation,
    }
end

-- ============================================================
-- CRÉATION DE PERSONNAGE
-- ============================================================

--- Crée un nouveau personnage pour un joueur
--- @param ply Player Le joueur
--- @param nom string Le nom du personnage
--- @param faction string L'ID de la faction
--- @param model string Le chemin du model
--- @param callback function Appelée avec le personnage créé (ou nil si erreur)
function TGRP.Persos.Creer(ply, nom, faction, model, callback)
    if not IsValid(ply) then return end

    local steamid = ply:SteamID()

    -- Validation
    local erreur = TGRP.Persos.ValiderCreation(ply, nom, faction, model)
    if erreur then
        TGRP.Net.Notification(ply, erreur, "erreur")
        if callback then callback(nil) end
        return
    end

    -- Trouver le prochain slot disponible
    local slot = TGRP.Persos.ProchainSlot(steamid)
    if not slot then
        TGRP.Net.Notification(ply, "Tous les slots de personnages sont utilisés !", "erreur")
        if callback then callback(nil) end
        return
    end

    local hpBase = TGRP.Factions.HP(faction)

    TGRP.DB.Preparer(
        "INSERT INTO tgrp_personnages (steamid, slot, nom, faction, model, hp, inventaire, equipement, cosmetique, hotbar, skills_debloquees) VALUES (?, ?, ?, ?, ?, ?, '[]', '{}', '{}', '[]', '[]')",
        { steamid, slot, nom, faction, model, hpBase },
        function(donnees)
            -- Recharger les persos du joueur
            TGRP.Persos.Charger(ply, function(persos)
                local perso = persos[slot]
                TGRP.Log("Personnages", ply:Nick() .. " a créé : " .. nom .. " (" .. faction .. ") slot " .. slot, "info")
                TGRP.DB.LogAction(steamid, "perso_cree", nom .. " | " .. faction .. " | slot " .. slot)

                if callback then callback(perso) end
            end)
        end,
        function(err)
            TGRP.LogErreur("Personnages", "Erreur création perso pour " .. ply:Nick() .. " : " .. tostring(err))
            TGRP.Net.Notification(ply, "Erreur lors de la création du personnage.", "erreur")
            if callback then callback(nil) end
        end
    )
end

--- Valide les données de création d'un personnage
--- @return string|nil Message d'erreur ou nil si tout est bon
function TGRP.Persos.ValiderCreation(ply, nom, faction, model)
    -- Nom
    if not nom or #nom < 3 then
        return "Le nom doit faire au moins 3 caractères."
    end
    if #nom > 32 then
        return "Le nom ne peut pas dépasser 32 caractères."
    end
    if string.match(nom, "[^%w%s%-']") then
        return "Le nom contient des caractères interdits."
    end

    -- Faction
    if not TGRP.Factions.Existe(faction) then
        return "Faction invalide."
    end

    -- Model
    if not TGRP.Factions.ModelValide(faction, model) then
        return "Model invalide pour cette faction."
    end

    -- Slots
    local steamid = ply:SteamID()
    local slot = TGRP.Persos.ProchainSlot(steamid)
    if not slot then
        return "Vous avez atteint le nombre maximum de personnages."
    end

    return nil
end

--- Trouve le prochain slot disponible pour un joueur
--- @param steamid string Le SteamID du joueur
--- @return number|nil Le numéro de slot disponible
function TGRP.Persos.ProchainSlot(steamid)
    local persos = TGRP.Persos.Cache[steamid] or {}
    local maxSlots = TGRP.Config.General.MaxPersonnages or 3

    for i = 1, maxSlots do
        if not persos[i] then
            return i
        end
    end

    return nil
end

-- ============================================================
-- SAUVEGARDE
-- ============================================================

--- Sauvegarde le personnage actif d'un joueur dans la DB
--- @param ply Player Le joueur
function TGRP.Persos.Sauvegarder(ply)
    if not IsValid(ply) then return end
    if not ply.tgrpPersoActif then return end

    local steamid = ply:SteamID()
    local perso = ply.tgrpPersoActif

    TGRP.DB.Preparer(
        "UPDATE tgrp_personnages SET hp = ?, rc = ?, faim = ?, inventaire = ?, equipement = ?, cosmetique = ?, hotbar = ?, skills_debloquees = ?, rang_ccg = ?, kagune_type = ?, quinque_type = ? WHERE steamid = ? AND slot = ?",
        {
            perso.HP,
            perso.RC,
            perso.Faim,
            util.TableToJSON(perso.Inventaire or {}),
            util.TableToJSON(perso.Equipement or {}),
            util.TableToJSON(perso.Cosmetique or {}),
            util.TableToJSON(perso.Hotbar or {}),
            util.TableToJSON(perso.SkillsDebloquees or {}),
            perso.RangCCG or "academie",
            perso.KaguneType,
            perso.QuinqueType,
            steamid,
            perso.Slot,
        },
        function()
            TGRP.LogDebug("Personnages", "Sauvegarde OK : " .. ply:Nick() .. " slot " .. perso.Slot)
        end,
        function(err)
            TGRP.LogErreur("Personnages", "Erreur sauvegarde " .. ply:Nick() .. " : " .. tostring(err))
        end
    )
end

--- Sauvegarde tous les joueurs connectés (utilisé par le timer auto-save)
function TGRP.Persos.SauvegarderTous()
    for _, ply in ipairs(player.GetAll()) do
        if ply.tgrpPersoActif then
            TGRP.Persos.Sauvegarder(ply)
        end
    end
end

-- ============================================================
-- SUPPRESSION
-- ============================================================

--- Supprime un personnage
--- @param ply Player Le joueur
--- @param slot number Le slot du personnage à supprimer
--- @param callback function Appelée après suppression
function TGRP.Persos.Supprimer(ply, slot, callback)
    if not IsValid(ply) then return end

    local steamid = ply:SteamID()
    local persos = TGRP.Persos.Cache[steamid]
    if not persos or not persos[slot] then
        TGRP.Net.Notification(ply, "Personnage introuvable.", "erreur")
        if callback then callback(false) end
        return
    end

    -- On ne peut pas supprimer le perso actif en jeu
    if ply.tgrpPersoActif and ply.tgrpPersoActif.Slot == slot then
        TGRP.Net.Notification(ply, "Vous ne pouvez pas supprimer votre personnage actif.", "erreur")
        if callback then callback(false) end
        return
    end

    local nomPerso = persos[slot].Nom

    TGRP.DB.Preparer(
        "DELETE FROM tgrp_personnages WHERE steamid = ? AND slot = ?",
        { steamid, slot },
        function()
            TGRP.Persos.Cache[steamid][slot] = nil
            TGRP.Log("Personnages", ply:Nick() .. " a supprimé : " .. nomPerso .. " (slot " .. slot .. ")", "info")
            TGRP.DB.LogAction(steamid, "perso_supprime", nomPerso .. " | slot " .. slot)
            TGRP.Net.Notification(ply, "Personnage supprimé : " .. nomPerso, "info")
            if callback then callback(true) end
        end,
        function(err)
            TGRP.LogErreur("Personnages", "Erreur suppression : " .. tostring(err))
            if callback then callback(false) end
        end
    )
end

-- ============================================================
-- SÉLECTION / ACTIVATION D'UN PERSONNAGE
-- ============================================================

--- Sélectionne et active un personnage pour un joueur
--- @param ply Player Le joueur
--- @param slot number Le slot du personnage
function TGRP.Persos.Selectionner(ply, slot)
    if not IsValid(ply) then return end

    local steamid = ply:SteamID()
    local persos = TGRP.Persos.Cache[steamid]

    if not persos or not persos[slot] then
        TGRP.Net.Notification(ply, "Personnage introuvable dans le slot " .. slot, "erreur")
        return
    end

    -- Sauvegarder l'ancien perso si besoin
    if ply.tgrpPersoActif then
        TGRP.Persos.Sauvegarder(ply)
    end

    local perso = persos[slot]
    ply.tgrpPersoActif = perso

    -- Appliquer la faction
    TGRP.Factions.Appliquer(ply, perso.Faction)

    -- Appliquer le model
    ply:SetModel(perso.Model)

    -- Appliquer les HP
    ply:SetMaxHealth(TGRP.Factions.HP(perso.Faction))
    ply:SetHealth(math.min(perso.HP, TGRP.Factions.HP(perso.Faction)))

    -- NWVars pour le client
    ply:SetNWString("tgrp_nom_perso", perso.Nom)
    ply:SetNWInt("tgrp_slot", perso.Slot)
    ply:SetNWInt("tgrp_rc", perso.RC)
    ply:SetNWFloat("tgrp_faim", perso.Faim)

    -- Spawn au point de la faction
    local pos, ang = TGRP.Factions.SpawnPoint(perso.Faction)
    ply:SetPos(pos)
    ply:SetEyeAngles(ang)
    ply:Spawn()

    -- Marquer le joueur comme ayant un perso actif
    ply:SetNWBool("tgrp_perso_charge", true)

    TGRP.Log("Personnages", ply:Nick() .. " joue : " .. perso.Nom .. " (" .. perso.Faction .. ")", "info")

    -- Hook pour les autres modules
    hook.Run("TGRP_PersonnageSelectionne", ply, perso)
end

-- ============================================================
-- ENREGISTREMENT JOUEUR DB
-- ============================================================

--- Enregistre ou met à jour un joueur dans la table tgrp_joueurs
--- @param ply Player Le joueur
function TGRP.Persos.EnregistrerJoueur(ply)
    if not IsValid(ply) then return end

    TGRP.DB.Preparer(
        "INSERT INTO tgrp_joueurs (steamid, nom_steam) VALUES (?, ?) ON DUPLICATE KEY UPDATE nom_steam = ?, derniere_connexion = NOW()",
        { ply:SteamID(), ply:Nick(), ply:Nick() }
    )
end
