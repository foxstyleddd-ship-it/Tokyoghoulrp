# Découpage en Sprints — Tokyo Ghoul RP

---

## Sprint 0 — Fondations techniques
> Objectif : Avoir la base technique solide sur laquelle tout le reste repose.

- [ ] **0.1** Structure de l'addon et système de chargement automatique des modules
- [ ] **0.2** Système de configuration (fichiers `cfg_*.lua` avec validation)
- [ ] **0.3** Connexion MySQL (mysqloo) + helpers de requêtes (pool, requêtes préparées, retry)
- [ ] **0.4** Framework networking optimisé (compression, batching, PVS, rate limiting)
- [ ] **0.5** Système de logs serveur (debug, erreurs, actions joueurs)

**Livrable** : Un addon vide qui se charge, se connecte à la BDD, et offre les outils réseau/DB réutilisables par tous les modules.

---

## Sprint 1 — Personnages & Factions
> Objectif : Un joueur peut créer un personnage, choisir une faction, et spawner.

- [ ] **1.1** Écran de sélection de personnage (3 slots) — UI PixelUI
- [ ] **1.2** Création de personnage (intégration Advanced Character Creator + choix faction)
- [ ] **1.3** Sauvegarde/chargement personnages en BDD (multi-slots)
- [ ] **1.4** Système de factions (Ghoul / CCG / Civil) avec zones de spawn
- [ ] **1.5** Spawn du joueur dans la zone de sa faction

**Livrable** : Le joueur se connecte, crée un perso avec faction, et spawn au bon endroit.

---

## Sprint 2 — Système RC, Faim & Mort
> Objectif : Le cycle de vie/mort fonctionne avec le système RC.

- [ ] **2.1** Système de valeur RC (stockage, progression, seuils de rang)
- [ ] **2.2** Système de faim des Ghouls (décroissance, effets)
- [ ] **2.3** Système de mort (0 HP → respawn hôpital)
- [ ] **2.4** Spawn de cadavres à la mort
- [ ] **2.5** Ghoul : manger un cadavre (gain RC + réduction faim)
- [ ] **2.6** CCG : détruire un cadavre OU extraire poche RC

**Livrable** : Un joueur meurt → cadavre spawn → une ghoul peut le manger → son RC monte.

---

## Sprint 3 — Reroll, Kagune & Quinque (base)
> Objectif : Les joueurs obtiennent leur Kagune/Quinque et peuvent l'activer.

- [ ] **3.1** Système de sous-classes Kagune (Rinkaku, Ukaku, Koukaku, Bikaku, +1)
- [ ] **3.2** Système de sous-classes Quinque (5 types configurables)
- [ ] **3.3** Système de raretés
- [ ] **3.4** Système de reroll / lootbox (animation défilement horizontal, 1 gratuit)
- [ ] **3.5** Activation Kagune (Ghoul) — affichage modèle/effets
- [ ] **3.6** Activation Quinque (CCG) — via mallette, durabilité

**Livrable** : Le joueur ouvre son menu → reroll → obtient un Kagune/Quinque → peut l'activer en jeu.

---

## Sprint 4 — Skill Tree, Compétences & Hotbar
> Objectif : Les joueurs débloquent et utilisent des compétences.

- [ ] **4.1** Structure de données du skill tree (arbre, nœuds, prérequis, rangs)
- [ ] **4.2** UI du skill tree (PixelUI) — navigation, déblocage
- [ ] **4.3** Système de rang joueur (lié au RC pour Ghouls, progression pour CCG)
- [ ] **4.4** Hotbar de compétences (drag & drop depuis le skill tree, slots 1-4)
- [ ] **4.5** Exécution des compétences (cooldowns, coût en énergie/RC, effets)

**Livrable** : Le joueur ouvre le skill tree, débloque des compétences selon son rang, les met dans sa hotbar, et les utilise avec [1-4].

---

## Sprint 5 — Système de Combat
> Objectif : Le combat PvP fonctionne avec coups basiques + compétences.

- [ ] **5.1** Coups basiques (mêlée, animations, hitbox, dégâts)
- [ ] **5.2** Intégration des compétences dans le combat (dégâts, effets, zones)
- [ ] **5.3** Système de HP / dégâts / résistances
- [ ] **5.4** Équilibrage Ghoul vs CCG
- [ ] **5.5** Feedback visuel (effets, particules, sons)
- [ ] **5.6** Optimisation networking du combat (PVS, interpolation, hit validation serveur)

**Livrable** : Deux joueurs peuvent se battre avec coups basiques + skills, le perdant meurt et le cycle Sprint 2 se déclenche.

---

## Sprint 6 — Inventaire & Équipement
> Objectif : Système d'inventaire fonctionnel avec équipement et cosmétiques.

- [ ] **6.1** Système d'inventaire (grille, poids/slots, sauvegarde BDD)
- [ ] **6.2** Système d'items (structure de données, types, raretés)
- [ ] **6.3** Onglet équipement (slots : arme, armure, accessoires)
- [ ] **6.4** Onglet cosmétique (items visuels sans stats)
- [ ] **6.5** UI inventaire (PixelUI — drag & drop, tooltips, split/stack)
- [ ] **6.6** CCG : craft de Quinque à partir de poches RC (interface de craft)

