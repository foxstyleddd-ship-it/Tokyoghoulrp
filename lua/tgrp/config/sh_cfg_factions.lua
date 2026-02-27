--[[
    Tokyo Ghoul RP — Configuration des Factions

    Modifiez ce fichier pour personnaliser les factions.
    Ajoutez vos propres player models, couleurs, et zones de spawn.
]]

TGRP.Config.Factions = {
    -- ============================================================
    -- GHOUL
    -- ============================================================
    ["ghoul"] = {
        Nom = "Ghoul",
        Description = "Un être mi-humain mi-ghoul qui se nourrit de chair humaine.",
        Couleur = Color(200, 30, 30),     -- Rouge
        Icone = "tgrp/factions/ghoul.png", -- Chemin vers l'icône (materials/)

        -- Player models disponibles (le client peut en ajouter ici)
        Models = {
            "models/player/group01/male_01.mdl",
            "models/player/group01/male_02.mdl",
            "models/player/group01/female_01.mdl",
        },

        -- Position de spawn (à adapter selon la map)
        Spawn = {
            Position = Vector(0, 0, 0),
            Angle = Angle(0, 0, 0),
        },

        -- HP de base
        HP = 100,

        -- Peut utiliser le système Kagune
        Kagune = true,

        -- Peut utiliser le système Quinque
        Quinque = false,
    },

    -- ============================================================
    -- CCG (Commission de Contrôle des Ghouls)
    -- ============================================================
    ["ccg"] = {
        Nom = "CCG",
        Description = "Enquêteur de la Commission de Contrôle des Ghouls.",
        Couleur = Color(30, 100, 200),    -- Bleu
        Icone = "tgrp/factions/ccg.png",

        Models = {
            "models/player/group01/male_03.mdl",
            "models/player/group01/male_04.mdl",
            "models/player/group01/female_02.mdl",
        },

        Spawn = {
            Position = Vector(500, 0, 0),
            Angle = Angle(0, 0, 0),
        },

        HP = 100,
        Kagune = false,
        Quinque = true,
    },

    -- ============================================================
    -- CIVIL
    -- ============================================================
    ["civil"] = {
        Nom = "Civil",
        Description = "Un citoyen ordinaire de Tokyo.",
        Couleur = Color(150, 150, 150),   -- Gris
        Icone = "tgrp/factions/civil.png",

        Models = {
            "models/player/group01/male_05.mdl",
            "models/player/group01/male_06.mdl",
            "models/player/group01/female_03.mdl",
        },

        Spawn = {
            Position = Vector(-500, 0, 0),
            Angle = Angle(0, 0, 0),
        },

        HP = 100,
        Kagune = false,
        Quinque = false,
    },
}

-- ============================================================
-- HIÉRARCHIE CCG (Sprint 8)
-- ============================================================

TGRP.Config.HierarchieCCG = {
    { ID = "academie",        Nom = "Académie",           Rang = 1 },
    { ID = "enqueteur_3",     Nom = "Enquêteur Rang 3",   Rang = 2 },
    { ID = "enqueteur_2",     Nom = "Enquêteur Rang 2",   Rang = 3 },
    { ID = "enqueteur_1",     Nom = "Enquêteur Rang 1",   Rang = 4 },
    { ID = "premier_classe",  Nom = "Enquêteur 1ère Classe", Rang = 5 },
    { ID = "classe_speciale", Nom = "Classe Spéciale",    Rang = 6 },
}
