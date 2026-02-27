--[[
    Tokyo Ghoul RP — UI : Menu de Sélection / Création de Personnage
    Menu principal affiché à la connexion si le joueur n'a pas de perso actif.

    NOTE : Ce menu utilise VGUI standard pour le Sprint 1.
    Il sera migré vers PixelUI au Sprint 7 pour un look Tokyo Ghoul.
]]

local PANEL = {}

-- Couleurs du thème Tokyo Ghoul
local COULEURS = {
    Fond        = Color(15, 15, 20, 250),
    FondPanel   = Color(25, 25, 35, 255),
    FondSlot    = Color(35, 35, 50, 255),
    FondSlotHover = Color(50, 50, 70, 255),
    Accent      = Color(200, 30, 30),        -- Rouge ghoul
    AccentCCG   = Color(30, 100, 200),       -- Bleu CCG
    AccentCivil = Color(150, 150, 150),      -- Gris civil
    Texte       = Color(220, 220, 220),
    TexteSombre = Color(120, 120, 120),
    Bordure     = Color(60, 60, 80),
    Succes      = Color(50, 200, 80),
    Erreur      = Color(200, 50, 50),
}

-- ============================================================
-- MENU PRINCIPAL : SÉLECTION DE PERSONNAGE
-- ============================================================

