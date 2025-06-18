@echo off
setlocal

set "SCRIPT_DIR=%~dp0.."
set "BIN_DIR=%SCRIPT_DIR%\bin"

if "%~1"=="verify" goto VERIFY

echo %YELLOW%[~]%RESET% Instalando herramientas...
echo.

REM Descargar wolcmd.exe si no existe
if not exist "%BIN_DIR%\wolcmd.exe" (
    echo Descargando wolcmd.exe...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.depicus.com/downloads/wolcmd.zip' -OutFile '%TEMP%\wolcmd.zip'"
    powershell -Command "Expand-Archive -Path '%TEMP%\wolcmd.zip' -DestinationPath '%BIN_DIR%' -Force"
    del /Q "%TEMP%\wolcmd.zip"
    echo %GREEN%[✓]%RESET% wolcmd.exe instalado
) else (
    echo %CYAN%[i]%RESET% wolcmd.exe ya existe
)

REM Descargar plink.exe si no existe
if not exist "%BIN_DIR%\plink.exe" (
    echo Descargando plink.exe...
    powershell -Command "Invoke-WebRequest -Uri 'https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe' -OutFile '%BIN_DIR%\plink.exe'"
    echo %GREEN%[✓]%RESET% plink.exe instalado
) else (
    echo %CYAN%[i]%RESET% plink.exe ya existe
)

REM Verificar si plink funciona
if exist "%BIN_DIR%\plink.exe" (
    "%BIN_DIR%\plink.exe" -V >nul 2>&1
    if %errorlevel% neq 0 (
        echo %YELLOW%[!]%RESET% Descargando versión alternativa de plink...
        powershell -Command "Invoke-WebRequest -Uri 'https://the.earth.li/~sgtatham/putty/latest/w32/plink.exe' -OutFile '%BIN_DIR%\plink.exe'"
    )
)

echo %GREEN%[✓]%RESET% Instalacion completada!
timeout /t 2 >nul
exit /b

:VERIFY
echo %YELLOW%[~]%RESET% Verificando dependencias...
echo.

set "missing=0"

if not exist "%BIN_DIR%\wolcmd.exe" (
    echo %RED%[X]%RESET% wolcmd.exe no encontrado
    set /a missing+=1
)

if not exist "%BIN_DIR%\plink.exe" (
    echo %RED%[X]%RESET% plink.exe no encontrado
    set /a missing+=1
) else (
    "%BIN_DIR%\plink.exe" -V >nul 2>&1
    if %errorlevel% neq 0 (
        echo %RED%[X]%RESET% plink.exe no funciona correctamente
        set /a missing+=1
    )
)

where ssh >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%[X]%RESET% Cliente SSH (OpenSSH) no instalado
    set /a missing+=1
)

where iperf3 >nul 2>&1
if %errorlevel% neq 0 (
    echo %YELLOW%[!]%RESET% iperf3 no encontrado (requerido para pruebas locales)
)

where nmap >nul 2>&1
if %errorlevel% neq 0 (
    echo %YELLOW%[!]%RESET% nmap no encontrado (requerido para escaneo de puertos)
    echo    Descargar e instalar: https://nmap.org/download.html
    echo    Durante instalacion, marcar: "Add nmap to my PATH"
)

if %missing% equ 0 (
    echo %GREEN%[✓]%RESET% Dependencias principales presentes!
) else (
    echo %RED%[X]%RESET% %missing% dependencias faltantes
)

timeout /t 3 >nul
exit /b