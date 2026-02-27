--[[
    Tokyo Ghoul RP — Core : Module Base de Données (MySQL via mysqloo)
    Gestion de la connexion, requêtes préparées, pool, et retry.
    SERVEUR UNIQUEMENT.
]]

TGRP.DB = TGRP.DB or {}
TGRP.DB.Connexion = nil
TGRP.DB.EnAttente = {} -- File d'attente des requêtes si la DB n'est pas prête

-- ============================================================
-- CONFIGURATION BASE DE DONNÉES
-- ============================================================

TGRP.DB.Config = {
    Host = "127.0.0.1",
    Port = 3306,
    Utilisateur = "root",
    MotDePasse = "",
    BaseDeDonnees = "tgrp",
}

-- ============================================================
-- CONNEXION
-- ============================================================

--- Initialise la connexion à la base de données
function TGRP.DB.Connecter()
    -- Vérifier que mysqloo est disponible
    if not mysqloo then
        TGRP.LogErreur("Database", "mysqloo n'est pas installé ! Le serveur ne peut pas fonctionner sans base de données.")
        TGRP.LogErreur("Database", "Téléchargez mysqloo : https://github.com/FredyH/MySQLOO")
        return false
    end

    local cfg = TGRP.DB.Config

    TGRP.Log("Database", "Connexion à MySQL : " .. cfg.Utilisateur .. "@" .. cfg.Host .. ":" .. cfg.Port .. "/" .. cfg.BaseDeDonnees, "info")

    TGRP.DB.Connexion = mysqloo.connect(cfg.Host, cfg.Utilisateur, cfg.MotDePasse, cfg.BaseDeDonnees, cfg.Port)

    TGRP.DB.Connexion.onConnected = function()
        TGRP.Log("Database", "Connexion MySQL établie avec succès !", "info")

        -- Configurer le charset
        TGRP.DB.Executer("SET NAMES utf8mb4")

        -- Créer les tables
        TGRP.DB.CreerTables()

        -- Exécuter les requêtes en attente
        TGRP.DB.ViderFileAttente()
    end

    TGRP.DB.Connexion.onConnectionFailed = function(_, err)
        TGRP.LogErreur("Database", "Échec de connexion MySQL : " .. tostring(err))
        TGRP.LogErreur("Database", "Nouvelle tentative dans 5 secondes...")

        timer.Simple(5, function()
            TGRP.DB.Connecter()
        end)
    end

    TGRP.DB.Connexion:connect()
    return true
end

--- Vérifie si la DB est connectée
--- @return boolean
function TGRP.DB.EstConnecte()
    return TGRP.DB.Connexion and TGRP.DB.Connexion:status() == mysqloo.DATABASE_CONNECTED
end

-- ============================================================
-- REQUÊTES
-- ============================================================

--- Exécute une requête SQL simple
--- @param sql string La requête SQL
--- @param callback function Fonction appelée avec les résultats (optionnel)
--- @param errCallback function Fonction appelée en cas d'erreur (optionnel)
function TGRP.DB.Executer(sql, callback, errCallback)
    if not TGRP.DB.EstConnecte() then
        -- Mettre en file d'attente
        table.insert(TGRP.DB.EnAttente, { sql = sql, callback = callback, errCallback = errCallback })
        TGRP.LogDebug("Database", "Requête mise en attente (DB non connectée) : " .. string.sub(sql, 1, 80))
        return
    end

    local requete = TGRP.DB.Connexion:query(sql)

    requete.onSuccess = function(_, donnees)
        TGRP.LogDebug("Database", "Requête OK : " .. string.sub(sql, 1, 80))
        if callback then
            callback(donnees)
        end
    end

    requete.onError = function(_, err, sqlErr)
        TGRP.LogErreur("Database", "Erreur SQL : " .. tostring(err))
        TGRP.LogErreur("Database", "Requête : " .. string.sub(sql, 1, 200))
        if errCallback then
            errCallback(err, sqlErr)
        end
    end

    requete:start()
    return requete
end

