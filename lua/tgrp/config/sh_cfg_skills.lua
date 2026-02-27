--[[
    Tokyo Ghoul RP — Configuration des Compétences & Skill Tree

    Modifiez ce fichier pour ajouter/modifier les compétences.
    Chaque compétence appartient à un type de Kagune ou Quinque.
]]

TGRP.Config.Skills = {}

-- ============================================================
-- PARAMÈTRES GÉNÉRAUX
-- ============================================================

TGRP.Config.Skills.General = {
    -- Nombre de slots dans la hotbar
    SlotsHotbar = 4,

    -- Touches par défaut de la hotbar
    Touches = {
        [1] = KEY_1,
        [2] = KEY_2,
        [3] = KEY_3,
        [4] = KEY_4,
    },

    -- Touche pour ouvrir le menu compétences
    ToucheMenu = KEY_K,

    -- Global cooldown entre deux compétences (secondes)
    GlobalCooldown = 0.5,
}

-- ============================================================
-- RANGS DE COMPÉTENCES
-- ============================================================

TGRP.Config.Skills.Rangs = {
    { ID = "E", Nom = "Rang E", RCRequis = 0,    Couleur = Color(180, 180, 180) },
    { ID = "D", Nom = "Rang D", RCRequis = 200,  Couleur = Color(100, 200, 100) },
    { ID = "C", Nom = "Rang C", RCRequis = 800,  Couleur = Color(50, 150, 255) },
    { ID = "B", Nom = "Rang B", RCRequis = 2000, Couleur = Color(180, 50, 255) },
    { ID = "A", Nom = "Rang A", RCRequis = 4000, Couleur = Color(255, 180, 0) },
    { ID = "S", Nom = "Rang S", RCRequis = 7000, Couleur = Color(255, 50, 50) },
    { ID = "SS", Nom = "Rang SS", RCRequis = 10000, Couleur = Color(255, 0, 0) },
}

-- ============================================================
-- COMPÉTENCES KAGUNE (exemple pour Rinkaku)
-- ============================================================

TGRP.Config.Skills.Kagune = {
    ["rinkaku"] = {
        -- Compétences organisées en arbre (chaque compétence peut avoir des prérequis)
        {
            ID = "rinkaku_frappe",
            Nom = "Frappe tentaculaire",
            Description = "Frappe basique avec les tentacules du Rinkaku.",
            Icone = "tgrp/skills/rinkaku_frappe.png",
            Rang = "E",
            Cooldown = 2,
            CoutRC = 5,
            Degats = 25,
            Portee = 400,
            Animation = "", -- À remplir par le client
            Prerequis = {},
        },
        {
            ID = "rinkaku_balayage",
            Nom = "Balayage",
            Description = "Attaque en zone autour du joueur.",
            Icone = "tgrp/skills/rinkaku_balayage.png",
            Rang = "D",
            Cooldown = 5,
            CoutRC = 15,
            Degats = 35,
            Portee = 300,
            Zone = true,   -- Attaque de zone (AoE)
            RayonZone = 200,
            Animation = "",
            Prerequis = { "rinkaku_frappe" },
        },
        {
            ID = "rinkaku_empalement",
            Nom = "Empalement",
            Description = "Empale la cible avec un tentacule, infligeant des dégâts massifs.",
            Icone = "tgrp/skills/rinkaku_empalement.png",
            Rang = "B",
            Cooldown = 12,
            CoutRC = 30,
            Degats = 60,
            Portee = 500,
            Animation = "",
            Prerequis = { "rinkaku_balayage" },
        },
        {
            ID = "rinkaku_regeneration",
            Nom = "Régénération",
            Description = "Le Rinkaku accélère la régénération naturelle de la ghoul.",
            Icone = "tgrp/skills/rinkaku_regen.png",
            Rang = "C",
            Cooldown = 20,
            CoutRC = 25,
            Soin = 40,
            Duree = 5,    -- Durée de l'effet en secondes
            Animation = "",
            Prerequis = { "rinkaku_frappe" },
        },
        {
            ID = "rinkaku_fureur",
            Nom = "Fureur du Rinkaku",
            Description = "Déchaîne tous les tentacules dans une attaque dévastatrice.",
            Icone = "tgrp/skills/rinkaku_fureur.png",
            Rang = "A",
            Cooldown = 30,
            CoutRC = 50,
            Degats = 100,
            Portee = 450,
            Zone = true,
            RayonZone = 350,
            Animation = "",
            Prerequis = { "rinkaku_empalement" },
        },
    },

    -- Les autres types de Kagune suivent le même format
    -- ["ukaku"] = { ... },
    -- ["koukaku"] = { ... },
    -- ["bikaku"] = { ... },
}

-- ============================================================
-- COMPÉTENCES QUINQUE (même structure)
-- ============================================================

TGRP.Config.Skills.Quinque = {
    -- Même format que Kagune, mais pour les Quinques
    -- ["ukaku_q"] = { ... },
    -- ["rinkaku_q"] = { ... },
}
