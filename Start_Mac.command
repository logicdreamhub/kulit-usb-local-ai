#!/bin/bash
cd "$(dirname "$0")"

# Fix permissions for the engine and app
chmod +x ./Kulit-App bin/kulit.llamafile 2>/dev/null

if [ -d "Kulit-App.app" ]; then
    echo "[+] Launching Kulit AI Desktop..."
    open "Kulit-App.app"
elif [ -f "Kulit-App" ]; then
    # Note: The Linux binary won't run on Mac, but we check just in case they have a Mac build
    echo "[+] Launching Kulit AI..."
    ./Kulit-App
elif [ -f "scripts/legacy/run_unix.sh" ]; then
    echo "[!] GUI application not found for Mac."
    echo "[*] Falling back to CLI Mode..."
    echo ""
    chmod +x ./scripts/legacy/run_unix.sh 2>/dev/null
    ./scripts/legacy/run_unix.sh
else
    echo "[!] ERROR: GUI application and legacy scripts not found."
    echo "Please ensure you have extracted all files from the download."
    read -p "Press Enter to exit..."
fi
