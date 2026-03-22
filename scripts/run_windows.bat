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
for %%f in ("%MODEL_DIR%\*.gguf") do (
    set /a i+=1
    set "model_!i!=%%~f"
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
echo.
echo  2] Maximum Mode
echo     - Uses ~4GB+ RAM. High context capacity.
echo.
choice /C 12 /N /M "Select mode (1 or 2): "
set "MODE_RESULT=%errorlevel%"

if "%MODE_RESULT%"=="2" (
    set "MODE_NAME=MAXIMUM"
    set "PARAMS=--ctx-size 16384 --parallel 2 --cache-type-k f16"
) else (
    set "MODE_NAME=LIGHTWEIGHT"
    set "PARAMS=--ctx-size 4096 --parallel 1 --cache-type-k f16"
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
echo  Loading... please wait.
echo.

:: Ensure no old instances are running
taskkill /F /IM kulit.llamafile >nul 2>&1

:: Clear old log
echo. > "%LOG_FILE%"

:: Start the server
start /b "" "%BIN_PATH%" -m "%SELECTED_MODEL%" --server --host %HOST% --port %PORT% ^
  --n-gpu-layers 0 --flash-attn off --no-mmap --threads 0 %PARAMS% > "%LOG_FILE%" 2>&1

:: --- LOADING ANIMATION ---
set "spinner=|/-\"
set /a "spin_idx=0"

:LOADING_LOOP
set "char=!spinner:~%spin_idx%,1!"
set /a "spin_idx=(spin_idx+1) %% 4"

:: Update Progress Line (using backspace trick for Windows)
<nul set /p "=."

:: Check if server is ready
:: Use a temporary copy of the log to avoid file locking issues
copy /y "%LOG_FILE%" "%LOG_FILE%.tmp" >nul 2>&1
findstr /C:"server is listening on" "%LOG_FILE%.tmp" >nul
if %errorlevel% equ 0 del "%LOG_FILE%.tmp" >nul 2>&1 & goto SUCCESS

findstr /C:"error" "%LOG_FILE%.tmp" >nul
if %errorlevel% equ 0 del "%LOG_FILE%.tmp" >nul 2>&1 & goto ERROR

:: Check if process is still running
tasklist /FI "IMAGENAME eq kulit.llamafile" | findstr "kulit.llamafile" >nul
if %errorlevel% neq 0 del "%LOG_FILE%.tmp" >nul 2>&1 & goto ERROR

:: Small delay
ping 127.0.0.1 -n 2 >nul
goto LOADING_LOOP

:SUCCESS
echo.
echo  [+] Server is READY!
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
echo  [!] ERROR: Server failed to start.
echo      Check 'server.log' for details.
pause
goto MENU
