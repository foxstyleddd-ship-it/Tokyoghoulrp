#!/bin/bash
# ============================================================
# Tokyo Ghoul RP — Lancement du serveur dédié (Linux)
# ============================================================

# === CONFIGURATION ===

# Dossier du serveur GMod
SERVEUR_DIR="$HOME/serveur_gmod"

# Map de démarrage (à changer selon votre map RP)
MAP="gm_construct"

# Nombre maximum de joueurs
MAXPLAYERS=120

# Gamemode
GAMEMODE="sandbox"

# Collection Workshop (ID de la collection Steam, vide = aucune)
WORKSHOP_COLLECTION=""

# Clé API Steam (nécessaire pour le Workshop)
# Obtenez-la ici : https://steamcommunity.com/dev/apikey
STEAM_API_KEY="VOTRE_CLE_API_STEAM"

# ============================================================

echo ""
echo "========================================"
echo "  Tokyo Ghoul RP - Lancement Serveur"
echo "========================================"
echo ""
echo "Map : $MAP"
echo "Joueurs max : $MAXPLAYERS"
echo ""

# Construire la ligne de commande
LAUNCH_CMD="-console -game garrysmod +maxplayers $MAXPLAYERS +map $MAP +gamemode $GAMEMODE -authkey $STEAM_API_KEY"

if [ -n "$WORKSHOP_COLLECTION" ]; then
    LAUNCH_CMD="$LAUNCH_CMD +host_workshop_collection $WORKSHOP_COLLECTION"
fi

echo "Lancement avec : $LAUNCH_CMD"
echo ""

cd "$SERVEUR_DIR"
./srcds_run $LAUNCH_CMD
