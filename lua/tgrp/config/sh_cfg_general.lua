--[[
    Tokyo Ghoul RP — Configuration Générale

    Ce fichier est destiné au propriétaire du serveur.
    Modifiez les valeurs ci-dessous selon vos besoins.
    NE MODIFIEZ PAS les fichiers en dehors du dossier config/.
]]

TGRP.Config = TGRP.Config or {}

-- ============================================================
-- PARAMÈTRES GÉNÉRAUX DU SERVEUR
-- ============================================================

TGRP.Config.General = {
    -- Nom du serveur affiché dans les UI
    NomServeur = "Tokyo Ghoul RP",

    -- Nombre maximum de slots de personnages par joueur
    MaxPersonnages = 3,

    -- Le joueur mort reste sur son corps jusqu'à interaction
    -- Timer de respawn forcé en secondes (0 = pas de timer, le joueur attend indéfiniment)
    TimeoutRespawn = 300, -- 5 minutes max avant respawn forcé (0 pour désactiver)

    -- Plusieurs ghouls peuvent manger le même cadavre ?
    CadavrePartage = false,

    -- Intervalle de sauvegarde automatique en secondes
    IntervalSauvegarde = 60,

    -- Mode debug (logs détaillés)
    Debug = false,
}

-- ============================================================
-- PARAMÈTRES DE PERFORMANCE (120 joueurs)
-- ============================================================

TGRP.Config.Performance = {
    -- Intervalle de mise à jour du networking en secondes
    IntervalNetworking = 0.1,

    -- Distance maximale pour les mises à jour réseau (unités Source)
    DistanceMaxNetwork = 4096,

    -- Nombre maximum de cadavres simultanés sur la map
    MaxCadavres = 60,

    -- Intervalle de mise à jour de la faim en secondes
    IntervalFaim = 30,

    -- Regrouper les messages réseau (batching)
    NetworkBatching = true,
}
