--[[
    Tokyo Ghoul RP — Configuration des Items & Équipement

    Modifiez ce fichier pour ajouter des items, équipements et cosmétiques.
    Pour ajouter un item :
    1. Ajoutez une entrée dans la table correspondante
    2. Placez les modèles/icônes dans les dossiers appropriés
]]

TGRP.Config.Items = {}

-- ============================================================
-- TYPES D'ITEMS
-- ============================================================

TGRP.Config.Items.Types = {
    "consommable",   -- Items utilisables (nourriture, potions, etc.)
    "equipement",    -- Pièces d'équipement avec stats
    "cosmetique",    -- Items visuels sans stats
    "materiau",      -- Matériaux de craft (poches RC, etc.)
    "divers",        -- Autres items
}

-- ============================================================
-- SLOTS D'ÉQUIPEMENT
-- ============================================================

TGRP.Config.Items.SlotsEquipement = {
    { ID = "tete",     Nom = "Tête",     Icone = "tgrp/slots/tete.png" },
    { ID = "torse",    Nom = "Torse",    Icone = "tgrp/slots/torse.png" },
    { ID = "jambes",   Nom = "Jambes",   Icone = "tgrp/slots/jambes.png" },
    { ID = "pieds",    Nom = "Pieds",    Icone = "tgrp/slots/pieds.png" },
    { ID = "accessoire", Nom = "Accessoire", Icone = "tgrp/slots/accessoire.png" },
}

-- ============================================================
-- SLOTS COSMÉTIQUES
-- ============================================================

TGRP.Config.Items.SlotsCosmetique = {
    { ID = "masque",    Nom = "Masque",    Icone = "tgrp/slots/masque.png" },
    { ID = "cape",      Nom = "Cape",      Icone = "tgrp/slots/cape.png" },
    { ID = "aura",      Nom = "Aura",      Icone = "tgrp/slots/aura.png" },
    { ID = "accessoire_cos", Nom = "Accessoire", Icone = "tgrp/slots/accessoire_cos.png" },
}

-- ============================================================
-- INVENTAIRE
-- ============================================================

TGRP.Config.Items.Inventaire = {
    -- Nombre de slots d'inventaire par défaut
    SlotsDefaut = 20,

    -- Nombre maximum de slots (avec améliorations)
    SlotsMax = 40,

    -- Les items sont-ils empilables par défaut ?
    EmpilableParDefaut = true,

    -- Taille de pile maximum par défaut
    PileMax = 64,
}

-- ============================================================
-- ITEMS DE BASE (exemples)
-- ============================================================

TGRP.Config.Items.Liste = {
    -- Matériaux
    ["poche_rc"] = {
        Nom = "Poche RC",
        Description = "Une poche RC extraite d'une ghoul. Utilisable pour forger une Quinque.",
        Type = "materiau",
        Icone = "tgrp/items/poche_rc.png",
        Empilable = true,
        PileMax = 10,
        Rarete = "rare",
    },

    -- Consommables
    ["nourriture_humaine"] = {
        Nom = "Nourriture humaine",
        Description = "De la nourriture pour humains. Inutile pour les ghouls.",
        Type = "consommable",
        Icone = "tgrp/items/nourriture.png",
        Empilable = true,
        PileMax = 20,
        Rarete = "commun",
        Effet = {
            FactionAutorisee = { "ccg", "civil" },
            Soin = 10,
        },
    },

    -- Les items d'équipement et cosmétiques sont ajoutés par le client ici
}
