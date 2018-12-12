@echo off
chcp 65001 > nul
color F0
goto askuser
:askuser
set /p user=Merci de renseigner l'ip ou l'identifiant de la machine : 
echo %user%|findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"
if NOT errorlevel 1 GOTO ip
set ip=0
for /F "tokens=2 delims= " %%i in ('"nslookup %user% | find "Address" | more /E +1"') do set ip=%%i
if %ip% EQU 0 GOTO failident ELSE (
set ident=%user%
goto menu
)
:ip
ping %user% -n 1 >nul
cls
if errorlevel 1 GOTO failident
set ip=%user%
GOTO hostname
:hostname
for /F "tokens=3 delims= " %%n in ('REG QUERY "\\%user%\HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Tcpip\Parameters" /v Hostname') do set  ident=%%n
goto menu
:failident
echo Veuillez vérifier votre saisie ...
goto askuser
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
echo  4 - Ralonger mise en veille Win10
echo  5 - Ouvrir fenetre c$
echo  6 - Lancer la Prise en main à distance 
echo  7 - Débogage Rforce
echo.
echo  8 - Logs pour escalade
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
if %choix% EQU 69 goto 69
if %choix% EQU q goto 12
if %choix% EQU Q goto 12
:1
REM 1 - Débogage de la stratégie de groupe
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
REM 2 - Arret du processus MS Outlook
echo %DATE:/=-% à %TIME::=-% - Arret du processus MS Outlook >> "log_%ident%.txt"
cls
echo Fermeture de Outlook
taskkill /s %ip% /IM OUTLOOK.EXE
if errorlevel 1 goto menu
echo ---------------------
echo ----Outlook fermé---- 
echo ---------------------
goto menu
:3
REM 3 - Rédémarage distant
echo %DATE:/=-% à %TIME::=-% - Rédémarage distant >> "log_%ident%.txt"
shutdown -r -t 10 -m  \\%ip%
goto menu
:4
REM 4 - Ralonger mise en veille Win10
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
echo ---------------------
echo Changement effectué 
echo ---------------------
goto menu
:5
REM 5 - Ouvrir fenetre c$
echo %DATE:/=-% à %TIME::=-% - Ouverture fenetre c$ >> "log_%ident%.txt"
explorer \\%ident%\c$\
goto menu
:6
REM 6 - Lancer la Prise en main à distance
echo %DATE:/=-% à %TIME::=-% - Lancer la Prise en main à distance >> "log_%ident%.txt"
echo -------------------------------------------
echo Lancement de la prise en main à distance
echo -------------------------------------------
"C:\Program Files (x86)\CMRemoteToolsv3\CmRcViewer.exe" %ip%
goto menu
:7
REM 7 - Débogage Rforce
echo %DATE:/=-% à %TIME::=-% - Débogage Rforce >> "log_%ident%.txt"
xcopy /s "Rforce.bat" "\\%ident%\C$\Users\Public\Desktop"
echo Le patch est maintenant copié sur le bureau de l'utilisateur
ping localhost -n 1 >nul 
goto menu
:8
REM 9 - Logs pour escalade
SYSTEMINFO /S %ident% 
echo %DATE:/=-% à %TIME::=-% - SYSTEMINFO >> "log_%ident%.txt"
SYSTEMINFO /S %ident% >> "log_%ident%.txt"
echo --------------------------
echo Fichier log sur le Bureau 
echo --------------------------
goto menu
:69
start eastereeg.bat
goto menu 
:12
@exit