#!/bin/bash
# ============================================================
# Tokyo Ghoul RP — Déployer l'addon dans le serveur (Linux)
# ============================================================
# Ce script copie les fichiers de l'addon dans le serveur local.
# À exécuter après chaque modification du code.
# ============================================================

# === CONFIGURATION ===
SERVEUR_DIR="$HOME/serveur_gmod"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ADDON_SOURCE="$SCRIPT_DIR/.."
ADDON_DEST="$SERVEUR_DIR/garrysmod/addons/tokyo-ghoul-rp"

# ============================================================

echo ""
echo "========================================"
echo "  Déploiement de l'addon Tokyo Ghoul RP"
echo "========================================"
echo ""

# Créer le dossier destination
mkdir -p "$ADDON_DEST"

# Copier le dossier lua/
echo "[1/3] Copie de lua/..."
cp -r "$ADDON_SOURCE/lua" "$ADDON_DEST/"

# Copier les ressources si elles existent
echo "[2/3] Copie des ressources..."
[ -d "$ADDON_SOURCE/materials" ] && cp -r "$ADDON_SOURCE/materials" "$ADDON_DEST/"
[ -d "$ADDON_SOURCE/sound" ] && cp -r "$ADDON_SOURCE/sound" "$ADDON_DEST/"
[ -d "$ADDON_SOURCE/models" ] && cp -r "$ADDON_SOURCE/models" "$ADDON_DEST/"
[ -d "$ADDON_SOURCE/resource" ] && cp -r "$ADDON_SOURCE/resource" "$ADDON_DEST/"

# Copier les fichiers cfg
echo "[3/3] Copie des configurations serveur..."
cp "$SCRIPT_DIR/cfg/"* "$SERVEUR_DIR/garrysmod/cfg/"

echo ""
echo "Déploiement terminé !"
echo "Redémarrez le serveur pour appliquer les changements."
echo "Ou tapez 'lua_openscript autorun/tgrp_init.lua' dans la console serveur."
echo ""
