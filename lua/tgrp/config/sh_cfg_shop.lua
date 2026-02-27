--[[
    Tokyo Ghoul RP — Configuration de la Boutique

    Modifiez ce fichier pour ajuster le contenu et les prix de la boutique.
]]

TGRP.Config.Shop = {}

-- ============================================================
-- PARAMÈTRES GÉNÉRAUX
-- ============================================================

TGRP.Config.Shop.General = {
    -- Nom de la monnaie in-game
    NomMonnaie = "Yens",

    -- Icône de la monnaie
    IconeMonnaie = "tgrp/ui/yen.png",

    -- Argent de départ pour un nouveau personnage
    ArgentDepart = 1000,
}

-- ============================================================
-- CATÉGORIES DE LA BOUTIQUE
-- ============================================================

TGRP.Config.Shop.Categories = {
    { ID = "rerolls",      Nom = "Rerolls",       Icone = "tgrp/shop/rerolls.png" },
    { ID = "consommables", Nom = "Consommables",   Icone = "tgrp/shop/consommables.png" },
    { ID = "equipement",   Nom = "Équipement",     Icone = "tgrp/shop/equipement.png" },
    { ID = "cosmetiques",  Nom = "Cosmétiques",    Icone = "tgrp/shop/cosmetiques.png" },
    { ID = "ameliorations", Nom = "Améliorations", Icone = "tgrp/shop/ameliorations.png" },
}

-- ============================================================
-- ARTICLES EN VENTE
-- ============================================================

TGRP.Config.Shop.Articles = {
    -- Rerolls
    {
        ID = "reroll_kagune",
        Categorie = "rerolls",
        Nom = "Reroll Kagune",
        Description = "Permet de relancer le type de votre Kagune.",
        Prix = 5000,
        Icone = "tgrp/shop/reroll_kagune.png",
        FactionAutorisee = { "ghoul" },
        Limite = 0, -- 0 = illimité
    },
    {
        ID = "reroll_quinque",
        Categorie = "rerolls",
        Nom = "Reroll Quinque",
        Description = "Permet de relancer le type de votre Quinque.",
        Prix = 5000,
        Icone = "tgrp/shop/reroll_quinque.png",
        FactionAutorisee = { "ccg" },
        Limite = 0,
    },

    -- Le client ajoute ses articles ici
}
