# Serveur Tokyo Ghoul RP — Garry's Mod
## Document de Contexte Projet

---

## 1. Vue d'ensemble

Serveur Garry's Mod Tokyo Ghoul RP conçu pour **120 joueurs simultanés**.
Développement complet côté code ; le client (propriétaire du serveur) n'aura qu'à ajouter ses propres ressources (animations, player models, sons) via des **fichiers de configuration simples** sans toucher au code core.

- **Base de données** : MySQL via mysqloo (performance)
- **UI/HUD** : HTML/CSS via le framework PixelUI
- **Framework** : From scratch (aucun framework RP existant ne couvre les systèmes de compétences/combat nécessaires)
- **Structure** : Addon unique modulaire (`garrysmod/addons/tokyo-ghoul-rp/`)
- **Langue du code** : Français (commentaires, docs, noms de config)
- **Character Creator** : Basé sur Advanced Character Creator (GmodStore) — modifiable (Lua source fourni)

---

## 2. Parcours Joueur

### 2.1 Connexion & Sélection de personnage
- Le joueur arrive sur un écran de **sélection de personnage** avec **3 slots**
- Clic sur un slot vide → lancement de la **création de personnage**
- Clic sur un personnage existant → spawn dans la zone de sa faction

### 2.2 Création de personnage
- Basé sur l'addon **Advanced Character Creator** (GmodStore, modifiable)
- Customisation visuelle du personnage
- **Choix de faction** obligatoire : Ghoul / CCG / Civil

### 2.3 Spawn
- Chaque faction a sa **zone de spawn dédiée** sur la map

---

## 3. Factions

### 3.1 Ghoul
- **Classe** : Kagune
- **Sous-classes** : Rinkaku, Ukaku, Koukaku, Bikaku (+ 1 à définir par le client)
- **Énergie** : Cellules RC (monte en mangeant des cadavres)
- **Rang** : Déterminé par la valeur RC
- **Système de faim** : Les ghouls doivent se nourrir
- **Risque** : Plus le RC est élevé, plus le CCG peut repérer la ghoul

### 3.2 CCG (Commission de Contrôle des Ghouls)
- **Classe** : Quinque
- **Sous-classes** : 5 types (à configurer, basés sur les types de Kagune récupérés)
- **Activation** : Via mallette
- **Durabilité** : Les Quinques s'usent avec l'utilisation
- **Craft** : Création de Quinque à partir de poches RC extraites de cadavres de ghouls
- **Hiérarchie** : Académie → Enquêteur → Classe spéciale

### 3.3 Civil
- Faction neutre / RP pur
- Possibilités à définir par le client (peut-il rejoindre une faction plus tard ?)

---

## 4. Systèmes de Jeu

### 4.1 Système de Reroll / Lootbox
- À la première ouverture du menu compétences, le joueur doit reroll son Kagune/Quinque
- **Animation** : Défilement horizontal des possibilités, s'arrête sur le résultat
- **Raretés** : Système de raretés par sous-classe (à configurer)
- **Rerolls** : 1 gratuit au départ, achat de rerolls supplémentaires en boutique

### 4.2 Skill Tree & Compétences
- Chaque Kagune/Quinque vient avec **x techniques de rangs différents**
- Le joueur peut utiliser une compétence **si son rang est suffisant**
- Les compétences sont organisées dans un **arbre de compétences** (skill tree)
- Le joueur glisse les compétences débloquées dans une **hotbar** [touches 1 à 4]
- Les compétences sont utilisables en combat via les raccourcis de la hotbar

### 4.3 Système de Combat
- **Coups basiques** : Attaques de mêlée/corps à corps
- **Compétences** : Utilisées depuis la hotbar [1-4]
- **Équilibrage** : Ghoul vs CCG doit être équilibré