**Livrable** : Le joueur a un inventaire, peut équiper des items et des cosmétiques, le CCG peut crafter des Quinques.

---

## Sprint 7 — HUD & Boutique
> Objectif : Interface de jeu complète et boutique fonctionnelle.

- [ ] **7.1** HUD principal (HP, RC, faim, faction, niveau/rang)
- [ ] **7.2** Indicateurs de combat (cooldowns hotbar, cible, dégâts)
- [ ] **7.3** Boutique : UI (PixelUI)
- [ ] **7.4** Boutique : système d'achat (rerolls, items, cosmétiques)
- [ ] **7.5** Intégration paiement (monnaie in-game et/ou réelle — selon décision client)

**Livrable** : Le joueur a un HUD complet style Tokyo Ghoul et peut acheter dans la boutique.

---

## Sprint 8 — Factions avancées & Réputation
> Objectif : Profondeur RP avec hiérarchie et système de réputation.

- [ ] **8.1** Hiérarchie CCG (Académie → Enquêteur → Classe spéciale)
- [ ] **8.2** Organisations Ghoul (type Aogiri, permissions)
- [ ] **8.3** Stockage partagé par faction
- [ ] **8.4** Système de réputation / niveau criminel (Ghouls)
- [ ] **8.5** Système d'enquête CCG / niveau de menace public
- [ ] **8.6** Système de risque : RC élevé → détection accrue

**Livrable** : Les factions ont de la profondeur, les ghouls sont traquées selon leur réputation.

---

## Sprint 9 — Capture, Masques & Immersion
> Objectif : Systèmes RP avancés pour l'immersion.

- [ ] **9.1** Système d'arrestation (CCG capture une ghoul)
- [ ] **9.2** Prison Cochléa (cellules, évasion possible ?)
- [ ] **9.3** Mécaniques d'interrogatoire
- [ ] **9.4** Système de masques (équipement, craft)
- [ ] **9.5** Dissimulation d'identité (masque = anonymat)

**Livrable** : Le CCG peut arrêter des ghouls, les ghouls peuvent porter des masques pour cacher leur identité.

---

## Sprint 10 — Événements & Marché noir
> Objectif : Contenu dynamique et économie parallèle.

- [ ] **10.1** Événements admin (interface de déclenchement, types d'events)
- [ ] **10.2** Événements automatiques (attaques ghouls, raids CCG)
- [ ] **10.3** Boss PNJ (IA, loot, spawn)
- [ ] **10.4** Marché noir (vendeur, armes illégales, boosts)
- [ ] **10.5** Améliorations rares de Kagune (via marché noir)

**Livrable** : Le serveur a du contenu dynamique et une économie souterraine.

---

## Sprint 11 — Évolution & Craft avancé
> Objectif : Systèmes de progression endgame.

- [ ] **11.1** Évolution visuelle du Kagune
- [ ] **11.2** Déblocage capacités spéciales (haute RC)
- [ ] **11.3** Transformation Kakuja
- [ ] **11.4** Évolution des Quinques
- [ ] **11.5** Armes expérimentales CCG

**Livrable** : Les joueurs endgame ont du contenu de progression avancé.

---

## Sprint 12 — Statistiques, Polish & Lancement
> Objectif : Finitions, classements, et préparation au lancement.

- [ ] **12.1** Classement : meilleurs enquêteurs CCG
- [ ] **12.2** Classement : ghoul la plus recherchée
- [ ] **12.3** Classement par faction
- [ ] **12.4** Optimisation finale (profiling, stress test 120 joueurs)
- [ ] **12.5** Documentation pour le client (guide d'ajout de contenu)
- [ ] **12.6** Tests complets & corrections de bugs

**Livrable** : Serveur prêt pour le lancement.

---

## Résumé des dépendances entre sprints

```
Sprint 0 (Fondations)
   ↓
Sprint 1 (Personnages & Factions)
   ↓
Sprint 2 (RC, Faim & Mort)
   ↓
Sprint 3 (Reroll, Kagune & Quinque)
   ↓
Sprint 4 (Skill Tree & Hotbar)
   ↓
Sprint 5 (Combat)        Sprint 6 (Inventaire) ← peuvent être en parallèle
   ↓                        ↓
Sprint 7 (HUD & Boutique) ← dépend des deux
   ↓
Sprint 8 (Factions avancées)    ← peut commencer dès Sprint 7
Sprint 9 (Capture & Masques)    ← peut commencer dès Sprint 7
Sprint 10 (Événements)          ← peut commencer dès Sprint 7
   ↓
Sprint 11 (Évolution & Craft)   ← dépend de Sprint 8-10
   ↓
Sprint 12 (Polish & Lancement)
```

---

*Document mis à jour le : 2026-02-27*
*Version : 1.0*
