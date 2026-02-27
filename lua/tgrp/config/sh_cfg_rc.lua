--[[
    Tokyo Ghoul RP — Configuration du Système RC & Faim

    Modifiez ce fichier pour ajuster les valeurs de RC et de faim.
]]

TGRP.Config.RC = {}

-- ============================================================
-- VALEURS RC
-- ============================================================

TGRP.Config.RC.Valeurs = {
    -- RC de départ pour une nouvelle ghoul
    RCDepart = 100,

    -- RC maximum possible
    RCMax = 15000,

    -- RC gagné en mangeant un cadavre de joueur
    GainCadavreJoueur = 50,

    -- RC gagné en mangeant un cadavre de PNJ
    GainCadavrePNJ = 20,

    -- Le RC est une valeur PERMANENTE et CUMULATIVE
    -- Il ne diminue JAMAIS — il ne fait que monter
}

-- ============================================================
-- RANGS GHOUL (basés sur la valeur RC)
-- ============================================================

TGRP.Config.RC.Rangs = {
    { ID = "E",  Nom = "Rang E",  RCMin = 0,     RCMax = 199 },
    { ID = "D",  Nom = "Rang D",  RCMin = 200,   RCMax = 799 },
    { ID = "C",  Nom = "Rang C",  RCMin = 800,   RCMax = 1999 },
    { ID = "B",  Nom = "Rang B",  RCMin = 2000,  RCMax = 3999 },
    { ID = "A",  Nom = "Rang A",  RCMin = 4000,  RCMax = 6999 },
    { ID = "S",  Nom = "Rang S",  RCMin = 7000,  RCMax = 9999 },
    { ID = "SS", Nom = "Rang SS", RCMin = 10000, RCMax = 15000 },
}

-- ============================================================
-- SYSTÈME DE FAIM
-- ============================================================

TGRP.Config.RC.Faim = {
    -- Faim maximale (100 = rassasié, 0 = affamé)
    FaimMax = 100,

    -- Faim de départ
    FaimDepart = 80,

    -- Perte de faim par intervalle (voir Config.Performance.IntervalFaim)
    PerteFaimParIntervalle = 2,

    -- Faim restaurée en mangeant un cadavre
    GainFaimCadavre = 40,

    -- Seuils et effets de la faim
    Seuils = {
        { Faim = 50, Effet = "vitesse_reduite",    Multiplicateur = 0.9 },
        { Faim = 25, Effet = "degats_reduits",      Multiplicateur = 0.7 },
        { Faim = 10, Effet = "perte_hp",             DegatsParIntervalle = 2 },
        { Faim = 0,  Effet = "perte_hp_critique",    DegatsParIntervalle = 5 },
    },
}

-- ============================================================
-- SYSTÈME DE RISQUE / DÉTECTION
-- ============================================================

TGRP.Config.RC.Risque = {
    -- Le niveau de risque augmente avec le RC
    -- Plus le risque est élevé, plus le CCG peut détecter la ghoul
    Niveaux = {
        { RCMin = 0,    Risque = 0,  Nom = "Invisible" },
        { RCMin = 1000, Risque = 10, Nom = "Suspect" },
        { RCMin = 3000, Risque = 25, Nom = "Recherché" },
        { RCMin = 5000, Risque = 50, Nom = "Dangereux" },
        { RCMin = 8000, Risque = 75, Nom = "Très dangereux" },
        { RCMin = 10000, Risque = 100, Nom = "Menace critique" },
    },

    -- Distance de détection par le CCG (unités Source) selon le risque
    DistanceDetection = {
        [0]   = 0,
        [10]  = 500,
        [25]  = 1000,
        [50]  = 2000,
        [75]  = 3000,
        [100] = 4096,
    },
}
