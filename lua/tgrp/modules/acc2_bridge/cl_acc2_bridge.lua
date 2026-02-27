--[[
    Tokyo Ghoul RP — Module ACC2 Bridge (Client)
    Commande console pour ouvrir le menu ACC2 et hooks client.
]]

-- ============================================================
-- COMMANDE CONSOLE : OUVRIR LE MENU ACC2
-- ============================================================

--- Commande pour ouvrir le menu de personnages (redirige vers ACC2)
concommand.Add("tgrp_perso", function()
    if not TGRP.ACC2Bridge.EstDisponible() then
        TGRP.Log("ACC2Bridge", "ACC2 n'est pas disponible", "erreur")
        return
    end

    -- ACC2 ouvre le menu via une touche configurée ou un NPC
    -- On simule l'ouverture via le net message ACC2
    if ACC2.GetSetting and ACC2.GetSetting("canOpenMenuWithKey", "boolean") then
        net.Start("ACC2:Character")
        net.WriteUInt(5, 4) -- uInt 5 = ouvrir menu via touche
        net.SendToServer()
    end
end)

-- ============================================================
-- HOOKS CLIENT
-- ============================================================

--- Quand les données TGRP du perso sont mises à jour via NWVars
--- Permet aux autres modules client de réagir
hook.Add("Think", "TGRP:ACC2Bridge:SyncNW", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- Vérifier si le perso est chargé (flag serveur)
    local persoCharge = ply:GetNWBool("tgrp_perso_charge", false)
    if not persoCharge then return end

    -- Mettre à jour les données locales depuis les NWVars
    TGRP.ACC2Bridge.DonneesLocales = TGRP.ACC2Bridge.DonneesLocales or {}
    TGRP.ACC2Bridge.DonneesLocales.Faction = ply:GetNWString("tgrp_faction", "")
    TGRP.ACC2Bridge.DonneesLocales.RC = ply:GetNWInt("tgrp_rc", 0)
    TGRP.ACC2Bridge.DonneesLocales.Faim = ply:GetNWFloat("tgrp_faim", 0)
end)
