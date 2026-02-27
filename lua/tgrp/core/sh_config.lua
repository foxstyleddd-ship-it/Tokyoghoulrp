--[[
    Tokyo Ghoul RP — Core : Système de Configuration
    Validation et accès centralisé aux configs.
]]

TGRP.ConfigSys = TGRP.ConfigSys or {}

--- Vérifie qu'une valeur de config existe et est du bon type
--- @param table table La table de config à vérifier
--- @param cle string La clé à vérifier
--- @param typeAttendu string Le type attendu ("string", "number", "table", "boolean")
--- @param valeurDefaut any La valeur par défaut si la clé n'existe pas
--- @return any La valeur de la config ou la valeur par défaut
function TGRP.ConfigSys.Obtenir(tbl, cle, typeAttendu, valeurDefaut)
    if tbl == nil then
        TGRP.Log("Config", "Table de config nil pour la clé : " .. tostring(cle), "erreur")
        return valeurDefaut
    end

    local valeur = tbl[cle]

    if valeur == nil then
        if valeurDefaut ~= nil then
            TGRP.Log("Config", "Clé manquante '" .. cle .. "', utilisation de la valeur par défaut : " .. tostring(valeurDefaut), "avertissement")
            return valeurDefaut
        end
        TGRP.Log("Config", "Clé manquante et aucune valeur par défaut : " .. cle, "erreur")
        return nil
    end

    if typeAttendu and type(valeur) ~= typeAttendu then
        TGRP.Log("Config", "Type incorrect pour '" .. cle .. "' : attendu " .. typeAttendu .. ", reçu " .. type(valeur), "erreur")
        return valeurDefaut
    end

    return valeur
end

--- Valide une table de configuration entière selon un schéma
--- @param nomConfig string Nom de la config (pour les logs)
--- @param config table La table de configuration à valider
--- @param schema table Le schéma de validation {cle = {type = "string", requis = true, defaut = "x"}}
--- @return boolean true si la validation est passée
function TGRP.ConfigSys.Valider(nomConfig, config, schema)
    if not config then
        TGRP.Log("Config", nomConfig .. " : table de configuration manquante !", "erreur")
        return false
    end

    local valide = true

    for cle, regle in pairs(schema) do
        local valeur = config[cle]

        -- Vérifier si requis
        if regle.requis and valeur == nil then
            TGRP.Log("Config", nomConfig .. " : clé requise manquante '" .. cle .. "'", "erreur")
            valide = false
        end

        -- Vérifier le type
        if valeur ~= nil and regle.type and type(valeur) ~= regle.type then
            TGRP.Log("Config", nomConfig .. " : '" .. cle .. "' devrait être " .. regle.type .. " mais est " .. type(valeur), "erreur")
            valide = false
        end

        -- Appliquer valeur par défaut si manquante
        if valeur == nil and regle.defaut ~= nil then
            config[cle] = regle.defaut
            TGRP.Log("Config", nomConfig .. " : '" .. cle .. "' → valeur par défaut : " .. tostring(regle.defaut), "info")
        end

        -- Vérifier min/max pour les nombres
        if valeur ~= nil and type(valeur) == "number" then
            if regle.min and valeur < regle.min then
                TGRP.Log("Config", nomConfig .. " : '" .. cle .. "' = " .. valeur .. " est inférieur au minimum " .. regle.min, "avertissement")
                config[cle] = regle.min
            end
            if regle.max and valeur > regle.max then
                TGRP.Log("Config", nomConfig .. " : '" .. cle .. "' = " .. valeur .. " est supérieur au maximum " .. regle.max, "avertissement")
                config[cle] = regle.max
            end
        end
    end

    if valide then
        TGRP.Log("Config", nomConfig .. " : validation réussie", "info")
    end

    return valide
end

--- Raccourci pour accéder à une config imbriquée
--- @param chemin string Chemin séparé par des points (ex: "General.MaxPersonnages")
--- @return any La valeur trouvée ou nil
function TGRP.ConfigSys.Get(chemin)
    local parties = string.Split(chemin, ".")
    local courant = TGRP.Config

    for _, partie in ipairs(parties) do
        if type(courant) ~= "table" then return nil end
        courant = courant[partie]
    end

    return courant
end
