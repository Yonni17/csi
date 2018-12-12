@echo off
chcp 65001 > nul
color F0
set /p user=Merci de renseigner l'ip ou l'identifiant de la machine : 
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
echo -----------------------------------------------
echo ------ ip:%ip%  ident:%ident% -------
echo -----------------------------------------------
echo.
echo   Gestionnaire Service Desk CSI
echo                                PERNOD-RICARD
echo.
echo ----------------------------------------------- 
echo.
echo  1 - Débogage de la stratégie de groupe
echo  2 - Arret du processus MS Outlook
echo  3 - Rédémarage distant
echo  4 - Débogage Tactile (KO)
echo  5 - Ralonger mise en veille Win10
echo  6 - Zscaler repair (KO)
echo  7 - Ouvrir fenetre c$
echo  8 - Lancer la Prise en main à distance 
echo  9 - Débogage Rforce (KO)
echo 10 - Mappage UNC (KO)
echo.
echo 11 - Logs pour escalade
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
if %choix% EQU 9 goto 9
if %choix% EQU 10 goto 10
if %choix% EQU 11 goto 11
if %choix% EQU q goto 12
if %choix% EQU Q goto 12
:1
echo %DATE:/=-% à %TIME::=-% - Débogage de la stratégie de groupe >> "log_%ident%.txt"
cls
start powershell -Command "Invoke-GPUpdate -Computer %ident% -RandomDelayInMinutes 0 -force"
echo ----------------------------------------------------------------------------
echo La mise à jour de la stratégie d'ordinateur s'est terminée sans erreur.
echo ----------------------------------------------------------------------------
echo.
ping localhost -n 1 >nul
goto menu
:2
echo %DATE:/=-% à %TIME::=-% - Arret du processus MS Outlook >> "log_%ident%.txt"
cls
echo Fermeture de Outlook
taskkill /s %ip% /IM OUTLOOK.EXE
goto menu
:3
echo %DATE:/=-% à %TIME::=-% - Rédémarage distant >> "log_%ident%.txt"
shutdown -r -t 10 -m  \\%ip%
goto menu
:4
echo %DATE:/=-% à %TIME::=-% - Débogage Tactile (KO) >> "log_%ident%.txt"
:5
echo %DATE:/=-% à %TIME::=-% - Ralonger mise en veille Win10 >> "log_%ident%.txt"
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
echo %DATE:/=-% à %TIME::=-% - Zscaler repair >> "log_%ident%.txt"
:7
echo %DATE:/=-% à %TIME::=-% - Ouverture fenetre c$ >> "log_%ident%.txt"
explorer \\%ident%\c$\
goto menu
:8
echo %DATE:/=-% à %TIME::=-% - Lancer la Prise en main à distance >> "log_%ident%.txt"
echo -------------------------------------------
echo Lancement de la prise en main à distance
echo -------------------------------------------
"C:\Program Files (x86)\CMRemoteToolsv3\CmRcViewer.exe" %ip%
goto menu
:9
echo %DATE:/=-% à %TIME::=-% - Débogage Rforce >> "log_%ident%.txt"
for %%a in (
@echo off
echo 0.0.0.0 > C:\Tools\BUApps\RFORCE_V3\Box\BoxVersion.txt
start C:\Tools\BUApps\RFORCE_V3\Box\Progs\EdgeUpdater.exe
pause
exit
) do echo %%a >> \\%ident%\C$\Users\Public\Desktop\RFOCE_patch.bat
pause
goto menu
:10
echo %DATE:/=-% à %TIME::=-% - Mappage UNC >> "log_%ident%.txt"
:11
SYSTEMINFO /S %ident% 
echo %DATE:/=-% à %TIME::=-% - SYSTEMINFO >> "log_%ident%.txt"
REM SYSTEMINFO >> "log_%ident%.txt"
goto menu
:12
@exit