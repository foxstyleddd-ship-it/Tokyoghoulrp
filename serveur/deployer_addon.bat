@echo off
REM ============================================================
REM Tokyo Ghoul RP — Déployer l'addon dans le serveur (Windows)
REM ============================================================
REM Ce script copie les fichiers de l'addon dans le serveur local.
REM À exécuter après chaque modification du code.
REM ============================================================

REM === CONFIGURATION ===
set SERVEUR_DIR=C:\serveur_gmod
set ADDON_SOURCE=%~dp0..
set ADDON_DEST=%SERVEUR_DIR%\garrysmod\addons\tokyo-ghoul-rp

REM ============================================================

echo.
echo ========================================
echo   Deploiement de l'addon Tokyo Ghoul RP
echo ========================================
echo.

REM Copier le dossier lua/
echo [1/3] Copie de lua/...
xcopy /E /Y /I "%ADDON_SOURCE%\lua" "%ADDON_DEST%\lua"

REM Copier les resources si elles existent
echo [2/3] Copie des ressources...
if exist "%ADDON_SOURCE%\materials" xcopy /E /Y /I "%ADDON_SOURCE%\materials" "%ADDON_DEST%\materials"
if exist "%ADDON_SOURCE%\sound" xcopy /E /Y /I "%ADDON_SOURCE%\sound" "%ADDON_DEST%\sound"
if exist "%ADDON_SOURCE%\models" xcopy /E /Y /I "%ADDON_SOURCE%\models" "%ADDON_DEST%\models"
if exist "%ADDON_SOURCE%\resource" xcopy /E /Y /I "%ADDON_SOURCE%\resource" "%ADDON_DEST%\resource"

REM Copier les fichiers cfg
echo [3/3] Copie des configurations serveur...
xcopy /Y "%~dp0cfg\*.*" "%SERVEUR_DIR%\garrysmod\cfg\"

echo.
echo Deploiement termine !
echo Redemarrez le serveur pour appliquer les changements.
echo Ou tapez "lua_openscript autorun/tgrp_init.lua" dans la console serveur.
echo.
pause
