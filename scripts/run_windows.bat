@echo off
setlocal enabledelayedexpansion
title Kulit Server
color 0B

cd /d "%~dp0.."

:: --- CONFIGURATION ---
set "MODEL_DIR=models"
set "HOST=127.0.0.1"
set "PORT=3690"
set "LOG_FILE=server.log"

:: NEW ENGINE LOGIC: Look for llamafile.exe first
if exist "bin\llamafile.exe" (
    set "BIN_PATH=bin\llamafile.exe"
) else (
    set "BIN_PATH=bin\kulit.llamafile"
)

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
echo.
echo  2] Maximum Mode
echo.
choice /C 12 /N /M "Select mode (1 or 2): "
set "MODE_RESULT=%errorlevel%"

if "%MODE_RESULT%"=="2" (
    set "MODE_NAME=MAXIMUM"
    set "PARAMS=--ctx-size 8192 --parallel 1 --batch-size 256"
) else (
    set "MODE_NAME=LIGHTWEIGHT"
    set "PARAMS=--ctx-size 2048 --parallel 1 --batch-size 128"
)

cls
echo.
echo  ==========================================================
echo     INITIALIZING KULIT SERVER (%MODE_NAME% MODE)
echo  ==========================================================
echo.
echo  Engine: %BIN_PATH%
echo  Model:  %MODEL_NAME%
echo.
echo  Loading... please wait.
echo.

taskkill /F /IM llamafile.exe >nul 2>&1
taskkill /F /IM kulit.llamafile >nul 2>&1

echo. > "%LOG_FILE%"

:: WINDOWS STABILITY ENVIRONMENT (llamafile 0.10.0+):
:: These environment variables tell the engine to avoid buggy math kernels
set GGML_NO_AVX_VNNI=1
set GGML_NO_AVX2=1
set GGML_NO_AVX=1
set GGML_NO_FMA=1
set GGML_NO_F16C=1

set LLAMA_CPP_NO_AVX_VNNI=1
set LLAMA_CPP_NO_AVX2=1
set LLAMA_CPP_NO_AVX=1
set LLAMA_CPP_NO_FMA=1
set LLAMA_CPP_NO_F16C=1

:: WINDOWS SAFETY FLAGS:
:: --no-mmap         : Prevents Windows file-locking/math read errors
:: --no-warmup       : Skips the initial math test that causes the crash
:: --gpu disable     : Forces CPU mode
:: --flash-attn off  : Mandatory for CPU stability
:: --numa distribute : Helps with memory-to-thread affinity stability
:: --cache-type-k f32: Bypasses buggy quantization math
:: --cache-type-v f32: Bypasses buggy quantization math
start /b "" "%BIN_PATH%" --server -m "%SELECTED_MODEL%" --host %HOST% --port %PORT% ^
  --gpu disable ^
  --flash-attn off ^
  --no-warmup ^
  --no-mmap ^
  --numa distribute ^
  --cache-type-k f32 ^
  --cache-type-v f32 ^
  --threads 4 %PARAMS% > "%LOG_FILE%" 2>&1

:: --- LOADING ---
set "spinner=|/-\"
set /a "spin_idx=0"
:LOADING_LOOP
set "char=!spinner:~%spin_idx%,1!"
set /a "spin_idx=(spin_idx+1) %% 4"
<nul set /p "=."
copy /y "%LOG_FILE%" "%LOG_FILE%.tmp" >nul 2>&1
findstr /C:"server is listening on" "%LOG_FILE%.tmp" >nul
if %errorlevel% equ 0 del "%LOG_FILE%.tmp" >nul 2>&1 & goto SUCCESS
findstr /C:"error" "%LOG_FILE%.tmp" >nul
if %errorlevel% equ 0 del "%LOG_FILE%.tmp" >nul 2>&1 & goto ERROR
ping 127.0.0.1 -n 2 >nul
goto LOADING_LOOP

:SUCCESS
echo.
echo  [+] Server is READY!
echo.
start http://%HOST%:%PORT%
echo  ----------------------------------------------------------
echo     SUCCESS: Server is running!
echo  ----------------------------------------------------------
echo.
echo     [S] Stop Server ^& Exit
choice /C S /N /M "Select option (S): "
if %errorlevel% equ 1 (
    taskkill /F /IM llamafile.exe >nul 2>&1
    taskkill /F /IM kulit.llamafile >nul 2>&1
    exit /b
)

:ERROR
echo.
color 0C
echo  [!] ERROR: Failed to start the server.
findstr /C:"assert(fabsf(fval) <= 4194303.f)" "%LOG_FILE%" >nul
if %errorlevel% equ 0 (
    echo.
    echo  [!] HARDWARE INCOMPATIBILITY DETECTED:
    echo  The model "%MODEL_NAME%" uses advanced quantization
    echo  that is not fully supported by your computer's processor.
    echo.
    echo  SOLUTION:
    echo  Please use a 'Q4_0' or 'Q8_0' version of this model instead.
    echo.
) else (
    echo  Please check 'server.log' for details.
)
pause
goto MENU
