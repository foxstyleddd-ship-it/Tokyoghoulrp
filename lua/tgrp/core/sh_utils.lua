--[[
    Tokyo Ghoul RP — Core : Utilitaires
    Fonctions partagées réutilisables dans tout l'addon.
]]

TGRP.Utils = TGRP.Utils or {}

-- ============================================================
-- JOUEURS
-- ============================================================

--- Récupère un joueur par son SteamID
--- @param steamid string Le SteamID à chercher
--- @return Player|nil Le joueur trouvé ou nil
function TGRP.Utils.JoueurParSteamID(steamid)
    for _, ply in ipairs(player.GetAll()) do
        if ply:SteamID() == steamid then
            return ply
        end
    end
    return nil
end

--- Vérifie si un joueur est d'une faction donnée
--- @param ply Player Le joueur
--- @param faction string L'ID de la faction
--- @return boolean
function TGRP.Utils.EstFaction(ply, faction)
    return IsValid(ply) and ply.tgrpFaction == faction
end

--- Vérifie si un joueur est une Ghoul
--- @param ply Player Le joueur
--- @return boolean
function TGRP.Utils.EstGhoul(ply)
    return TGRP.Utils.EstFaction(ply, "ghoul")
end

--- Vérifie si un joueur est CCG
--- @param ply Player Le joueur
--- @return boolean
function TGRP.Utils.EstCCG(ply)
    return TGRP.Utils.EstFaction(ply, "ccg")
end

--- Vérifie si un joueur est Civil
--- @param ply Player Le joueur
--- @return boolean
function TGRP.Utils.EstCivil(ply)
    return TGRP.Utils.EstFaction(ply, "civil")
end

-- ============================================================
-- TABLES
-- ============================================================

--- Copie superficielle d'une table
--- @param tbl table La table à copier
--- @return table La copie
function TGRP.Utils.CopierTable(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copie = {}
    for k, v in pairs(tbl) do
        copie[k] = v
    end
    return copie
end

--- Copie profonde d'une table (récursive)
--- @param tbl table La table à copier
--- @return table La copie profonde
function TGRP.Utils.CopierTableProfond(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copie = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copie[k] = TGRP.Utils.CopierTableProfond(v)
        else
            copie[k] = v
        end
    end
    return copie
end

--- Fusionne deux tables (la source écrase la destination)
--- @param destination table La table de destination
--- @param source table La table source
--- @return table La table fusionnée
function TGRP.Utils.FusionnerTables(destination, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(destination[k]) == "table" then
            TGRP.Utils.FusionnerTables(destination[k], v)
        else
            destination[k] = v
        end
    end
    return destination
end

-- ============================================================
-- MATHÉMATIQUES
-- ============================================================

--- Clamp une valeur entre un min et un max
--- @param valeur number La valeur
--- @param min number Le minimum
--- @param max number Le maximum
--- @return number La valeur clampée
function TGRP.Utils.Clamp(valeur, min, max)
    return math.max(min, math.min(max, valeur))
end

--- Interpolation linéaire
--- @param a number Valeur de départ
--- @param b number Valeur d'arrivée
--- @param t number Facteur d'interpolation (0-1)
--- @return number La valeur interpolée
function TGRP.Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

-- ============================================================
-- FORMATAGE
-- ============================================================

--- Formate un nombre avec des séparateurs de milliers
--- @param nombre number Le nombre à formater
--- @return string Le nombre formaté (ex: "1 234 567")
function TGRP.Utils.FormaterNombre(nombre)
    local str = tostring(math.floor(nombre))
    local resultat = ""
    local compteur = 0

    for i = #str, 1, -1 do
        resultat = string.sub(str, i, i) .. resultat
        compteur = compteur + 1
        if compteur % 3 == 0 and i > 1 then
            resultat = " " .. resultat
        end
    end

    return resultat
end

--- Formate une durée en secondes en texte lisible
--- @param secondes number La durée en secondes
--- @return string La durée formatée (ex: "2m 30s")
function TGRP.Utils.FormaterDuree(secondes)
    secondes = math.floor(secondes)
    if secondes < 60 then
        return secondes .. "s"
    elseif secondes < 3600 then
        local m = math.floor(secondes / 60)
        local s = secondes % 60
        return m .. "m " .. s .. "s"
    else
        local h = math.floor(secondes / 3600)
        local m = math.floor((secondes % 3600) / 60)
        return h .. "h " .. m .. "m"
    end
end

-- ============================================================
-- COOLDOWNS
-- ============================================================

TGRP.Utils.Cooldowns = {}

--- Vérifie et applique un cooldown
--- @param id string Identifiant unique du cooldown
--- @param duree number Durée du cooldown en secondes
--- @return boolean true si l'action est possible (cooldown terminé)
function TGRP.Utils.Cooldown(id, duree)
    local maintenant = CurTime()
    local fin = TGRP.Utils.Cooldowns[id] or 0

    if maintenant < fin then
        return false
    end

    TGRP.Utils.Cooldowns[id] = maintenant + duree
    return true
end

--- Retourne le temps restant d'un cooldown
--- @param id string Identifiant du cooldown
--- @return number Temps restant en secondes (0 si terminé)
function TGRP.Utils.CooldownRestant(id)
    local fin = TGRP.Utils.Cooldowns[id] or 0
    return math.max(0, fin - CurTime())
end
