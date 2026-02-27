--[[
    Tokyo Ghoul RP — Module ACC2 Bridge (Serveur)
    Pont d'intégration entre Advanced Character Creator (ACC2) et TGRP.

    Ce fichier :
    - Synchronise les factions TGRP vers ACC2 automatiquement
    - Enregistre une "compatibility" ACC2 pour sauvegarder/charger les données TGRP
    - Gère le cycle de vie des personnages (création, chargement, sauvegarde)
    - Limite le nombre de personnages à 3
    - Bloque le menu de mort ACC2 (TGRP gère la mort autrement)
    - Gère PlayerInitialSpawn, PlayerDisconnected, et l'auto-save
]]

-- ============================================================
-- SYNCHRONISATION DES FACTIONS TGRP → ACC2
-- ============================================================

--- Synchronise les factions TGRP vers ACC2
--- Crée les factions ACC2 si elles n'existent pas, met à jour si elles existent
function TGRP.ACC2Bridge.SyncFactions()
    if not TGRP.ACC2Bridge.EstDisponible() then
        TGRP.LogErreur("ACC2Bridge", "ACC2 n'est pas chargé — impossible de synchroniser les factions")
        return
    end

    TGRP.Log("ACC2Bridge", "Synchronisation des factions TGRP → ACC2...", "info")

    for tgrpId, factionData in pairs(TGRP.Config.Factions) do
        -- Construire la table de models au format ACC2 : { ["models/path.mdl"] = true }
        local acc2Models = {}
        for _, mdl in ipairs(factionData.Models or {}) do
            acc2Models[mdl] = true
        end

        -- Chercher si la faction existe déjà dans ACC2 (par nom)
        local existingId = nil
        for acc2Id, acc2Faction in pairs(ACC2.Factions or {}) do
            if acc2Faction.name == factionData.Nom then
                existingId = acc2Id
                break
            end
        end

        if existingId then
            -- Mettre à jour la faction existante (sync models)
            ACC2.UpdateFaction(nil, existingId, factionData.Nom,
                factionData.Icone or "", factionData.Description or "",
                "", 0, acc2Models, { ["*"] = true }, { ["*"] = true })

            TGRP.ACC2Bridge.FactionMap[existingId] = tgrpId
            TGRP.ACC2Bridge.FactionMapInverse[tgrpId] = existingId
            TGRP.Log("ACC2Bridge", "Faction mise à jour : " .. factionData.Nom .. " (ACC2 ID " .. existingId .. " → TGRP '" .. tgrpId .. "')", "info")
        else
            -- Créer la faction dans ACC2
            ACC2.CreateFaction(nil, factionData.Nom,
                factionData.Icone or "", factionData.Description or "",
                "", 0, acc2Models, { ["*"] = true }, { ["*"] = true })

            TGRP.Log("ACC2Bridge", "Faction créée dans ACC2 : " .. factionData.Nom .. " (TGRP '" .. tgrpId .. "')", "info")
        end
    end

    -- Reconstruire le mapping après un délai (les INSERT ACC2 sont asynchrones)
    timer.Simple(3, function()
        TGRP.ACC2Bridge.ReconstruireMapping()
    end)
end

--- Reconstruit le mapping faction en parcourant ACC2.Factions
function TGRP.ACC2Bridge.ReconstruireMapping()
    TGRP.ACC2Bridge.FactionMap = {}
    TGRP.ACC2Bridge.FactionMapInverse = {}

    for acc2Id, acc2Faction in pairs(ACC2.Factions or {}) do
        for tgrpId, tgrpFaction in pairs(TGRP.Config.Factions) do
            if acc2Faction.name == tgrpFaction.Nom then
                TGRP.ACC2Bridge.FactionMap[acc2Id] = tgrpId
                TGRP.ACC2Bridge.FactionMapInverse[tgrpId] = acc2Id
                break
            end
        end
    end

    local nbMapped = table.Count(TGRP.ACC2Bridge.FactionMap)
    TGRP.Log("ACC2Bridge", "Mapping factions reconstruit : " .. nbMapped .. " faction(s) mappée(s)", "info")

    if nbMapped == 0 then
        TGRP.LogErreur("ACC2Bridge", "ATTENTION : aucune faction mappée ! Vérifiez que les noms correspondent entre TGRP.Config.Factions et ACC2.")
    end