### 4.4 Système RC & Faim (Ghouls)
- **Valeur RC** : Augmente en mangeant des cadavres → détermine le rang
- **Faim** : Système de faim, la ghoul doit se nourrir régulièrement
- **Risque** : RC élevé = plus repérable par le CCG
- **Progression** : RC bas → rang faible, RC élevé → rang élevé → compétences plus puissantes

### 4.5 Mort & Cadavres
- Joueur à 0 HP → **respawn à l'hôpital**
- Un **cadavre** est spawné à l'emplacement de la mort
- **Ghoul** : Peut manger le cadavre → gain de RC
- **CCG** : Peut détruire le cadavre OU extraire la poche RC → utilisable pour crafter une Quinque

### 4.6 Inventaire & Équipement
- Système d'**inventaire** complet
- **Onglet équipement** : Pièces d'équipement (armure, armes, etc.)
- **Onglet cosmétique** : Items cosmétiques séparés
- Sources d'items : loot, craft, boutique (à définir)

### 4.7 Boutique
- Achat de **rerolls** supplémentaires
- Autres items à définir (monnaie réelle / in-game / les deux — à confirmer)

---

## 5. Priorités de Développement

### Priorité 1 — Systèmes fondamentaux (Lancement)

| # | Système | Détails clés |
|---|---------|-------------|
| 1 | Système Kagune (Ghoul) | Activation, 4+ types, cellules RC, progression, combat |
| 2 | Système Quinque (CCG) | Armes custom, craft depuis ghouls, progression, mallette, durabilité |
| 3 | Système RC & Faim | Progression RC, faim ghoul, consommation humains, risque détection |
| 4 | Base de données & Sauvegarde | MySQL, multi-slots personnages, sauvegarde RC/faction/inventaire/stats |
| 5 | Optimisation serveur | Réduction entités, optimisation scripts, networking pour 120 joueurs |

### Priorité 2 — Factions & Profondeur RP

| # | Système | Détails clés |
|---|---------|-------------|
| 6 | Factions avancées | Hiérarchie CCG, organisations Ghoul (Aogiri), permissions, stockage partagé |
| 7 | Réputation / Recherche | Niveau criminel, enquêtes CCG, niveau de menace public |
| 8 | Capture & Interrogation | Arrestation CCG, prison Cochléa, mécaniques d'interrogatoire |

### Priorité 3 — Immersion & Systèmes avancés

| # | Système | Détails clés |
|---|---------|-------------|
| 9 | HUD personnalisé | Interface Tokyo Ghoul, barre RC, indicateur faim, identification factions |
| 10 | Système de masques | Équipement masque, craft, dissimulation d'identité |
| 11 | Système d'événements | Events admin, events auto (attaques ghouls, raids CCG), boss PNJ |
| 12 | Marché noir | Armes illégales, améliorations Kagune rares, objets boost RC |

### Priorité 4 — Améliorations futures

| # | Système | Détails clés |
|---|---------|-------------|
| 13 | Évolution Kagune | Évolution visuelle, capacités spéciales, transformation Kakuja |
| 14 | Craft avancé | Évolution Quinque, armes expérimentales |
| 15 | Statistiques & Classement | Top enquêteurs, ghoul la plus recherchée, classement factions |

---

## 6. Architecture Technique

