@echo off
:: Move to the directory where this script is located
cd /d "%~dp0"
:: Launch the main script in a new window
start "" cmd /c "scripts\run_windows.bat"