--- Exécute une requête préparée (protection contre les injections SQL)
--- @param sql string La requête SQL avec des ? comme placeholders
--- @param parametres table Les paramètres à injecter dans la requête
--- @param callback function Fonction appelée avec les résultats
--- @param errCallback function Fonction appelée en cas d'erreur
function TGRP.DB.Preparer(sql, parametres, callback, errCallback)
    if not TGRP.DB.EstConnecte() then
        table.insert(TGRP.DB.EnAttente, {
            sql = sql, parametres = parametres,
            callback = callback, errCallback = errCallback,
            preparee = true,
        })
        return
    end

    local requete = TGRP.DB.Connexion:prepare(sql)

    -- Injecter les paramètres
    for i, param in ipairs(parametres) do
        local t = type(param)
        if t == "string" then
            requete:setString(i, param)
        elseif t == "number" then
            if math.floor(param) == param then
                requete:setNumber(i, param)
            else
                requete:setNumber(i, param)
            end
        elseif t == "boolean" then
            requete:setBoolean(i, param)
        elseif param == nil then
            requete:setNull(i)
        end
    end

    requete.onSuccess = function(_, donnees)
        TGRP.LogDebug("Database", "Requête préparée OK : " .. string.sub(sql, 1, 80))
        if callback then
            callback(donnees)
        end
    end

    requete.onError = function(_, err, sqlErr)
        TGRP.LogErreur("Database", "Erreur requête préparée : " .. tostring(err))
        TGRP.LogErreur("Database", "SQL : " .. string.sub(sql, 1, 200))
        if errCallback then
            errCallback(err, sqlErr)
        end
    end

    requete:start()
    return requete
end

--- Échappe une chaîne pour la protéger des injections SQL
--- @param str string La chaîne à échapper
--- @return string La chaîne échappée
function TGRP.DB.Echapper(str)
    if TGRP.DB.EstConnecte() then
        return TGRP.DB.Connexion:escape(tostring(str))
    end
    -- Fallback basique si la DB n'est pas connectée
    return string.gsub(tostring(str), "'", "\\'")
end

--- Vide la file d'attente de requêtes
function TGRP.DB.ViderFileAttente()
    if #TGRP.DB.EnAttente == 0 then return end

    TGRP.Log("Database", "Exécution de " .. #TGRP.DB.EnAttente .. " requêtes en attente...", "info")

    local file = TGRP.DB.EnAttente
    TGRP.DB.EnAttente = {}

    for _, req in ipairs(file) do
        if req.preparee then
            TGRP.DB.Preparer(req.sql, req.parametres, req.callback, req.errCallback)
        else
            TGRP.DB.Executer(req.sql, req.callback, req.errCallback)
        end
    end
end

-- ============================================================
-- CRÉATION DES TABLES
-- ============================================================

function TGRP.DB.CreerTables()
    TGRP.Log("Database", "Création/vérification des tables...", "info")

    -- Table des joueurs
    TGRP.DB.Executer([[
        CREATE TABLE IF NOT EXISTS tgrp_joueurs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            steamid VARCHAR(32) NOT NULL UNIQUE,
            nom_steam VARCHAR(128) NOT NULL,
            premiere_connexion DATETIME DEFAULT CURRENT_TIMESTAMP,
            derniere_connexion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            argent INT DEFAULT 1000,
            rerolls_restants INT DEFAULT 1,
            INDEX idx_steamid (steamid)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Table des personnages (liée à ACC2 via acc2_character_id)
    TGRP.DB.Executer([[
        CREATE TABLE IF NOT EXISTS tgrp_personnages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            steamid VARCHAR(32) NOT NULL,
            acc2_character_id INT NOT NULL UNIQUE,
            faction VARCHAR(16) NOT NULL,
            rc INT DEFAULT 100,
            faim FLOAT DEFAULT 80,
            hp INT DEFAULT 100,
            kagune_type VARCHAR(32) DEFAULT NULL,
            quinque_type VARCHAR(32) DEFAULT NULL,
            inventaire TEXT,
            equipement TEXT,
            cosmetique TEXT,
            hotbar TEXT,
            skills_debloquees TEXT,
            rang_ccg VARCHAR(32) DEFAULT 'academie',
            reroll_utilise TINYINT(1) DEFAULT 0,
            date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
            derniere_utilisation DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_steamid (steamid),
            INDEX idx_acc2_char (acc2_character_id),
            INDEX idx_faction (faction)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Table des logs d'actions (traçabilité)
    TGRP.DB.Executer([[
        CREATE TABLE IF NOT EXISTS tgrp_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            steamid VARCHAR(32),
            action VARCHAR(64) NOT NULL,
            details TEXT,
            date_action DATETIME DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_steamid (steamid),
            INDEX idx_action (action),
            INDEX idx_date (date_action)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    TGRP.Log("Database", "Tables vérifiées/créées avec succès", "info")
end

-- ============================================================
-- HELPERS PRATIQUES
-- ============================================================

--- Sauvegarde une action dans la table de logs
--- @param steamid string SteamID du joueur
--- @param action string Type d'action
--- @param details string Détails de l'action
function TGRP.DB.LogAction(steamid, action, details)
    TGRP.DB.Preparer(
        "INSERT INTO tgrp_logs (steamid, action, details) VALUES (?, ?, ?)",
        { steamid, action, details or "" }
    )
end

-- ============================================================
-- INITIALISATION
-- ============================================================

hook.Add("Initialize", "TGRP_InitDatabase", function()
    TGRP.DB.Connecter()
end)