### 6.1 Structure addon
```
garrysmod/addons/tokyo-ghoul-rp/
├── lua/
│   ├── autorun/           -- Points d'entrée (chargement modules)
│   ├── tgrp/              -- Code core du gamemode
│   │   ├── config/        -- Fichiers de configuration (modifiables par le client)
│   │   ├── core/          -- Systèmes fondamentaux (database, networking, utils)
│   │   ├── modules/       -- Modules de jeu (kagune, quinque, combat, etc.)
│   │   │   ├── characters/    -- Sélection & création de personnage
│   │   │   ├── factions/      -- Système de factions
│   │   │   ├── kagune/        -- Système Kagune (Ghouls)
│   │   │   ├── quinque/       -- Système Quinque (CCG)
│   │   │   ├── combat/        -- Système de combat
│   │   │   ├── skills/        -- Skill tree & hotbar
│   │   │   ├── inventory/     -- Inventaire & équipement
│   │   │   ├── rc/            -- Système RC & faim
│   │   │   ├── death/         -- Mort, cadavres, respawn
│   │   │   ├── reroll/        -- Système de lootbox/reroll
│   │   │   ├── shop/          -- Boutique
│   │   │   ├── reputation/    -- Réputation & recherche
│   │   │   ├── capture/       -- Capture & interrogation
│   │   │   ├── masks/         -- Système de masques
│   │   │   ├── events/        -- Événements
│   │   │   └── market/        -- Marché noir
│   │   └── ui/            -- Tous les éléments UI (PixelUI / HTML/CSS)
│   │       ├── hud/
│   │       ├── menus/
│   │       └── components/
│   └── pixelui/           -- Framework PixelUI (dépendance)
├── materials/             -- Textures & icônes
├── sound/                 -- Sons
├── models/                -- Modèles (ajoutés par le client)
└── resource/              -- Ressources à télécharger par les clients
```

### 6.2 Convention de fichiers par module
Chaque module suit la structure :
```
modules/nom_module/
├── sh_nom.lua         -- Code partagé (shared) : structures de données, config
├── sv_nom.lua         -- Code serveur : logique, base de données, sécurité
├── cl_nom.lua         -- Code client : UI, effets, rendu
└── net_nom.lua        -- Messages réseau dédiés (optimisation networking)
```

### 6.3 Optimisation networking (120 joueurs)
- Messages réseau **compressés** et **regroupés** (batching)
- Envoi uniquement aux joueurs **dans le PVS** (Potentially Visible Set) quand possible
- Utilisation de **net.WriteUInt** avec le minimum de bits nécessaires
- Éviter les net.WriteTable — sérialisation manuelle
- **Rate limiting** côté serveur sur les requêtes client
- **Think hooks** optimisés : intervalles adaptés, pas de calculs inutiles chaque tick

### 6.4 Fichiers de configuration (pour le client)
Tous dans `tgrp/config/` :
- `cfg_general.lua` — Paramètres serveur généraux
- `cfg_factions.lua` — Noms, couleurs, spawns, hiérarchie des factions
- `cfg_kagune.lua` — Types de Kagune, raretés, modèles, animations
- `cfg_quinque.lua` — Types de Quinque, raretés, modèles, animations
- `cfg_skills.lua` — Compétences, rangs, dégâts, cooldowns
- `cfg_items.lua` — Items, équipement, cosmétiques
- `cfg_shop.lua` — Contenu de la boutique, prix
- `cfg_rc.lua` — Valeurs RC, seuils de rang, vitesse de faim

> **Le client ne modifie QUE ces fichiers** pour ajouter du contenu (models, animations, etc.)

---

## 7. Points à confirmer avec le client

- [ ] 5ème sous-classe Kagune/Quinque (nom et comportement)
- [ ] Faction Civil : gameplay exact, possibilité de changer de faction ?
- [ ] Boutique : monnaie réelle, in-game, ou les deux ?
- [ ] Types de pièces d'équipement et leurs sources (loot, craft, boutique)
- [ ] Durée de vie des cadavres sur la map
- [ ] Plusieurs ghouls peuvent-elles manger le même cadavre ?
- [ ] Processus exact du craft de Quinque (PNJ ? Atelier ? Menu ?)

---

## 8. Dépendances externes

| Addon/Lib | Usage | Source |
|-----------|-------|--------|
| mysqloo | Base de données MySQL | GitHub |
| PixelUI | Framework UI HTML/CSS | GmodStore/GitHub |
| Advanced Character Creator | Base pour la création de personnage | GmodStore (à acheter & modifier) |

---

*Document mis à jour le : 2026-02-27*
*Version : 1.0*
