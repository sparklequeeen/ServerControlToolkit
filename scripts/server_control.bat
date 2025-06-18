@echo off
setlocal

set "SCRIPT_DIR=%~dp0.."

REM Cargar configuracion
if exist "%SCRIPT_DIR%\config.ini" (
    for /f "tokens=1,2 delims==" %%A in (%SCRIPT_DIR%\config.ini) do (
        set "%%A=%%B"
    )
)

if "%~1"=="poweroff" goto POWEROFF
if "%~1"=="reboot" goto REBOOT
if "%~1"=="suspend" goto SUSPEND
if "%~1"=="hibernate" goto HIBERNATE
if "%~1"=="sshkeys" goto SSHKEYS
if "%~1"=="troubleshoot" goto TROUBLESHOOT
if "%~1"=="configuresudo" goto CONFIGURE_SUDO

echo Uso: server_control.bat [poweroff|reboot|suspend|hibernate|sshkeys|troubleshoot|configuresudo]
exit /b 1

:POWEROFF
echo %YELLOW%[~]%RESET% Apagando servidor...
ssh -p %SSH_PORT% %SSH_USER%@%IP% "sudo -S systemctl poweroff" < nul
goto :CHECK_ERROR

:REBOOT
echo %YELLOW%[~]%RESET% Reiniciando servidor...
ssh -p %SSH_PORT% %SSH_USER%@%IP% "sudo -S systemctl reboot" < nul
goto :CHECK_ERROR

:SUSPEND
echo %YELLOW%[~]%RESET% Suspension servidor...
ssh -p %SSH_PORT% %SSH_USER%@%IP% "sudo -S systemctl suspend" < nul
goto :CHECK_ERROR

:HIBERNATE
echo %YELLOW%[~]%RESET% Hibernando servidor...
ssh -p %SSH_PORT% %SSH_USER%@%IP% "sudo -S systemctl hibernate" < nul
goto :CHECK_ERROR

:SSHKEYS
echo %YELLOW%[~]%RESET% Configurando SSH keys...
if not exist "%USERPROFILE%\.ssh\id_rsa" (
    ssh-keygen -t rsa -b 4096 -N "" -f "%USERPROFILE%\.ssh\id_rsa" -q
)

echo Copiando clave publica al servidor...
type "%USERPROFILE%\.ssh\id_rsa.pub" | ssh -p %SSH_PORT% %SSH_USER%@%IP% "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
if %errorlevel% equ 0 (
    echo %GREEN%[✓]%RESET% Clave SSH configurada con exito
) else (
    echo %RED%[X]%RESET% Error al copiar clave
)
pause
exit /b

:CONFIGURE_SUDO
echo %YELLOW%[~]%RESET% Configurando sudo sin contrasena...
echo %CYAN%[i]%RESET% Abriendo conexion SSH para configuracion...
start "" ssh -t -p %SSH_PORT% %SSH_USER%@%IP% "echo '%SSH_USER% ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend, /usr/bin/systemctl hibernate' | sudo tee /etc/sudoers.d/nopasswd_systemctl && sudo chmod 440 /etc/sudoers.d/nopasswd_systemctl && echo 'Configuracion completada! Cierre esta ventana.' || echo 'Error en configuracion'"
echo %GREEN%[✓]%RESET% Siga las instrucciones en la nueva ventana SSH
echo %YELLOW%[~]%RESET% Cuando termine, cierre la ventana SSH y presione una tecla aqui...
pause
exit /b

:CHECK_ERROR
if %errorlevel% equ 0 (
    echo %GREEN%[✓]%RESET% Comando ejecutado con exito
) else (
    echo %RED%[X]%RESET% Error en comando remoto
)
pause
exit /b

:TROUBLESHOOT
echo %YELLOW%===== SOPORTE TECNICO =====%RESET%
echo 1) Problemas con Wake-on-LAN
echo 2) Error en comandos SSH
echo 3) Fallo en iperf3
echo 4) Problemas con escaneo de puertos
set "valid_options=1 2 3 4"
:GET_ISSUE
set "issue="
set /p "issue=➤ Seleccione opcion (1-4): "

if "%issue%"=="" goto GET_ISSUE

echo %valid_options% | findstr /i "\<%issue%\>" >nul
if %errorlevel% neq 0 (
    echo %RED%[!]%RESET% Opcion invalida.
    timeout /t 1 >nul
    goto GET_ISSUE
)

if "%issue%"=="1" (
    echo %CYAN%[i]%RESET% Solucion WoL:
    echo 1. Verifique cable de red y alimentacion
    echo 2. Habilite WoL en BIOS: Power Management > Wake on LAN
    echo 3. En servidor Linux ejecute:
    echo    sudo ethtool -s eth0 wol g
    echo 4. Configure router para permitir paquetes WoL (UDP puerto 9)
    echo 5. Verifique firewall: sudo ufw allow 9/udp
)

if "%issue%"=="2" (
    echo %CYAN%[i]%RESET% Solucion SSH:
    echo 1. Verifique usuario/puerto en config.ini
    echo 2. Confirme estado del servicio SSH:
    echo    sudo systemctl status sshd
    echo 3. Verifique firewall:
    echo    sudo ufw allow %SSH_PORT%
    echo 4. Pruebe conexion manual:
    echo    ssh -p %SSH_PORT% %SSH_USER%@%IP%
)

if "%issue%"=="3" (
    echo %CYAN%[i]%RESET% Solucion iperf3:
    echo 1. Instale iperf3 en servidor:
    echo    sudo apt install iperf3
    echo 2. Abra puerto 5201 en firewall:
    echo    sudo ufw allow 5201/tcp
    echo 3. Verifique que no haya otro iperf3 corriendo
)

if "%issue%"=="4" (
    echo %CYAN%[i]%RESET% Solucion nmap:
    echo 1. Debe instalar nmap en su PC Windows
    echo 2. Descargue el instalador: https://nmap.org/download.html
    echo 3. Ejecute el instalador y siga los pasos
    echo 4. Asegurese de marcar "Add nmap to my PATH" durante la instalacion
    echo 5. Despues de instalar, verifique con: nmap --version
)

pause
exit /b