@echo off
REM ============================================================
REM Tokyo Ghoul RP — Lancement du serveur dédié (Windows)
REM ============================================================

REM === CONFIGURATION ===

REM Dossier du serveur GMod
set SERVEUR_DIR=C:\serveur_gmod

REM Map de démarrage (à changer selon votre map RP)
set MAP=gm_construct

REM Nombre maximum de joueurs
set MAXPLAYERS=120

REM Gamemode
set GAMEMODE=sandbox

REM Collection Workshop (ID de la collection Steam, 0 = aucune)
set WORKSHOP_COLLECTION=0

REM ============================================================

echo.
echo ========================================
echo   Tokyo Ghoul RP - Lancement Serveur
echo ========================================
echo.
echo Map : %MAP%
echo Joueurs max : %MAXPLAYERS%
echo.

REM Construire la ligne de commande
set LAUNCH_CMD=-console -game garrysmod +maxplayers %MAXPLAYERS% +map %MAP% +gamemode %GAMEMODE% -authkey VOTRE_CLE_API_STEAM

if %WORKSHOP_COLLECTION% NEQ 0 (
    set LAUNCH_CMD=%LAUNCH_CMD% +host_workshop_collection %WORKSHOP_COLLECTION%
)

echo Lancement avec : %LAUNCH_CMD%
echo.

cd /d "%SERVEUR_DIR%"
srcds.exe %LAUNCH_CMD%

pause
