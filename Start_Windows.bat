@echo off
setlocal
cd /d "%~dp0"

if exist "Kulit-App.exe" (
    start "" "Kulit-App.exe"
) else if exist "bin\llamafile.exe" (
    echo [!] GUI executable not found. Falling back to legacy CLI...
    call "scripts\legacy\run_windows.bat"
) else (
    echo [!] ERROR: Engine or GUI not found. Please extract all files.
    pause
)
