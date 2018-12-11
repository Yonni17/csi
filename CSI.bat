@echo off
chcp 65001 > nul
color 9F
set /p ident=Nom de la machine ? ou ip ?
echo %ident%|findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"
if NOT errorlevel 1 GOTO menu 
for /F "tokens=2 delims= " %%i in ('"nslookup %ident% | find "Address" | more /E +1"') do set ip=%%i
echo IP: %ip%
:menu
echo -----------------------------------------------
echo   Gestionnaire de mise a jours CSI
echo                                PERNOD-RICARD
echo ----------------------------------------------- 
echo.
echo  1 - Débogage de la stratégie de groupe
echo  2 - Débogage de MS Outlook
echo  3 - Rédémarage distant
echo  4 - Débogage Tactile
echo  5 - Ralonger mise en veille Win10
echo  6 - Zscaler repair
echo  7 - Log escalade ticket
echo.
echo -----------------------------------------------
ping localhost -n 2 >nul
echo.
set /p choix=Choisir ou Q et presser ENTRÉE : 
if %choix% EQU 1 goto 1
if %choix% EQU 2 goto 2
if %choix% EQU 3 goto 3
if %choix% EQU 4 goto 4
if %choix% EQU 5 goto 5
if %choix% EQU 6 goto 6
if %choix% EQU 7 goto 7
if %choix% EQU q goto 4
if %choix% EQU Q goto 4
:1
cls
start powershell -Command "Invoke-GPUpdate -Computer %ident% -RandomDelayInMinutes 0 -force"
echo ----------------------------------------------------------------------------
echo La mise à jour de la stratégie d'ordinateur s'est terminée sans erreur.
echo ----------------------------------------------------------------------------
echo.
ping localhost -n 1 >nul
goto menu
:2
cls
echo Fermeture de Outlook
taskkill /s %ip% /IM OUTLOOK.EXE
ping localhost -n 1 >nul
echo Démarrage de Outlook en mode sans échec
ping localhost -n 1 >nul
echo Merci de quitter l'application a la fin du lancement du profil utilisateur
echo ! quand vous etes sur la page avec la liste des mails !
"C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE" /safe
ping localhost -n 1 >nul
echo Démarrage en mode normal
"C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"
ping localhost -n 1 >nul
goto menu
:3
shutdown -r -t 10 -m  \\%ip%
goto menu
:5
cls
runas /noprofile /user:RICARD\moreaut cmd
powercfg -energy
echo Observation du comportement du système effectué
echo.
goto menu
pause
:4
@exit