end

-- ============================================================
-- ENREGISTREMENT DE LA COMPATIBILITY ACC2
-- ============================================================

--- Appelé quand ACC2 a fini son initialisation
hook.Add("ACC2:OnCompatibilitiesLoaded", "TGRP:ACC2Bridge:Init", function()
    TGRP.Log("ACC2Bridge", "ACC2 prêt — initialisation du bridge TGRP", "info")

    -- 1. Synchroniser les factions
    TGRP.ACC2Bridge.SyncFactions()

    -- 2. Enregistrer la compatibility TGRP
    -- Les callbacks save retournent nil pour que ACC2 ne stocke PAS nos données
    -- dans acc2_characters_compatibilities (on utilise notre propre table tgrp_personnages)
    ACC2.RegisterCompatibility("TGRP:Gameplay",
        -- Callbacks SAVE
        {
            -- Quand un personnage est créé dans ACC2
            ["ACC2:Character:Created"] = function(ply, characterId, characterArguments, dontLoad, transfered)
                TGRP.ACC2Bridge.OnCharacterCreated(ply, characterId, characterArguments)
                return nil -- Ne pas stocker dans ACC2
            end,

            -- Quand ACC2 sauvegarde un personnage
            ["ACC2:Character:Save"] = function(ply, characterId, characterArguments, dontSend)
                TGRP.ACC2Bridge.OnCharacterSave(ply, characterId)
                return nil -- Ne pas stocker dans ACC2
            end,
        },
        -- Callbacks RESTORE
        {
            -- Quand un personnage est chargé/sélectionné
            ["ACC2:Load:Character"] = function(ply, characterId, oldCharacterId, charactersData)
                TGRP.ACC2Bridge.OnCharacterLoad(ply, characterId, oldCharacterId)
            end,
        },
        TGRP, -- check : la table TGRP existe toujours
        true  -- cannotDisable : on ne peut pas désactiver cette compatibility
    )

    TGRP.Log("ACC2Bridge", "Compatibility TGRP:Gameplay enregistrée avec succès", "info")
end)

-- ============================================================
-- CALLBACKS : CRÉATION DE PERSONNAGE
-- ============================================================

--- Appelé quand ACC2 crée un nouveau personnage
--- Crée la ligne correspondante dans tgrp_personnages
function TGRP.ACC2Bridge.OnCharacterCreated(ply, characterId, characterArguments)
    if not IsValid(ply) or not isnumber(characterId) then return end

    local steamid = ply:SteamID()

    -- Mapper la faction ACC2 vers la faction TGRP
    local acc2FactionId = tonumber(characterArguments["factionId"])
    local tgrpFaction = TGRP.ACC2Bridge.FactionTGRPDepuisACC2(acc2FactionId)

    if not tgrpFaction or not TGRP.Factions.Existe(tgrpFaction) then
        TGRP.Log("ACC2Bridge", "Faction ACC2 ID " .. tostring(acc2FactionId) .. " non mappée, fallback civil", "avertissement")
        tgrpFaction = "civil"
    end

    local hpBase = TGRP.Factions.HP(tgrpFaction)
    local rcDefaut = TGRP.Config.RC and TGRP.Config.RC.Valeurs and TGRP.Config.RC.Valeurs.Depart or 100
    local faimDefaut = TGRP.Config.RC and TGRP.Config.RC.Faim and TGRP.Config.RC.Faim.Depart or 80

    TGRP.DB.Preparer(
        "INSERT INTO tgrp_personnages (steamid, acc2_character_id, faction, hp, rc, faim, inventaire, equipement, cosmetique, hotbar, skills_debloquees) VALUES (?, ?, ?, ?, ?, ?, '[]', '{}', '{}', '[]', '[]')",
        { steamid, characterId, tgrpFaction, hpBase, rcDefaut, faimDefaut },
        function()
            -- Recharger le cache
            TGRP.Persos.Charger(ply)
            TGRP.Log("ACC2Bridge", ply:Nick() .. " a créé un personnage " .. tgrpFaction .. " (ACC2 #" .. characterId .. ")", "info")
            TGRP.DB.LogAction(steamid, "perso_cree", tgrpFaction .. " | ACC2 #" .. characterId)
        end,
        function(err)
            TGRP.LogErreur("ACC2Bridge", "Erreur création perso TGRP pour " .. ply:Nick() .. " : " .. tostring(err))
        end
    )
