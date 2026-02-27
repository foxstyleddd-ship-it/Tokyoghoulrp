--[[
    Tokyo Ghoul RP — Configuration des Quinque

    Modifiez ce fichier pour ajouter/modifier les types de Quinque.
    Pour ajouter un nouveau Quinque :
    1. Ajoutez une entrée dans la table ci-dessous
    2. Placez vos modèles dans models/tgrp/quinque/
    3. Placez vos animations dans models/tgrp/quinque/animations/
]]

TGRP.Config.Quinque = {}

-- ============================================================
-- TYPES DE QUINQUE (basés sur les types de Kagune récupérés)
-- ============================================================

TGRP.Config.Quinque.Types = {
    ["ukaku_q"] = {
        Nom = "Quinque Ukaku",
        Description = "Quinque forgée à partir d'un Kagune Ukaku. Légère et rapide.",
        KaguneSource = "ukaku",
        Rarete = "commun",
        Couleur = Color(100, 150, 255),

        -- Modèle 3D (à remplacer par le client)
        Model = "models/tgrp/quinque/ukaku_q.mdl",
        -- Modèle de la mallette
        ModelMallette = "models/tgrp/quinque/mallette.mdl",

        Stats = {
            Degats = 14,
            Vitesse = 1.2,
            Defense = 0.9,
            Portee = 550,
            Durabilite = 100,      -- Points de durabilité
            CoutDurabilite = 1,    -- Coût par attaque
        },
    },

    ["koukaku_q"] = {
        Nom = "Quinque Koukaku",
        Description = "Quinque forgée à partir d'un Kagune Koukaku. Très défensive.",
        KaguneSource = "koukaku",
        Rarete = "commun",
        Couleur = Color(200, 50, 50),

        Model = "models/tgrp/quinque/koukaku_q.mdl",
        ModelMallette = "models/tgrp/quinque/mallette.mdl",

        Stats = {
            Degats = 10,
            Vitesse = 0.9,
            Defense = 1.6,
            Portee = 250,
            Durabilite = 150,
            CoutDurabilite = 0.5,
        },
    },

    ["rinkaku_q"] = {
        Nom = "Quinque Rinkaku",
        Description = "Quinque forgée à partir d'un Kagune Rinkaku. Dégâts élevés.",
        KaguneSource = "rinkaku",
        Rarete = "rare",
        Couleur = Color(150, 30, 200),

        Model = "models/tgrp/quinque/rinkaku_q.mdl",
        ModelMallette = "models/tgrp/quinque/mallette.mdl",

        Stats = {
            Degats = 20,
            Vitesse = 1.0,
            Defense = 0.7,
            Portee = 400,
            Durabilite = 80,
            CoutDurabilite = 1.5,
        },
    },

    ["bikaku_q"] = {
        Nom = "Quinque Bikaku",
        Description = "Quinque forgée à partir d'un Kagune Bikaku. Équilibrée.",
        KaguneSource = "bikaku",
        Rarete = "rare",
        Couleur = Color(50, 200, 100),

        Model = "models/tgrp/quinque/bikaku_q.mdl",
        ModelMallette = "models/tgrp/quinque/mallette.mdl",

        Stats = {
            Degats = 15,
            Vitesse = 1.1,
            Defense = 1.0,
            Portee = 350,
            Durabilite = 120,
            CoutDurabilite = 1,
        },
    },

    -- 5ème type à configurer par le client
    -- ["chimere_q"] = { ... },
}

-- ============================================================
-- RARETÉS (partagées avec Kagune pour cohérence)
-- ============================================================

TGRP.Config.Quinque.Raretes = TGRP.Config.Kagune and TGRP.Config.Kagune.Raretes or {
    ["commun"]     = { Nom = "Commun",     Couleur = Color(180, 180, 180), Poids = 50 },
    ["rare"]       = { Nom = "Rare",       Couleur = Color(50, 150, 255),  Poids = 30 },
    ["epique"]     = { Nom = "Épique",     Couleur = Color(180, 50, 255),  Poids = 15 },
    ["legendaire"] = { Nom = "Légendaire", Couleur = Color(255, 180, 0),   Poids = 4 },
    ["mythique"]   = { Nom = "Mythique",   Couleur = Color(255, 50, 50),   Poids = 1 },
}

-- ============================================================
-- CRAFT DE QUINQUE
-- ============================================================

TGRP.Config.Quinque.Craft = {
    -- Nombre de poches RC nécessaires pour crafter une Quinque
    PochesRequises = 1,

    -- Le type de Quinque dépend du type de Kagune de la poche RC
    TypeParSource = true,

    -- Temps de craft en secondes
    TempsCraft = 10,

    -- Le craft se fait via un PNJ spécial au QG du CCG
    PNJCraft = true,
}

-- ============================================================
-- DURABILITÉ & RÉPARATION
-- ============================================================

TGRP.Config.Quinque.Reparation = {
    -- Coût de réparation (monnaie in-game par point de durabilité)
    CoutParPoint = 5,

    -- Réparation via PNJ au QG du CCG
    PNJReparation = true,

    -- La Quinque est-elle détruite à 0 durabilité ou juste inutilisable ?
    DestructionAZero = false, -- false = inutilisable, true = détruite
}
