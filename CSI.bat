@echo off
chcp 65001 > nul
color 9F
set /p ident=Nom de la machine ? ou ip ?
echo %ident%|findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"
if NOT errorlevel 1 GOTO menu 
for /F "tokens=2 delims= " %%i in ('"nslookup %ident% | find "Address" | more /E +1"') do set ip=%%i
echo IP: %ip%
REM HKEY_LOCAL_MACHINE-->SOFTWARE-->SYSTEM-->ControlSet001-->services-->Tcpip-->Parameters-->NV Hostname
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
echo --------------------------
echo Changement de l'atribut 
echo --------------------------
REG ADD \\%ident%\HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 /v Attributes /t REG_DWORD /d 0x00000002 /f
ping localhost -n 1 >nul
echo --------------------------------------------------
echo Changement du délai de veille Ordinateur à 20 min
echo --------------------------------------------------
REM REG ADD "\\%ident%\HKEY_USERS\S-1-5-21-3212575337-2465839514-940793929-%%%%%\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d 1200 /F
for /f "tokens=5" %%i in ('REG QUERY "\\RICD00232\HKEY_USERS') do Set reg_ident=%%i
REM for /f "tokens=5" %%a in ('REG QUERY "\\RICD00232\HKEY_USERS') do echo %%a
REM set reg_ident=REG QUERY "\\%ident%\HKEY_USERS
REM echo %reg_ident%
pause
ping localhost -n 1 >nul 
goto menu
:6
cls
runas /noprofile /user:RICARD\moreaut cmd
powercfg -energy
echo Observation du comportement du système effectué
echo.
goto menu
pause
:4
@exit