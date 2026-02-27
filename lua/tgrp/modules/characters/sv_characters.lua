--[[
    Tokyo Ghoul RP — Module Personnages (Serveur)
    CRUD base de données, chargement, sauvegarde.
    Les personnages sont liés à ACC2 via acc2_character_id.
    ACC2 gère : nom, model, apparence, slots, UI.
    TGRP gère : faction, RC, faim, HP, kagune/quinque, inventaire, skills.
]]

TGRP.Persos = TGRP.Persos or {}

-- Cache des personnages chargés en mémoire par SteamID
-- Structure : TGRP.Persos.Cache[steamid] = { [acc2_character_id] = données, ... }
TGRP.Persos.Cache = {}

-- ============================================================
-- CONVERSION ROW SQL → TABLE PERSONNAGE
-- ============================================================

--- Convertit une row SQL en table de personnage exploitable
--- @param row table La row SQL brute
--- @return table Le personnage formaté
function TGRP.Persos.RowVersPerso(row)
    return {
        ID = tonumber(row.id),
        SteamID = row.steamid,
        ACC2CharID = tonumber(row.acc2_character_id),
        Faction = row.faction,
        RC = tonumber(row.rc) or 100,
        Faim = tonumber(row.faim) or 80,
        HP = tonumber(row.hp) or 100,
        KaguneType = row.kagune_type,
        QuinqueType = row.quinque_type,
        RangCCG = row.rang_ccg or "academie",
        RerollUtilise = tonumber(row.reroll_utilise) == 1,
        Inventaire = row.inventaire and util.JSONToTable(row.inventaire) or {},
        Equipement = row.equipement and util.JSONToTable(row.equipement) or {},
        Cosmetique = row.cosmetique and util.JSONToTable(row.cosmetique) or {},
        Hotbar = row.hotbar and util.JSONToTable(row.hotbar) or {},
        SkillsDebloquees = row.skills_debloquees and util.JSONToTable(row.skills_debloquees) or {},
        DateCreation = row.date_creation,
    }
end

-- ============================================================
-- CHARGEMENT DEPUIS LA DB
-- ============================================================

--- Charge tous les personnages TGRP d'un joueur depuis la DB
--- @param ply Player Le joueur
--- @param callback function Appelée avec la table des personnages
function TGRP.Persos.Charger(ply, callback)
    if not IsValid(ply) then return end

    local steamid = ply:SteamID()

    TGRP.DB.Preparer(
        "SELECT * FROM tgrp_personnages WHERE steamid = ?",
        { steamid },
        function(donnees)
            TGRP.Persos.Cache[steamid] = {}

            if donnees then
                for _, row in ipairs(donnees) do
                    local perso = TGRP.Persos.RowVersPerso(row)
                    TGRP.Persos.Cache[steamid][perso.ACC2CharID] = perso
                end
            end

            local nbPersos = table.Count(TGRP.Persos.Cache[steamid])
            TGRP.LogDebug("Personnages", ply:Nick() .. " : " .. nbPersos .. " personnage(s) TGRP chargé(s)")

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

-- ============================================================
-- SAUVEGARDE
-- ============================================================

--- Sauvegarde le personnage actif d'un joueur dans la DB
--- @param ply Player Le joueur
function TGRP.Persos.Sauvegarder(ply)
    if not IsValid(ply) then return end
    if not ply.tgrpPersoActif then return end

    local perso = ply.tgrpPersoActif

    TGRP.DB.Preparer(
        "UPDATE tgrp_personnages SET hp = ?, rc = ?, faim = ?, kagune_type = ?, quinque_type = ?, inventaire = ?, equipement = ?, cosmetique = ?, hotbar = ?, skills_debloquees = ?, rang_ccg = ?, reroll_utilise = ? WHERE acc2_character_id = ?",
        {
            perso.HP,
            perso.RC,
            perso.Faim,
            perso.KaguneType,
            perso.QuinqueType,
            util.TableToJSON(perso.Inventaire or {}),
            util.TableToJSON(perso.Equipement or {}),
            util.TableToJSON(perso.Cosmetique or {}),
            util.TableToJSON(perso.Hotbar or {}),
            util.TableToJSON(perso.SkillsDebloquees or {}),
            perso.RangCCG or "academie",
            perso.RerollUtilise and 1 or 0,
            perso.ACC2CharID,
        },
        function()
            TGRP.LogDebug("Personnages", "Sauvegarde OK : " .. ply:Nick() .. " (ACC2 #" .. perso.ACC2CharID .. ")")
        end,
        function(err)
            TGRP.LogErreur("Personnages", "Erreur sauvegarde " .. ply:Nick() .. " : " .. tostring(err))
        end
    )
end

--- Sauvegarde tous les joueurs connectés
function TGRP.Persos.SauvegarderTous()
    for _, ply in ipairs(player.GetAll()) do
        if ply.tgrpPersoActif then
            ply.tgrpPersoActif.HP = ply:Health()
            TGRP.Persos.Sauvegarder(ply)
        end
    end
end

-- ============================================================
-- SUPPRESSION
-- ============================================================

--- Supprime un personnage TGRP (appelé quand ACC2 supprime un perso)
--- @param steamid string Le SteamID du joueur
--- @param acc2CharId number L'ID du personnage ACC2
--- @param callback function Appelée après suppression
function TGRP.Persos.Supprimer(steamid, acc2CharId, callback)
    TGRP.DB.Preparer(
        "DELETE FROM tgrp_personnages WHERE acc2_character_id = ?",
        { acc2CharId },
        function()
            -- Nettoyer le cache
            if TGRP.Persos.Cache[steamid] then
                TGRP.Persos.Cache[steamid][acc2CharId] = nil
            end
            TGRP.Log("Personnages", "Personnage TGRP supprimé (ACC2 #" .. acc2CharId .. ")", "info")
            TGRP.DB.LogAction(steamid, "perso_supprime", "ACC2 #" .. acc2CharId)
            if callback then callback(true) end
        end,
        function(err)
            TGRP.LogErreur("Personnages", "Erreur suppression : " .. tostring(err))
            if callback then callback(false) end
        end
    )
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
