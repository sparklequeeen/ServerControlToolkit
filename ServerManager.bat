@echo off
setlocal enabledelayedexpansion

REM ===== FIX CODIFICACIÓN UTF-8 =====
chcp 65001 > nul
if not defined _CHCP_SET (
    set "_CHCP_SET=1"
    cmd /c "%~f0" %*
    exit /b
)

REM ===== CONFIGURACIÓN INICIAL =====
set "SCRIPT_DIR=%~dp0"
set "BIN_DIR=%SCRIPT_DIR%bin"
set "LOG_DIR=%SCRIPT_DIR%logs"
set "SCRIPTS_DIR=%SCRIPT_DIR%scripts"

REM Crear directorios necesarios
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%BIN_DIR%" mkdir "%BIN_DIR%"

REM Cargar configuración
call :LOAD_CONFIG

REM Iniciar sistema de colores
call :INIT_COLORS

:MENU_PRINCIPAL
cls
echo %BLUE%============================================%RESET%
echo %BLUE%       SERVER CONTROL KIT v2.0 [Linux]     %RESET%
echo %BLUE%============================================%RESET%
echo.

echo %YELLOW%===== CONTROL DE ENERGIA =====%RESET%
echo  1) [WoL] Encender servidor
echo  2) [OFF] Apagar servidor
echo  3) [RST] Reiniciar servidor
echo  4) [SUS] Suspender servidor
echo  5) [HIB] Hibernar servidor
echo.

echo %YELLOW%===== DIAGNOSTICO DE RED =====%RESET%
echo  6) [PING] Comprobar conectividad
echo  7) [SPEED] Test de velocidad (iperf3)
echo  8) [SCAN] Escanear puertos
echo.

echo %YELLOW%===== CONFIGURACION =====%RESET%
echo  9) [CFG] Editar configuracion
echo 10) [SSH] Configurar SSH sin contrasena
echo 11) [INST] Instalar requisitos
echo 15) [SUDO] Configurar sudo sin contrasena
echo.

echo %YELLOW%===== HERRAMIENTAS =====%RESET%
echo 12) [CHK] Verificar dependencias
echo 13) [LOG] Ver logs de actividad
echo 14) [HELP] Soporte tecnico
echo  0) [EXIT] Salir
echo %BLUE%============================================%RESET%

set "valid_options=0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
:GET_INPUT
set "option="
set /p "option=➤ Seleccione opcion (0-15): "

if "%option%"=="" goto GET_INPUT

echo %valid_options% | findstr /i "\<%option%\>" >nul
if %errorlevel% neq 0 (
    echo %RED%[!]%RESET% Opcion invalida. Intente nuevamente.
    timeout /t 1 >nul
    goto GET_INPUT
)

if "%option%"=="0" goto EXIT_PROGRAM
if "%option%"=="1" goto WAKE_SERVER
if "%option%"=="2" goto SHUTDOWN
if "%option%"=="3" goto REBOOT
if "%option%"=="4" goto SUSPEND
if "%option%"=="5" goto HIBERNATE
if "%option%"=="6" goto PING_TEST
if "%option%"=="7" goto IPERF_TEST
if "%option%"=="8" goto PORT_SCAN
if "%option%"=="9" goto EDIT_CONFIG
if "%option%"=="10" goto SSH_KEY_SETUP
if "%option%"=="11" goto INSTALL_REQS
if "%option%"=="12" goto VERIFY_TOOLS
if "%option%"=="13" goto VIEW_LOGS
if "%option%"=="14" goto TROUBLESHOOT
if "%option%"=="15" goto CONFIGURE_SUDO

:WAKE_SERVER
call :LOG_ACTION "Iniciando Wake-on-LAN"
set "WOL_CMD=%BIN_DIR%\wolcmd.exe"
if not exist "%WOL_CMD%" (
    echo %RED%[!]%RESET% wolcmd.exe no encontrado
    echo Ejecute %YELLOW%'Instalar requisitos'%RESET% primero
    pause
    goto MENU_PRINCIPAL
)
echo Enviando paquete WoL a %MAC%...
"%WOL_CMD%" %MAC% %BROADCAST% %MASK% 9
if %errorlevel% equ 0 (
    echo %GREEN%[✓]%RESET% Paquete enviado con exito!
    call :LOG_ACTION "Paquete WoL enviado a %MAC%"
) else (
    echo %RED%[X]%RESET% Error al enviar paquete WoL
    call :LOG_ACTION "Error WoL (codigo %errorlevel%)"
)
timeout /t 3 >nul
goto MENU_PRINCIPAL

