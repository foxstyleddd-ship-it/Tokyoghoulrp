--[[
    Tokyo Ghoul RP — Module ACC2 Bridge (Partagé)
    Pont d'intégration entre Advanced Character Creator (ACC2) et TGRP.
    Contient le namespace, les tables de mapping faction, et les helpers.
]]

TGRP.ACC2Bridge = TGRP.ACC2Bridge or {}

-- Mapping des factions : ACC2 faction ID (int) <-> TGRP faction ID (string)
-- Rempli côté serveur lors de la synchronisation des factions
TGRP.ACC2Bridge.FactionMap = {}        -- [acc2_faction_id] = "ghoul"/"ccg"/"civil"
TGRP.ACC2Bridge.FactionMapInverse = {} -- ["ghoul"] = acc2_faction_id

-- ============================================================
-- HELPERS DE MAPPING
-- ============================================================

--- Retourne l'ID de faction TGRP à partir d'un ID de faction ACC2
--- @param acc2FactionId number L'ID de faction ACC2 (entier)
--- @return string|nil L'ID de faction TGRP ("ghoul", "ccg", "civil") ou nil
function TGRP.ACC2Bridge.FactionTGRPDepuisACC2(acc2FactionId)
    if not acc2FactionId then return nil end
    return TGRP.ACC2Bridge.FactionMap[tonumber(acc2FactionId)]
end

--- Retourne l'ID de faction ACC2 à partir d'un ID de faction TGRP
--- @param tgrpFactionId string L'ID de faction TGRP ("ghoul", "ccg", "civil")
--- @return number|nil L'ID de faction ACC2 (entier) ou nil
function TGRP.ACC2Bridge.FactionACC2DepuisTGRP(tgrpFactionId)
    if not tgrpFactionId then return nil end
    return TGRP.ACC2Bridge.FactionMapInverse[tgrpFactionId]
end

--- Vérifie si ACC2 est chargé et disponible
--- @return boolean
function TGRP.ACC2Bridge.EstDisponible()
    return ACC2 ~= nil
end
