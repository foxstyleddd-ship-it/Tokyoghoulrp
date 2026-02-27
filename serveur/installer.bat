@echo off
REM ============================================================
REM Tokyo Ghoul RP — Installation du serveur dédié GMod (Windows)
REM ============================================================
REM
REM Prérequis : SteamCMD installé
REM Téléchargez SteamCMD ici : https://developer.valvesoftware.com/wiki/SteamCMD
REM
REM Instructions :
REM 1. Placez ce script dans le même dossier que steamcmd.exe
REM    OU modifiez la variable STEAMCMD_DIR ci-dessous
REM 2. Exécutez ce script en double-cliquant dessus
REM 3. Le serveur GMod sera installé dans le dossier SERVEUR_DIR
REM ============================================================

REM === CONFIGURATION (à modifier selon votre installation) ===

REM Chemin vers steamcmd.exe
set STEAMCMD_DIR=C:\steamcmd

REM Dossier d'installation du serveur GMod
set SERVEUR_DIR=C:\serveur_gmod

REM ============================================================

echo.
echo ========================================
echo   Tokyo Ghoul RP - Installation Serveur
echo ========================================
echo.

REM Vérifier que SteamCMD existe
if not exist "%STEAMCMD_DIR%\steamcmd.exe" (
    echo [ERREUR] steamcmd.exe introuvable dans %STEAMCMD_DIR%
    echo Telechargez SteamCMD depuis : https://developer.valvesoftware.com/wiki/SteamCMD
    pause
    exit /b 1
)

echo [1/3] Installation/mise a jour du serveur Garry's Mod...
"%STEAMCMD_DIR%\steamcmd.exe" +force_install_dir "%SERVEUR_DIR%" +login anonymous +app_update 4020 validate +quit

if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] L'installation du serveur a echoue.
    pause
    exit /b 1
)

echo.
echo [2/3] Installation de Counter-Strike: Source (textures necessaires)...
"%STEAMCMD_DIR%\steamcmd.exe" +force_install_dir "%SERVEUR_DIR%\cstrike" +login anonymous +app_update 232330 validate +quit

echo.
echo [3/3] Creation des dossiers de l'addon...

REM Créer le lien symbolique ou copier l'addon dans le serveur
if not exist "%SERVEUR_DIR%\garrysmod\addons\tokyo-ghoul-rp" (
    mkdir "%SERVEUR_DIR%\garrysmod\addons\tokyo-ghoul-rp"
)

echo.
echo ========================================
echo   Installation terminee !
echo ========================================
echo.
echo Serveur installe dans : %SERVEUR_DIR%
echo.
echo Prochaines etapes :
echo   1. Copiez le dossier lua/ de l'addon dans :
echo      %SERVEUR_DIR%\garrysmod\addons\tokyo-ghoul-rp\
echo   2. Copiez les fichiers cfg/ dans :
echo      %SERVEUR_DIR%\garrysmod\cfg\
echo   3. Lancez le serveur avec lancer.bat
echo.
pause
