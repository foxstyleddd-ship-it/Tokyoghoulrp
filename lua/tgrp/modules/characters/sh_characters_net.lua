--[[
    Tokyo Ghoul RP — Module Personnages : Networking
    Messages réseau pour la synchronisation des données TGRP au client.
    La création, sélection, et suppression de personnages sont gérées par ACC2.
]]

-- ============================================================
-- ENREGISTREMENT DES MESSAGES RÉSEAU
-- ============================================================

TGRP.Net.Enregistrer("perso_liste", 2048) -- Serveur → Client : données TGRP des persos

-- ============================================================
-- SERVEUR : Envoi des données TGRP au client
-- ============================================================

if SERVER then

    --- Envoie les données TGRP des personnages au client
    --- (faction, RC, faim, kagune/quinque — pas le nom/model, ACC2 gère ça)
    --- @param ply Player Le joueur
    function TGRP.Persos.EnvoyerListe(ply)
        if not IsValid(ply) then return end

        local steamid = ply:SteamID()
        local persos = TGRP.Persos.Cache[steamid] or {}

        -- Construire la liste des données TGRP pour le client
        local liste = {}
        for acc2CharId, perso in pairs(persos) do
            liste[acc2CharId] = {
                ACC2CharID = perso.ACC2CharID,
                Faction = perso.Faction,
                RC = perso.RC,
                HP = perso.HP,
                Faim = perso.Faim,
                RangCCG = perso.RangCCG,
                KaguneType = perso.KaguneType,
                QuinqueType = perso.QuinqueType,
                RerollUtilise = perso.RerollUtilise,
            }
        end

        net.Start(TGRP.Net.Nom("perso_liste"))
        TGRP.Net.WriteTableCompresse(liste)
        net.Send(ply)
    end

end

-- ============================================================
-- CLIENT : Réception des données TGRP
-- ============================================================

if CLIENT then

    -- Cache client des données TGRP
    TGRP.Persos = TGRP.Persos or {}
    TGRP.Persos.MesPersos = {}

    -- Réception de la liste des données TGRP
    net.Receive(TGRP.Net.Nom("perso_liste"), function()
        TGRP.Persos.MesPersos = TGRP.Net.ReadTableCompresse()
        TGRP.LogDebug("Personnages", "Données TGRP reçues : " .. table.Count(TGRP.Persos.MesPersos) .. " perso(s)")

        -- Hook pour mettre à jour l'UI si nécessaire
        hook.Run("TGRP_PersosRecus", TGRP.Persos.MesPersos)
    end)

end