end

-- ============================================================
-- CALLBACKS : CHARGEMENT DE PERSONNAGE
-- ============================================================

--- Appelé quand ACC2 charge/sélectionne un personnage
--- Charge les données TGRP et les applique au joueur
function TGRP.ACC2Bridge.OnCharacterLoad(ply, characterId, oldCharacterId)
    if not IsValid(ply) or not isnumber(characterId) then return end

    local steamid = ply:SteamID()

    -- Sauvegarder l'ancien personnage si on en switch
    if ply.tgrpPersoActif and oldCharacterId and oldCharacterId ~= characterId then
        ply.tgrpPersoActif.HP = ply:Health()
        TGRP.Persos.Sauvegarder(ply)
    end

    -- Chercher dans le cache d'abord
    local cache = TGRP.Persos.Cache[steamid]
    if cache and cache[characterId] then
        TGRP.ACC2Bridge.AppliquerPerso(ply, cache[characterId])
        return
    end

    -- Fallback : charger depuis la DB
    TGRP.DB.Preparer(
        "SELECT * FROM tgrp_personnages WHERE acc2_character_id = ?",
        { characterId },
        function(donnees)
            if donnees and donnees[1] then
                local perso = TGRP.Persos.RowVersPerso(donnees[1])
                -- Mettre en cache
                TGRP.Persos.Cache[steamid] = TGRP.Persos.Cache[steamid] or {}
                TGRP.Persos.Cache[steamid][characterId] = perso
                TGRP.ACC2Bridge.AppliquerPerso(ply, perso)
            else
                TGRP.Log("ACC2Bridge", "Aucune donnée TGRP pour ACC2 #" .. characterId .. " (" .. ply:Nick() .. ") — personnage probablement en cours de création", "avertissement")
            end
        end,
        function(err)
            TGRP.LogErreur("ACC2Bridge", "Erreur chargement perso TGRP : " .. tostring(err))
        end
    )
end

-- ============================================================
-- APPLICATION DES DONNÉES TGRP SUR LE JOUEUR
-- ============================================================

--- Applique toutes les données TGRP d'un personnage au joueur
--- @param ply Player Le joueur
--- @param perso table Les données du personnage TGRP
function TGRP.ACC2Bridge.AppliquerPerso(ply, perso)
    if not IsValid(ply) or not perso then return end

    -- Stocker le perso actif
    ply.tgrpPersoActif = perso

    -- Appliquer la faction TGRP
    TGRP.Factions.Appliquer(ply, perso.Faction)

    -- NWVars pour le client
    ply:SetNWInt("tgrp_rc", perso.RC)
    ply:SetNWFloat("tgrp_faim", perso.Faim)
    ply:SetNWBool("tgrp_perso_charge", true)

    -- HP et spawn — on attend qu'ACC2 ait fini d'appliquer le model/spawn
    -- ACC2:FinishedLoadingCharacter fire après, donc on utilise un timer
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end

        -- Appliquer les HP selon la faction
        local hpMax = TGRP.Factions.HP(perso.Faction)
        ply:SetMaxHealth(hpMax)
        ply:SetHealth(math.min(perso.HP, hpMax))

        -- Spawn au point de la faction
        local pos, ang = TGRP.Factions.SpawnPoint(perso.Faction)
        if pos and pos ~= Vector(0, 0, 0) then
            ply:SetPos(pos)
            ply:SetEyeAngles(ang)
        end
    end)

    TGRP.Log("ACC2Bridge", ply:Nick() .. " joue : " .. perso.Faction .. " (ACC2 #" .. perso.ACC2CharID .. ", RC=" .. perso.RC .. ")", "info")

    -- Hook pour les autres modules TGRP
    hook.Run("TGRP_PersonnageSelectionne", ply, perso)
end

-- ============================================================
-- CALLBACKS : SAUVEGARDE
-- ============================================================