:SHUTDOWN
call :LOG_ACTION "Solicitando apagado remoto"
start "Apagando Servidor" cmd /c "%SCRIPTS_DIR%\server_control.bat" poweroff
goto MENU_PRINCIPAL

:REBOOT
call :LOG_ACTION "Solicitando reinicio remoto"
start "Reiniciando Servidor" cmd /c "%SCRIPTS_DIR%\server_control.bat" reboot
goto MENU_PRINCIPAL

:SUSPEND
call :LOG_ACTION "Solicitando suspension remota"
start "Suspender Servidor" cmd /c "%SCRIPTS_DIR%\server_control.bat" suspend
goto MENU_PRINCIPAL

:HIBERNATE
call :LOG_ACTION "Solicitando hibernacion remota"
start "Hibernar Servidor" cmd /c "%SCRIPTS_DIR%\server_control.bat" hibernate
goto MENU_PRINCIPAL

:PING_TEST
call :LOG_ACTION "Iniciando prueba de ping"
call "%SCRIPTS_DIR%\network_tests.bat" ping
goto MENU_PRINCIPAL

:IPERF_TEST
call :LOG_ACTION "Iniciando prueba iperf3"
call "%SCRIPTS_DIR%\network_tests.bat" iperf
goto MENU_PRINCIPAL

:PORT_SCAN
call :LOG_ACTION "Escaneo de puertos"
echo %YELLOW%[~]%RESET% Esta funcion requiere nmap instalado
call "%SCRIPTS_DIR%\network_tests.bat" scan
goto MENU_PRINCIPAL

:EDIT_CONFIG
call :LOG_ACTION "Editando configuracion"
call "%SCRIPTS_DIR%\config_editor.bat"
goto MENU_PRINCIPAL

:SSH_KEY_SETUP
call :LOG_ACTION "Configurando SSH sin contrasena"
call "%SCRIPTS_DIR%\server_control.bat" sshkeys
goto MENU_PRINCIPAL

:INSTALL_REQS
call :LOG_ACTION "Instalando requisitos"
call "%SCRIPTS_DIR%\install_tools.bat"
goto MENU_PRINCIPAL

:VERIFY_TOOLS
call :LOG_ACTION "Verificando dependencias"
call "%SCRIPTS_DIR%\install_tools.bat" verify
goto MENU_PRINCIPAL

:VIEW_LOGS
call :LOG_ACTION "Viendo logs"
explorer "%LOG_DIR%"
goto MENU_PRINCIPAL

:TROUBLESHOOT
call :LOG_ACTION "Soporte tecnico"
call "%SCRIPTS_DIR%\server_control.bat" troubleshoot
goto MENU_PRINCIPAL

:CONFIGURE_SUDO
call :LOG_ACTION "Configurando sudo sin contrasena"
call "%SCRIPTS_DIR%\server_control.bat" configuresudo
goto MENU_PRINCIPAL

:EXIT_PROGRAM
call :LOG_ACTION "Saliendo del programa"
exit /b 0

:LOAD_CONFIG
if exist "%SCRIPT_DIR%\config.ini" (
    for /f "tokens=1,2 delims==" %%A in (%SCRIPT_DIR%\config.ini) do (
        set "%%A=%%B"
    )
) else (
    echo Creando configuracion inicial...
    (
        echo IP=192.168.1.100
        echo BROADCAST=192.168.1.255
        echo MASK=255.255.255.0
        echo MAC=00:11:22:33:44:55
        echo SSH_USER=admin
        echo SSH_PORT=22
    ) > "%SCRIPT_DIR%\config.ini"
)
exit /b

:INIT_COLORS
for /F "delims=#" %%A in ('"prompt #$E# & for %%B in (1) do rem"') do set "ESC=%%A"
set "GREEN=%ESC%[92m"
set "RED=%ESC%[91m"
set "YELLOW=%ESC%[93m"
set "BLUE=%ESC%[94m"
set "CYAN=%ESC%[96m"
set "RESET=%ESC%[0m"
exit /b

:LOG_ACTION
set "LOG_FILE=%LOG_DIR%\%~n0_%DATE:/=%.log"
echo [%TIME%] - %* >> "%LOG_FILE%"
exit /b