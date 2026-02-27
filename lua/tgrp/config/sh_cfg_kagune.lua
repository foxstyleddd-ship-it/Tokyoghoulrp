--[[
    Tokyo Ghoul RP — Configuration des Kagune

    Modifiez ce fichier pour ajouter/modifier les types de Kagune.
    Pour ajouter un nouveau Kagune :
    1. Ajoutez une entrée dans la table ci-dessous
    2. Placez vos modèles dans models/tgrp/kagune/
    3. Placez vos animations dans models/tgrp/kagune/animations/
]]

TGRP.Config.Kagune = {}

-- ============================================================
-- TYPES DE KAGUNE
-- ============================================================

TGRP.Config.Kagune.Types = {
    ["ukaku"] = {
        Nom = "Ukaku",
        Description = "Kagune situé sur les épaules. Rapide et offensif, mais consomme beaucoup de RC.",
        Rarete = "commun",      -- commun / rare / epique / legendaire / mythique
        Couleur = Color(100, 150, 255),

        -- Modèle 3D du Kagune (à remplacer par le client)
        Model = "models/tgrp/kagune/ukaku.mdl",

        -- Statistiques de base
        Stats = {
            Degats = 15,
            Vitesse = 1.3,       -- Multiplicateur de vitesse quand activé
            Defense = 0.8,       -- Multiplicateur de défense (faible)
            CoutRC = 5,          -- Coût RC par seconde quand activé
            Portee = 600,        -- Portée des attaques (unités Source)
        },
    },

    ["koukaku"] = {
        Nom = "Koukaku",
        Description = "Kagune situé sous l'omoplate. Très résistant, idéal pour la défense.",
        Rarete = "commun",
        Couleur = Color(200, 50, 50),

        Model = "models/tgrp/kagune/koukaku.mdl",

        Stats = {
            Degats = 12,
            Vitesse = 0.85,
            Defense = 1.5,
            CoutRC = 3,
            Portee = 300,
        },
    },

    ["rinkaku"] = {
        Nom = "Rinkaku",
        Description = "Kagune situé dans le bas du dos. Puissant en attaque, mais fragile.",
        Rarete = "rare",
        Couleur = Color(150, 30, 200),

        Model = "models/tgrp/kagune/rinkaku.mdl",

        Stats = {
            Degats = 22,
            Vitesse = 1.0,
            Defense = 0.6,
            CoutRC = 4,
            Portee = 450,
        },
    },

    ["bikaku"] = {
        Nom = "Bikaku",
        Description = "Kagune en forme de queue. Polyvalent et équilibré.",
        Rarete = "rare",
        Couleur = Color(50, 200, 100),

        Model = "models/tgrp/kagune/bikaku.mdl",

        Stats = {
            Degats = 16,
            Vitesse = 1.1,
            Defense = 1.1,
            CoutRC = 3.5,
            Portee = 400,
        },
    },

    -- 5ème type à configurer par le client
    -- ["chimere"] = {
    --     Nom = "Chimère",
    --     Description = "Kagune hybride extrêmement rare combinant deux types.",
    --     Rarete = "mythique",
    --     Couleur = Color(255, 200, 0),
    --     Model = "models/tgrp/kagune/chimere.mdl",
    --     Stats = {
    --         Degats = 20,
    --         Vitesse = 1.15,
    --         Defense = 1.2,
    --         CoutRC = 6,
    --         Portee = 500,
    --     },
    -- },
}

-- ============================================================
-- RARETÉS
-- ============================================================

TGRP.Config.Kagune.Raretes = {
    ["commun"]     = { Nom = "Commun",     Couleur = Color(180, 180, 180), Poids = 50 },
    ["rare"]       = { Nom = "Rare",       Couleur = Color(50, 150, 255),  Poids = 30 },
    ["epique"]     = { Nom = "Épique",     Couleur = Color(180, 50, 255),  Poids = 15 },
    ["legendaire"] = { Nom = "Légendaire", Couleur = Color(255, 180, 0),   Poids = 4 },
    ["mythique"]   = { Nom = "Mythique",   Couleur = Color(255, 50, 50),   Poids = 1 },
}

-- ============================================================
-- PROGRESSION (lié au système RC)
-- ============================================================

TGRP.Config.Kagune.Progression = {
    -- Seuils de RC pour débloquer les niveaux de Kagune
    Niveaux = {
        { Niveau = 1, RCRequis = 0,     Nom = "Kagune basique" },
        { Niveau = 2, RCRequis = 500,   Nom = "Kagune renforcé" },
        { Niveau = 3, RCRequis = 1500,  Nom = "Kagune avancé" },
        { Niveau = 4, RCRequis = 3000,  Nom = "Kagune maîtrisé" },
        { Niveau = 5, RCRequis = 5000,  Nom = "Kakuja partiel" },
        { Niveau = 6, RCRequis = 10000, Nom = "Kakuja complet" },
    },
}
