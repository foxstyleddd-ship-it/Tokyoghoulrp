#!/bin/bash
# ============================================================
# Tokyo Ghoul RP — Installation du serveur dédié GMod (Linux)
# ============================================================
#
# Prérequis :
#   - SteamCMD installé (apt install steamcmd ou manuellement)
#   - lib32gcc-s1 (Ubuntu/Debian : sudo apt install lib32gcc-s1)
#
# Usage :
#   chmod +x installer.sh
#   ./installer.sh
# ============================================================

# === CONFIGURATION ===

# Dossier d'installation du serveur GMod
SERVEUR_DIR="$HOME/serveur_gmod"

# Chemin vers steamcmd (auto-détection)
if command -v steamcmd &> /dev/null; then
    STEAMCMD="steamcmd"
elif [ -f "$HOME/steamcmd/steamcmd.sh" ]; then
    STEAMCMD="$HOME/steamcmd/steamcmd.sh"
else
    echo "[ERREUR] SteamCMD introuvable."
    echo "Installez-le avec : sudo apt install steamcmd"
    echo "Ou manuellement : https://developer.valvesoftware.com/wiki/SteamCMD"
    exit 1
fi

# ============================================================

echo ""
echo "========================================"
echo "  Tokyo Ghoul RP - Installation Serveur"
echo "========================================"
echo ""

# Créer le dossier serveur
mkdir -p "$SERVEUR_DIR"

echo "[1/3] Installation/mise à jour du serveur Garry's Mod..."
$STEAMCMD +force_install_dir "$SERVEUR_DIR" +login anonymous +app_update 4020 validate +quit

if [ $? -ne 0 ]; then
    echo "[ERREUR] L'installation du serveur a échoué."
    exit 1
fi

echo ""
echo "[2/3] Installation de Counter-Strike: Source (textures)..."
$STEAMCMD +force_install_dir "$SERVEUR_DIR/cstrike" +login anonymous +app_update 232330 validate +quit

echo ""
echo "[3/3] Création des dossiers de l'addon..."
mkdir -p "$SERVEUR_DIR/garrysmod/addons/tokyo-ghoul-rp"
mkdir -p "$SERVEUR_DIR/garrysmod/cfg"

echo ""
echo "========================================"
echo "  Installation terminée !"
echo "========================================"
echo ""
echo "Serveur installé dans : $SERVEUR_DIR"
echo ""
echo "Prochaines étapes :"
echo "  1. Copiez le dossier lua/ de l'addon dans :"
echo "     $SERVEUR_DIR/garrysmod/addons/tokyo-ghoul-rp/"
echo "  2. Copiez les fichiers cfg/ dans :"
echo "     $SERVEUR_DIR/garrysmod/cfg/"
echo "  3. Lancez le serveur avec ./lancer.sh"
echo ""