--- Appelé quand ACC2 sauvegarde un personnage
function TGRP.ACC2Bridge.OnCharacterSave(ply, characterId)
    if not IsValid(ply) or not ply.tgrpPersoActif then return end

    -- Mettre à jour les HP avant sauvegarde
    ply.tgrpPersoActif.HP = ply:Health()

    TGRP.Persos.Sauvegarder(ply)
end

-- ============================================================
-- HOOKS ACC2 : RESTRICTIONS ET VALIDATION
-- ============================================================

--- Limiter le nombre de personnages à 3
hook.Add("ACC2:GetMaxCharacter", "TGRP:MaxCharacters", function(ply, userGroup, maxCharacter)
    return TGRP.Config.General.MaxPersonnages or 3
end)

--- Valider la faction lors de la création de personnage
hook.Add("ACC2:CanCreateCharacter", "TGRP:ValiderFaction", function(ply, currentCharId, name, lastName, age, size, model, bodygroups, factionId)
    -- Vérifier que la faction est bien mappée vers TGRP
    if not factionId or factionId == 0 then
        return false, "Vous devez choisir une faction."
    end

    local tgrpFaction = TGRP.ACC2Bridge.FactionTGRPDepuisACC2(tonumber(factionId))
    if not tgrpFaction then
        return false, "Faction invalide. Contactez un administrateur."
    end
end)

--- Bloquer le menu de mort ACC2 (TGRP gère la mort avec le système ragdoll)
hook.Add("PlayerSpawn", "TGRP:ACC2Bridge:BloquerMenuMort", function(ply)
    if not IsValid(ply) then return end

    -- Empêcher ACC2 d'ouvrir son menu de sélection au respawn
    timer.Simple(0, function()
        if not IsValid(ply) then return end
        if ply.ACC2 then
            ply.ACC2["isDeath"] = nil
        end
    end)
end)

--- Override HP après qu'ACC2 ait fini de charger
--- (au cas où loadHealth serait activé par erreur dans ACC2)
hook.Add("ACC2:FinishedLoadingCharacter", "TGRP:OverrideHP", function(ply, data)
    if not IsValid(ply) or not ply.tgrpPersoActif then return end

    local perso = ply.tgrpPersoActif
    local hpMax = TGRP.Factions.HP(perso.Faction)
    ply:SetMaxHealth(hpMax)
    ply:SetHealth(math.min(perso.HP, hpMax))
end)

-- ============================================================
-- HOOKS LIFECYCLE : CONNEXION, DÉCONNEXION, AUTO-SAVE
-- ============================================================

--- Quand un joueur se connecte : enregistrer dans la DB et charger le cache
hook.Add("PlayerInitialSpawn", "TGRP:ACC2Bridge:InitJoueur", function(ply)
    timer.Simple(1, function()
        if not IsValid(ply) then return end

        TGRP.Persos.EnregistrerJoueur(ply)
        TGRP.Persos.Charger(ply, function(persos)
            local nbPersos = table.Count(persos)
            TGRP.Log("ACC2Bridge", ply:Nick() .. " connecté — " .. nbPersos .. " personnage(s) TGRP en cache", "info")
        end)
    end)
end)

--- Quand un joueur se déconnecte : sauvegarder et nettoyer
hook.Add("PlayerDisconnected", "TGRP:ACC2Bridge:DecoJoueur", function(ply)
    if ply.tgrpPersoActif then
        ply.tgrpPersoActif.HP = ply:Health()
        TGRP.Persos.Sauvegarder(ply)
        TGRP.Log("ACC2Bridge", ply:Nick() .. " déconnecté — personnage sauvegardé", "info")
    end

    -- Nettoyer le cache
    local steamid = ply:SteamID()
    if steamid then
        TGRP.Persos.Cache[steamid] = nil
    end
end)

--- Auto-sauvegarde périodique (filet de sécurité)
timer.Create("TGRP_AutoSave", TGRP.Config.General.IntervalSauvegarde or 60, 0, function()
    TGRP.Persos.SauvegarderTous()
end)

TGRP.Log("ACC2Bridge", "Module ACC2 Bridge chargé (en attente d'ACC2...)", "info")