function TGRP.OuvrirMenuPersos()
    -- Fermer si déjà ouvert
    if IsValid(TGRP.MenuPerso) then
        TGRP.MenuPerso:Remove()
    end

    local largeur, hauteur = 800, 520
    local frame = vgui.Create("DFrame")
    frame:SetSize(largeur, hauteur)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COULEURS.Fond)
        draw.RoundedBox(8, 0, 0, w, 48, COULEURS.FondPanel)
        draw.SimpleText("TOKYO GHOUL RP", "DermaLarge", w / 2, 24, COULEURS.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COULEURS.Accent)
        surface.DrawRect(0, 47, w, 2)
    end

    TGRP.MenuPerso = frame

    -- Sous-titre
    local sousTitre = vgui.Create("DLabel", frame)
    sousTitre:SetPos(0, 55)
    sousTitre:SetSize(largeur, 25)
    sousTitre:SetText("Sélectionnez un personnage ou créez-en un nouveau")
    sousTitre:SetFont("DermaDefaultBold")
    sousTitre:SetTextColor(COULEURS.TexteSombre)
    sousTitre:SetContentAlignment(5) -- Centre

    -- Conteneur des slots
    local conteneurSlots = vgui.Create("DPanel", frame)
    conteneurSlots:SetPos(20, 90)
    conteneurSlots:SetSize(largeur - 40, 370)
    conteneurSlots.Paint = function() end

    -- Créer les slots
    local maxSlots = TGRP.Config.General.MaxPersonnages or 3
    local slotLargeur = math.floor((largeur - 40 - (maxSlots - 1) * 15) / maxSlots)
    local persos = TGRP.Persos.MesPersos or {}

    for i = 1, maxSlots do
        local perso = nil
        -- Chercher le perso pour ce slot (les clés peuvent être des strings après JSON)
        for k, v in pairs(persos) do
            if tonumber(v.Slot) == i or tonumber(k) == i then
                perso = v
                break
            end
        end

        local x = (i - 1) * (slotLargeur + 15)
        local slotPanel = vgui.Create("DButton", conteneurSlots)
        slotPanel:SetPos(x, 0)
        slotPanel:SetSize(slotLargeur, 370)
        slotPanel:SetText("")

        if perso then
            -- Slot occupé
            local factionCouleur = TGRP.Factions.Couleur(perso.Faction)

            slotPanel.Paint = function(self, w, h)
                local bgColor = self:IsHovered() and COULEURS.FondSlotHover or COULEURS.FondSlot
                draw.RoundedBox(6, 0, 0, w, h, bgColor)

                -- Barre de faction en haut
                draw.RoundedBoxEx(6, 0, 0, w, 4, factionCouleur, true, true, false, false)

                -- Nom du personnage
                draw.SimpleText(perso.Nom, "DermaLarge", w / 2, 180, COULEURS.Texte, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Faction
                draw.SimpleText(TGRP.Factions.Nom(perso.Faction), "DermaDefaultBold", w / 2, 210, factionCouleur, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Stats
                local y = 240
                draw.SimpleText("HP: " .. (perso.HP or 100), "DermaDefault", w / 2, y, COULEURS.TexteSombre, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("RC: " .. (perso.RC or 100), "DermaDefault", w / 2, y + 20, COULEURS.TexteSombre, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Bordure slot
                surface.SetDrawColor(COULEURS.Bordure)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                -- Texte "Jouer"
                draw.SimpleText("▶ Jouer", "DermaDefaultBold", w / 2, h - 40, COULEURS.Succes, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            slotPanel.DoClick = function()
                local slot = tonumber(perso.Slot)
                TGRP.Persos.DemanderSelection(slot)
                frame:Remove()
            end

            slotPanel.DoRightClick = function()
                local menu = DermaMenu()
                menu:AddOption("Jouer", function()
                    TGRP.Persos.DemanderSelection(tonumber(perso.Slot))
                    frame:Remove()
                end):SetIcon("icon16/controller.png")

                menu:AddSpacer()

                menu:AddOption("Supprimer", function()
                    Derma_Query(
                        "Voulez-vous vraiment supprimer " .. perso.Nom .. " ? Cette action est irréversible.",
                        "Supprimer le personnage",
                        "Supprimer", function()
                            TGRP.Persos.DemanderSuppression(tonumber(perso.Slot))
                        end,
                        "Annuler", function() end
                    )
                end):SetIcon("icon16/cross.png")

                menu:Open()
            end

            -- Model preview (spawn icon comme preview basique)
            local modelPreview = vgui.Create("DModelPanel", slotPanel)
            modelPreview:SetPos(10, 15)
            modelPreview:SetSize(slotLargeur - 20, 150)
            modelPreview:SetModel(perso.Model or "models/player/group01/male_01.mdl")
            modelPreview:SetFOV(50)
            modelPreview:SetMouseInputEnabled(false)

            local mn = modelPreview.Entity:GetSequence()
            modelPreview.Entity:SetSequence(modelPreview.Entity:LookupSequence("idle_all_01") or mn)

            function modelPreview:LayoutEntity(ent)
                ent:SetAngles(Angle(0, RealTime() * 30, 0))
            end
        else
            -- Slot vide — bouton de création
            slotPanel.Paint = function(self, w, h)
                local bgColor = self:IsHovered() and COULEURS.FondSlotHover or COULEURS.FondSlot
                draw.RoundedBox(6, 0, 0, w, h, bgColor)

                draw.SimpleText("+", "DermaLarge", w / 2, h / 2 - 20, COULEURS.TexteSombre, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Créer un personnage", "DermaDefault", w / 2, h / 2 + 20, COULEURS.TexteSombre, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                draw.SimpleText("Slot " .. i, "DermaDefault", w / 2, h / 2 + 40, Color(80, 80, 80), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(COULEURS.Bordure)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end

            slotPanel.DoClick = function()
                frame:Remove()
                TGRP.OuvrirMenuCreation()
            end
        end
    end

    -- Bouton fermer (seulement si le joueur a déjà un perso actif)
    if LocalPlayer():GetNWBool("tgrp_perso_charge", false) then
        local btnFermer = vgui.Create("DButton", frame)
        btnFermer:SetPos(largeur - 50, 8)
        btnFermer:SetSize(32, 32)
        btnFermer:SetText("✕")
        btnFermer:SetFont("DermaDefaultBold")
        btnFermer:SetTextColor(COULEURS.TexteSombre)
        btnFermer.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(200, 50, 50, 30))
            end
        end
        btnFermer.DoClick = function()
            frame:Remove()
        end
    end
end

-- ============================================================
-- MENU DE CRÉATION DE PERSONNAGE
-- ============================================================

function TGRP.OuvrirMenuCreation()
    if IsValid(TGRP.MenuCreation) then
        TGRP.MenuCreation:Remove()
    end

    local largeur, hauteur = 700, 550
    local frame = vgui.Create("DFrame")
    frame:SetSize(largeur, hauteur)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COULEURS.Fond)
        draw.RoundedBox(8, 0, 0, w, 48, COULEURS.FondPanel)
        draw.SimpleText("CRÉER UN PERSONNAGE", "DermaLarge", w / 2, 24, COULEURS.Accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COULEURS.Accent)
        surface.DrawRect(0, 47, w, 2)
    end

    TGRP.MenuCreation = frame

    -- Variables de sélection
    local selFaction = nil
    local selModel = nil
    local selNom = ""

    -- ===== PARTIE GAUCHE : Formulaire =====
    local panelGauche = vgui.Create("DPanel", frame)
    panelGauche:SetPos(20, 60)
    panelGauche:SetSize(350, 430)
    panelGauche.Paint = function() end

    -- Label Nom
    local lblNom = vgui.Create("DLabel", panelGauche)
    lblNom:SetPos(0, 10)
    lblNom:SetSize(350, 20)
    lblNom:SetText("NOM DU PERSONNAGE")
    lblNom:SetFont("DermaDefaultBold")
    lblNom:SetTextColor(COULEURS.Texte)

    -- Input Nom
    local inputNom = vgui.Create("DTextEntry", panelGauche)
    inputNom:SetPos(0, 35)
    inputNom:SetSize(350, 35)
    inputNom:SetPlaceholderText("Entrez un nom (3-32 caractères)")
    inputNom:SetFont("DermaDefault")
    inputNom.OnChange = function(self)
        selNom = self:GetValue()
    end
    inputNom.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COULEURS.FondSlot)
        surface.SetDrawColor(self:HasFocus() and COULEURS.Accent or COULEURS.Bordure)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(COULEURS.Texte, COULEURS.Accent, COULEURS.Texte)
    end

    -- Label Faction
    local lblFaction = vgui.Create("DLabel", panelGauche)
    lblFaction:SetPos(0, 85)
    lblFaction:SetSize(350, 20)
    lblFaction:SetText("FACTION")
    lblFaction:SetFont("DermaDefaultBold")
    lblFaction:SetTextColor(COULEURS.Texte)

    -- Model preview panel (à droite)
    local panelDroit = vgui.Create("DPanel", frame)
    panelDroit:SetPos(390, 60)
    panelDroit:SetSize(290, 380)
    panelDroit.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COULEURS.FondSlot)
        surface.SetDrawColor(COULEURS.Bordure)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local modelPreview = vgui.Create("DModelPanel", panelDroit)
    modelPreview:SetPos(5, 5)
    modelPreview:SetSize(280, 370)
    modelPreview:SetModel("models/player/group01/male_01.mdl")
    modelPreview:SetFOV(50)
    function modelPreview:LayoutEntity(ent)
        ent:SetAngles(Angle(0, RealTime() * 30, 0))
    end

    -- Description faction (sous le model preview)
    local lblDescription = vgui.Create("DLabel", frame)
    lblDescription:SetPos(390, 445)
    lblDescription:SetSize(290, 40)
    lblDescription:SetText("")
    lblDescription:SetFont("DermaDefault")
    lblDescription:SetTextColor(COULEURS.TexteSombre)
    lblDescription:SetWrap(true)

    -- Panel models
    local lblModel = vgui.Create("DLabel", panelGauche)
    lblModel:SetPos(0, 210)
    lblModel:SetSize(350, 20)
    lblModel:SetText("APPARENCE")
    lblModel:SetFont("DermaDefaultBold")
    lblModel:SetTextColor(COULEURS.Texte)

    local scrollModels = vgui.Create("DScrollPanel", panelGauche)
    scrollModels:SetPos(0, 235)
    scrollModels:SetSize(350, 150)

    local panelModels = vgui.Create("DIconLayout", scrollModels)
    panelModels:SetPos(0, 0)
    panelModels:SetSize(350, 150)
    panelModels:SetSpaceX(8)
    panelModels:SetSpaceY(8)

    -- Fonction pour rafraîchir les models quand une faction est sélectionnée
    local modelButtons = {}
    local function rafraichirModels(factionID)
        panelModels:Clear()
        modelButtons = {}
        selModel = nil

        local models = TGRP.Factions.Models(factionID)
        for _, mdl in ipairs(models) do
            local btn = panelModels:Add("DButton")
            btn:SetSize(105, 130)
            btn:SetText("")

            local mdlPanel = vgui.Create("DModelPanel", btn)
            mdlPanel:SetPos(2, 2)
            mdlPanel:SetSize(101, 100)
            mdlPanel:SetModel(mdl)
            mdlPanel:SetFOV(50)
            mdlPanel:SetMouseInputEnabled(false)
            function mdlPanel:LayoutEntity(ent)
                ent:SetAngles(Angle(0, RealTime() * 20, 0))
            end

            btn.ModelPath = mdl
            btn.Selected = false

            btn.Paint = function(self, w, h)
                local bg = self.Selected and COULEURS.Accent or (self:IsHovered() and COULEURS.FondSlotHover or COULEURS.FondSlot)
                draw.RoundedBox(4, 0, 0, w, h, bg)
                surface.SetDrawColor(self.Selected and COULEURS.Accent or COULEURS.Bordure)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                -- Nom court du model
                local nomCourt = string.match(mdl, "([^/]+)%.mdl$") or "model"
                draw.SimpleText(nomCourt, "DermaDefault", w / 2, h - 12, COULEURS.Texte, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            btn.DoClick = function()
                for _, b in ipairs(modelButtons) do
                    b.Selected = false
                end
                btn.Selected = true
                selModel = mdl
                modelPreview:SetModel(mdl)
            end

            table.insert(modelButtons, btn)
        end

        -- Sélectionner le premier model par défaut
        if #models > 0 then
            selModel = models[1]
            modelPreview:SetModel(models[1])
            if modelButtons[1] then
                modelButtons[1].Selected = true
            end
        end
    end

    -- Boutons de faction
    local factionIDs = TGRP.Factions.ListeIDs()
    local factionBoutons = {}
    local btnLargeur = math.floor((350 - (#factionIDs - 1) * 10) / #factionIDs)

    for idx, factionID in ipairs(factionIDs) do
        local factionData = TGRP.Factions.Get(factionID)
        local x = (idx - 1) * (btnLargeur + 10)

        local btn = vgui.Create("DButton", panelGauche)
        btn:SetPos(x, 110)
        btn:SetSize(btnLargeur, 80)
        btn:SetText("")
        btn.FactionID = factionID
        btn.Selected = false

        btn.Paint = function(self, w, h)
            local bg = self.Selected and ColorAlpha(factionData.Couleur, 40) or (self:IsHovered() and COULEURS.FondSlotHover or COULEURS.FondSlot)
            draw.RoundedBox(6, 0, 0, w, h, bg)

            local borderColor = self.Selected and factionData.Couleur or COULEURS.Bordure
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, self.Selected and 2 or 1)

            draw.SimpleText(factionData.Nom, "DermaDefaultBold", w / 2, h / 2 - 8, self.Selected and factionData.Couleur or COULEURS.Texte, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local typePerso = ""
            if factionData.Kagune then typePerso = "Kagune"
            elseif factionData.Quinque then typePerso = "Quinque"
            else typePerso = "Neutre" end
            draw.SimpleText(typePerso, "DermaDefault", w / 2, h / 2 + 12, COULEURS.TexteSombre, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        btn.DoClick = function()
            for _, b in ipairs(factionBoutons) do
                b.Selected = false
            end
            btn.Selected = true
            selFaction = factionID
            rafraichirModels(factionID)
            lblDescription:SetText(factionData.Description)
        end

        table.insert(factionBoutons, btn)
    end

    -- ===== BOUTONS DU BAS =====

    -- Bouton Retour
    local btnRetour = vgui.Create("DButton", frame)
    btnRetour:SetPos(20, hauteur - 55)
    btnRetour:SetSize(120, 40)
    btnRetour:SetText("◀ Retour")
    btnRetour:SetFont("DermaDefaultBold")
    btnRetour:SetTextColor(COULEURS.Texte)
    btnRetour.Paint = function(self, w, h)
        local bg = self:IsHovered() and COULEURS.FondSlotHover or COULEURS.FondSlot
        draw.RoundedBox(6, 0, 0, w, h, bg)
    end
    btnRetour.DoClick = function()
        frame:Remove()
        TGRP.OuvrirMenuPersos()
    end

    -- Label erreur
    local lblErreur = vgui.Create("DLabel", frame)
    lblErreur:SetPos(160, hauteur - 55)
    lblErreur:SetSize(350, 40)
    lblErreur:SetText("")
    lblErreur:SetFont("DermaDefault")
    lblErreur:SetTextColor(COULEURS.Erreur)
    lblErreur:SetContentAlignment(5)

    -- Bouton Créer
    local btnCreer = vgui.Create("DButton", frame)
    btnCreer:SetPos(largeur - 180, hauteur - 55)
    btnCreer:SetSize(160, 40)
    btnCreer:SetText("Créer ▶")
    btnCreer:SetFont("DermaDefaultBold")
    btnCreer:SetTextColor(Color(255, 255, 255))
    btnCreer.Paint = function(self, w, h)
        local bg = self:IsHovered() and Color(180, 20, 20) or COULEURS.Accent
        draw.RoundedBox(6, 0, 0, w, h, bg)
    end
    btnCreer.DoClick = function()
        -- Validation côté client
        if not selFaction then
            lblErreur:SetText("Choisissez une faction !")
            return
        end
        if not selModel then
            lblErreur:SetText("Choisissez un model !")
            return
        end
        if #selNom < 3 then
            lblErreur:SetText("Le nom doit faire au moins 3 caractères.")
            return
        end
        if #selNom > 32 then
            lblErreur:SetText("Le nom ne peut pas dépasser 32 caractères.")
            return
        end
        if string.match(selNom, "[^%w%s%-']") then
            lblErreur:SetText("Caractères interdits dans le nom.")
            return
        end

        -- Envoyer au serveur
        TGRP.Persos.DemanderCreation(selNom, selFaction, selModel)
        frame:Remove()
    end
end

-- ============================================================
-- HOOKS
-- ============================================================

-- Ouvrir le menu quand le serveur le demande
hook.Add("TGRP_OuvrirMenuPersos", "TGRP_OuvrirMenuPersos", function()
    TGRP.OuvrirMenuPersos()
end)

-- Quand la liste des persos est mise à jour et le menu est ouvert, le rafraîchir
hook.Add("TGRP_PersosReçus", "TGRP_RafraichirMenuPersos", function(persos)
    if IsValid(TGRP.MenuPerso) then
        TGRP.MenuPerso:Remove()
        TGRP.OuvrirMenuPersos()
    end
end)

-- Commande console pour ouvrir le menu
concommand.Add("tgrp_perso", function()
    net.Start(TGRP.Net.Nom("perso_ouvrir_menu"))
    net.SendToServer()
end)
