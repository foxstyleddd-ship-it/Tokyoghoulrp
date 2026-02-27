--[[
    Tokyo Ghoul RP — Module Factions
    Registre des factions, validation, helpers.
    Partagé serveur/client.
]]

TGRP.Factions = TGRP.Factions or {}

-- ============================================================
-- ACCÈS AUX FACTIONS
-- ============================================================

--- Récupère les données d'une faction depuis la config
--- @param factionID string L'ID de la faction ("ghoul", "ccg", "civil")
--- @return table|nil Les données de la faction
function TGRP.Factions.Get(factionID)
    if not TGRP.Config.Factions then return nil end
    return TGRP.Config.Factions[factionID]
end

--- Vérifie si une faction existe
--- @param factionID string L'ID de la faction
--- @return boolean
function TGRP.Factions.Existe(factionID)
    return TGRP.Factions.Get(factionID) ~= nil
end

--- Retourne la liste de tous les IDs de factions
--- @return table Liste des IDs
function TGRP.Factions.ListeIDs()
    local ids = {}
    for id, _ in pairs(TGRP.Config.Factions) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end

--- Retourne le nom affiché d'une faction
--- @param factionID string L'ID de la faction
--- @return string Le nom affiché
function TGRP.Factions.Nom(factionID)
    local f = TGRP.Factions.Get(factionID)
    return f and f.Nom or "Inconnu"
end

--- Retourne la couleur d'une faction
--- @param factionID string L'ID de la faction
--- @return Color La couleur de la faction
function TGRP.Factions.Couleur(factionID)
    local f = TGRP.Factions.Get(factionID)
    return f and f.Couleur or Color(255, 255, 255)
end

--- Vérifie si un model est valide pour une faction donnée
--- @param factionID string L'ID de la faction
--- @param model string Le chemin du model
--- @return boolean
function TGRP.Factions.ModelValide(factionID, model)
    local f = TGRP.Factions.Get(factionID)
    if not f or not f.Models then return false end

    for _, m in ipairs(f.Models) do
        if m == model then return true end
    end
    return false
end

--- Retourne les models disponibles pour une faction
--- @param factionID string L'ID de la faction
--- @return table Liste des models
function TGRP.Factions.Models(factionID)
    local f = TGRP.Factions.Get(factionID)
    return f and f.Models or {}
end

--- Retourne le point de spawn d'une faction
--- @param factionID string L'ID de la faction
--- @return Vector, Angle La position et l'angle de spawn
function TGRP.Factions.SpawnPoint(factionID)
    local f = TGRP.Factions.Get(factionID)
    if f and f.Spawn then
        return f.Spawn.Position, f.Spawn.Angle
    end
    return Vector(0, 0, 0), Angle(0, 0, 0)
end

--- Retourne les HP de base d'une faction
--- @param factionID string L'ID de la faction
--- @return number Les HP de base
function TGRP.Factions.HP(factionID)
    local f = TGRP.Factions.Get(factionID)
    return f and f.HP or 100
end

--- Vérifie si une faction peut utiliser le Kagune
--- @param factionID string L'ID de la faction
--- @return boolean
function TGRP.Factions.PeutKagune(factionID)
    local f = TGRP.Factions.Get(factionID)
    return f and f.Kagune or false
end

--- Vérifie si une faction peut utiliser le Quinque
--- @param factionID string L'ID de la faction
--- @return boolean
function TGRP.Factions.PeutQuinque(factionID)
    local f = TGRP.Factions.Get(factionID)
    return f and f.Quinque or false
end

-- ============================================================
-- MAPPING ACC2 ↔ TGRP
-- ============================================================

--- Retourne l'ID de faction TGRP à partir d'un ID de faction ACC2
--- @param acc2FactionId number L'ID de faction ACC2
--- @return string|nil L'ID de faction TGRP
function TGRP.Factions.DepuisACC2ID(acc2FactionId)
    return TGRP.ACC2Bridge and TGRP.ACC2Bridge.FactionTGRPDepuisACC2(acc2FactionId) or nil
end

--- Retourne l'ID de faction ACC2 à partir d'un ID de faction TGRP
--- @param tgrpFactionId string L'ID de faction TGRP
--- @return number|nil L'ID de faction ACC2
function TGRP.Factions.VersACC2ID(tgrpFactionId)
    return TGRP.ACC2Bridge and TGRP.ACC2Bridge.FactionACC2DepuisTGRP(tgrpFactionId) or nil
end

-- ============================================================
-- APPLICATION SUR UN JOUEUR
-- ============================================================

--- Applique une faction à un joueur (stocke les données sur l'entité)
--- @param ply Player Le joueur
--- @param factionID string L'ID de la faction
function TGRP.Factions.Appliquer(ply, factionID)
    if not IsValid(ply) then return end
    if not TGRP.Factions.Existe(factionID) then return end

    ply.tgrpFaction = factionID
    ply:SetNWString("tgrp_faction", factionID)

    TGRP.Log("Factions", ply:Nick() .. " → faction " .. TGRP.Factions.Nom(factionID), "info")
end

--- Retourne la faction d'un joueur
--- @param ply Player Le joueur
--- @return string L'ID de la faction
function TGRP.Factions.DuJoueur(ply)
    if not IsValid(ply) then return "" end
    return ply.tgrpFaction or ply:GetNWString("tgrp_faction", "")
end
