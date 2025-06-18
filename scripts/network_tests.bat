@echo off
setlocal

set "SCRIPT_DIR=%~dp0.."
set "LOG_DIR=%SCRIPT_DIR%\logs"

REM Cargar configuracion
if exist "%SCRIPT_DIR%\config.ini" (
    for /f "tokens=1,2 delims==" %%A in (%SCRIPT_DIR%\config.ini) do (
        set "%%A=%%B"
    )
)

if "%~1"=="ping" goto PING
if "%~1"=="iperf" goto IPERF
if "%~1"=="scan" goto SCAN

echo Uso: network_tests.bat [ping|iperf|scan]
exit /b

:PING
echo %YELLOW%[~]%RESET% Probando conectividad con %IP%...
ping -n 4 %IP%
if %errorlevel% equ 0 (
    echo %GREEN%[✓]%RESET% Servidor responde correctamente
) else (
    echo %RED%[X]%RESET% El servidor no responde
)
pause
exit /b

:IPERF
echo %YELLOW%[~]%RESET% Iniciando prueba iperf3...
echo Iniciando servidor remoto...
start "" /B ssh -p %SSH_PORT% %SSH_USER%@%IP% "iperf3 -s -1 > iperf.log 2>&1"
timeout /t 2 >nul

echo Ejecutando cliente local...
iperf3 -c %IP% -t 10
if %errorlevel% equ 0 (
    echo %GREEN%[✓]%RESET% Prueba completada con exito
) else (
    echo %RED%[X]%RESET% Error en la prueba iperf3
)

echo Deteniendo servidor remoto...
ssh -p %SSH_PORT% %SSH_USER%@%IP% "pkill iperf3"
pause
exit /b

:SCAN
echo %YELLOW%[~]%RESET% Escaneo basico de puertos...
echo %CYAN%[i]%RESET% Esta funcion requiere nmap instalado localmente
where nmap >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[X]%RESET% nmap no esta instalado.
    echo.
    echo %YELLOW%[!]%RESET% Instrucciones para instalar nmap:
    echo 1. Descargue el instalador: https://nmap.org/download.html
    echo 2. Ejecute el archivo .exe
    echo 3. Durante la instalacion, marque "Add nmap to my PATH"
    echo 4. Despues de instalar, verifique con: nmap --version
    echo 5. Vuelva a ejecutar esta opcion
    pause
    exit /b
)
echo %GREEN%[✓]%RESET% Iniciando escaneo en %IP%...
nmap -Pn -F %IP%
pause
exit /b