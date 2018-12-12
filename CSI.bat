@echo off
chcp 65001 > nul
color 9F
set /p user=Nom de la machine ? ou ip ?
echo %user%|findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"
if NOT errorlevel 1 GOTO ip
for /F "tokens=2 delims= " %%i in ('"nslookup %user% | find "Address" | more /E +1"') do set ip=%%i
set ident=%user%
goto menu
:ip
set ip=%user%
GOTO hostname
:hostname
for /F "tokens=3 delims= " %%n in ('REG QUERY "\\%user%\HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v Hostname') do set  ident=%%n
goto menu
:menu
echo ip:%ip% ident:%ident%
echo -----------------------------------------------
echo   Gestionnaire de mise a jours CSI
echo                                PERNOD-RICARD
echo ----------------------------------------------- 
echo.
echo  1 - Débogage de la stratégie de groupe
echo  2 - Arret du processus MS Outlook
echo  3 - Rédémarage distant
echo  4 - Débogage Tactile
echo  5 - Ralonger mise en veille Win10
echo  6 - Zscaler repair
echo  7 - Log escalade ticket
echo  8 - Lancer la Prise en main à distance
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
if %choix% EQU 8 goto 8
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
for /F %%n in ('REG QUERY \\%ident%\HKEY_USERS') do (
	REG QUERY "\\%ident%\%%n\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut
	if NOT errorlevel 1 (
	REG ADD "\\%ident%\%%n\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d 1200 /F
	)
)
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
:8
echo -------------------------------------------
echo Lancement de la prise en main à distance
echo -------------------------------------------
"C:\Program Files (x86)\CMRemoteToolsv3\CmRcViewer.exe" %ip%
goto menu
@exit