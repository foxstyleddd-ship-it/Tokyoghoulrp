--[[
    Tokyo Ghoul RP — Point d'entrée principal
    Ce fichier charge tous les modules du gamemode.
]]

TGRP = TGRP or {}
TGRP.Version = "1.0.0"
TGRP.Modules = {}

-- Répertoire racine de l'addon
local RACINE = "tgrp/"

--- Charge un fichier selon son préfixe (sh_, sv_, cl_)
--- @param chemin string Le chemin du fichier relatif à lua/
function TGRP.ChargerFichier(chemin)
    local nom = string.GetFileFromFilename(chemin)

    if string.StartWith(nom, "sh_") then
        AddCSLuaFile(chemin)
        include(chemin)
    elseif string.StartWith(nom, "sv_") then
        if SERVER then
            include(chemin)
        end
    elseif string.StartWith(nom, "cl_") then
        AddCSLuaFile(chemin)
        if CLIENT then
            include(chemin)
        end
    elseif string.StartWith(nom, "net_") then
        -- Fichiers networking : partagés (contiennent la déclaration + handlers)
        AddCSLuaFile(chemin)
        include(chemin)
    end
end

--- Charge tous les fichiers Lua d'un répertoire
--- @param repertoire string Le chemin du répertoire relatif à lua/
function TGRP.ChargerRepertoire(repertoire)
    local fichiers, dossiers = file.Find(repertoire .. "*.lua", "LUA")

    -- Charger d'abord les fichiers partagés (sh_), puis serveur (sv_), puis client (cl_)
    local ordre = { sh_ = 1, sv_ = 2, cl_ = 3, net = 4 }

    table.sort(fichiers, function(a, b)
        local prefA = string.sub(a, 1, 3)
        local prefB = string.sub(b, 1, 3)
        return (ordre[prefA] or 5) < (ordre[prefB] or 5)
    end)

    for _, fichier in ipairs(fichiers) do
        TGRP.ChargerFichier(repertoire .. fichier)
    end
end

--- Charge un module complet (tous les fichiers de son répertoire)
--- @param nomModule string Le nom du module (nom du dossier dans modules/)
function TGRP.ChargerModule(nomModule)
    local chemin = RACINE .. "modules/" .. nomModule .. "/"
    TGRP.ChargerRepertoire(chemin)
    TGRP.Modules[nomModule] = true
    print("[TGRP] Module chargé : " .. nomModule)
end

-- ============================================================
-- Chargement du système
-- ============================================================

print("[TGRP] ========================================")
print("[TGRP] Tokyo Ghoul RP v" .. TGRP.Version)
print("[TGRP] Chargement en cours...")
print("[TGRP] ========================================")

-- 1. Charger le core (config, database, networking, utils)
TGRP.ChargerRepertoire(RACINE .. "config/")
TGRP.ChargerRepertoire(RACINE .. "core/")

-- 2. Charger les modules dans l'ordre de dépendance
local modulesOrdre = {
    -- Sprint 0-1 : Fondations
    "factions",
    "characters",

    -- Sprint 2 : RC & Mort
    "rc",
    "death",

    -- Sprint 3 : Kagune & Quinque
    "kagune",
    "quinque",
    "reroll",

    -- Sprint 4-5 : Skills & Combat
    "skills",
    "combat",

    -- Sprint 6-7 : Inventaire & Boutique
    "inventory",
    "shop",

    -- Sprint 8-9 : RP avancé
    "reputation",
    "capture",
    "masks",

    -- Sprint 10-11 : Contenu dynamique
    "events",
    "market",
}

for _, nomModule in ipairs(modulesOrdre) do
    local chemin = RACINE .. "modules/" .. nomModule .. "/"
    local fichiers = file.Find(chemin .. "*.lua", "LUA")

    if fichiers and #fichiers > 0 then
        TGRP.ChargerModule(nomModule)
    end
end

-- 3. Charger les UI
TGRP.ChargerRepertoire(RACINE .. "ui/components/")
TGRP.ChargerRepertoire(RACINE .. "ui/hud/")
TGRP.ChargerRepertoire(RACINE .. "ui/menus/")

print("[TGRP] ========================================")
print("[TGRP] Chargement terminé ! (" .. table.Count(TGRP.Modules) .. " modules)")
print("[TGRP] ========================================")
