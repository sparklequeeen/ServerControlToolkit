@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0.."

if exist "%SCRIPT_DIR%\config.ini" (
    for /f "tokens=1,2 delims==" %%A in (%SCRIPT_DIR%\config.ini) do (
        set "%%A=%%B"
    )
)

:CONFIG_MENU
cls
echo %YELLOW%===== EDITOR DE CONFIGURACION =====%RESET%
echo 1) IP servidor: %IP%
echo 2) Direccion broadcast: %BROADCAST%
echo 3) Mascara de red: %MASK%
echo 4) MAC servidor: %MAC%
echo 5) Usuario SSH: %SSH_USER%
echo 6) Puerto SSH: %SSH_PORT%
echo 7) %GREEN%Guardar y salir%RESET%
echo 0) Salir sin guardar
echo %YELLOW%====================================%RESET%

set "valid_options=0 1 2 3 4 5 6 7"
:GET_CHOICE
set "choice="
set /p "choice=➤ Seleccione campo (0-7): "

if "%choice%"=="" goto GET_CHOICE

echo %valid_options% | findstr /i "\<%choice%\>" >nul
if %errorlevel% neq 0 (
    echo %RED%[!]%RESET% Opcion invalida!
    timeout /t 1 >nul
    goto GET_CHOICE
)

if "%choice%"=="0" exit /b
if "%choice%"=="7" goto SAVE_CONFIG

set /p "new_val=Nuevo valor: "
if "%choice%"=="1" set "IP=!new_val!"
if "%choice%"=="2" set "BROADCAST=!new_val!"
if "%choice%"=="3" set "MASK=!new_val!"
if "%choice%"=="4" set "MAC=!new_val!"
if "%choice%"=="5" set "SSH_USER=!new_val!"
if "%choice%"=="6" set "SSH_PORT=!new_val!"
goto CONFIG_MENU

:SAVE_CONFIG
(
    echo IP=%IP%
    echo BROADCAST=%BROADCAST%
    echo MASK=%MASK%
    echo MAC=%MAC%
    echo SSH_USER=%SSH_USER%
    echo SSH_PORT=%SSH_PORT%
) > "%SCRIPT_DIR%\config.ini"
echo %GREEN%[✓]%RESET% Configuracion guardada!
timeout /t 2 >nul
exit /b