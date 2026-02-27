--[[
    Tokyo Ghoul RP — Core : Système de Logs
    Logging centralisé avec niveaux de sévérité.
]]

TGRP.Logs = TGRP.Logs or {}

-- Niveaux de log
local NIVEAUX = {
    ["debug"]         = { Priorite = 0, Couleur = Color(150, 150, 150), Prefixe = "DEBUG" },
    ["info"]          = { Priorite = 1, Couleur = Color(100, 200, 255), Prefixe = "INFO" },
    ["avertissement"] = { Priorite = 2, Couleur = Color(255, 200, 50),  Prefixe = "WARN" },
    ["erreur"]        = { Priorite = 3, Couleur = Color(255, 50, 50),   Prefixe = "ERREUR" },
}

-- Niveau minimum affiché (debug = tout afficher)
local niveauMinimum = 1 -- info par défaut

--- Définit le niveau minimum de log
--- @param niveau string Le niveau minimum ("debug", "info", "avertissement", "erreur")
function TGRP.Logs.SetNiveau(niveau)
    local n = NIVEAUX[niveau]
    if n then
        niveauMinimum = n.Priorite
    end
end

--- Log un message
--- @param module string Nom du module source (ex: "Database", "Combat")
--- @param message string Le message à logger
--- @param niveau string Le niveau de log ("debug", "info", "avertissement", "erreur")
function TGRP.Log(module, message, niveau)
    niveau = niveau or "info"
    local n = NIVEAUX[niveau]
    if not n then n = NIVEAUX["info"] end

    -- Vérifier le niveau minimum
    if n.Priorite < niveauMinimum then return end

    -- Formatter le message
    local horodatage = os.date("%H:%M:%S")
    local texteFormate = string.format("[TGRP][%s][%s][%s] %s", horodatage, n.Prefixe, module, message)

    -- Affichage console avec couleurs
    if SERVER then
        MsgC(n.Couleur, texteFormate .. "\n")
    else
        MsgC(n.Couleur, texteFormate .. "\n")
    end

    -- Écriture dans un fichier de log (serveur uniquement)
    if SERVER then
        local nomFichier = "tgrp/logs/" .. os.date("%Y-%m-%d") .. ".txt"
        file.Append(nomFichier, texteFormate .. "\n")
    end
end

--- Raccourci pour log debug (seulement si mode debug activé)
function TGRP.LogDebug(module, message)
    TGRP.Log(module, message, "debug")
end

--- Raccourci pour log erreur
function TGRP.LogErreur(module, message)
    TGRP.Log(module, message, "erreur")
end

-- Initialisation : créer le dossier de logs
if SERVER then
    if not file.IsDir("tgrp", "DATA") then
        file.CreateDir("tgrp")
    end
    if not file.IsDir("tgrp/logs", "DATA") then
        file.CreateDir("tgrp/logs")
    end
end

-- Appliquer le mode debug depuis la config si disponible
hook.Add("Initialize", "TGRP_InitLogs", function()
    if TGRP.Config and TGRP.Config.General and TGRP.Config.General.Debug then
        TGRP.Logs.SetNiveau("debug")
        TGRP.Log("Logs", "Mode debug activé", "info")
    end
end)
