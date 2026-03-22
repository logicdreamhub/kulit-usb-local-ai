@echo off
setlocal enabledelayedexpansion
title Kulit Server
color 0B

cd /d "%~dp0.."

:: --- CONFIGURATION ---
set "MODEL_DIR=models"
set "BIN_PATH=bin\kulit.llamafile"
set "HOST=127.0.0.1"
set "PORT=3690"
set "LOG_FILE=server.log"

:MENU
cls
echo.
echo  ==========================================================
echo     KULIT LLAMAFILE - MODEL SELECTOR
echo  ==========================================================
echo.
echo  [AVAILABLE MODELS]
set i=0
for %%f in (%MODEL_DIR%\*.gguf) do (
    set /a i+=1
    set "model_!i!=%%f"
    echo  !i!] %%~nxf
)
echo  q] Quit

echo.
set /p choice="Select a model (1-%i%): "
if /i "%choice%"=="q" exit /b
if not defined model_%choice% goto MENU
set "SELECTED_MODEL=!model_%choice%!"
for %%A in ("%SELECTED_MODEL%") do set "MODEL_NAME=%%~nxA"

:: --- MODE SELECTION ---
cls
echo.
echo  ==========================================================
echo     SELECT PERFORMANCE MODE
echo  ==========================================================
echo.
echo  1] Lightweight Mode (Recommended)
echo     - Uses ~500MB RAM. Fast ^& snappy.
echo     - Ideal for quick chats and basic tasks.
echo.
echo  2] Maximum Mode
echo     - Uses ~4GB+ RAM. High context capacity.
echo     - Best for long documents and complex logic.
echo.
choice /C 12 /N /M "Select mode (1 or 2): "
set "MODE_RESULT=%errorlevel%"

if "%MODE_RESULT%"=="2" (
    set "MODE_NAME=MAXIMUM"
    set "PARAMS=--ctx-size 16384 --parallel 2 --cache-type-k f16"
) else (
    set "MODE_NAME=LIGHTWEIGHT"
    set "PARAMS=--ctx-size 4096 --parallel 1 --cache-type-k q8_0"
)

cls
echo.
echo  ==========================================================
echo     INITIALIZING KULIT SERVER (%MODE_NAME% MODE)
echo  ==========================================================
echo.
echo  Model: %MODEL_NAME%
echo  URL:   http://%HOST%:%PORT%
echo.
echo  Optimizing memory... loading model.
echo.

echo. > "%LOG_FILE%"
start /b "" "%BIN_PATH%" -m "%SELECTED_MODEL%" --server --host %HOST% --port %PORT% ^
  --n-gpu-layers 0 --flash-attn on --cont-batching --threads 0 %PARAMS% > "%LOG_FILE%" 2>&1

:: --- LOADING ---
set "spinner=|/-\"
set /a "spin_idx=0"
:LOADING_LOOP
set "char=!spinner:~%spin_idx%,1!"
set /a "spin_idx=(spin_idx+1) %% 4"
<nul set /p "=^r [%char%] Loading Environment... [##########----------] 50%%"
findstr /C:"server is listening on" "%LOG_FILE%" >nul
if %errorlevel% equ 0 goto SUCCESS
findstr /C:"error" "%LOG_FILE%" >nul
if %errorlevel% equ 0 goto ERROR
ping 127.0.0.1 -n 1 -w 500 >nul
goto LOADING_LOOP

:SUCCESS
echo.
echo  [+] Server is READY!      [####################] 100%%
echo.
start http://%HOST%:%PORT%
echo  ----------------------------------------------------------
echo     SUCCESS: Server is running in %MODE_NAME% mode!
echo  ----------------------------------------------------------
echo.
echo     [S] Stop Server ^& Exit
choice /C S /N /M "Select option (S): "
if %errorlevel% equ 1 (
    taskkill /F /IM kulit.llamafile >nul 2>&1
    exit /b
)

:ERROR
echo.
color 0C
echo  [!] ERROR: Check 'server.log'
pause
goto MENU
