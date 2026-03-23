#!/bin/bash
cd "$(dirname "$0")"

if [ -f "./Kulit-App" ]; then
    chmod +x ./Kulit-App 2>/dev/null
    ./Kulit-App
elif [ -f "scripts/legacy/run_unix.sh" ]; then
    echo "[!] GUI app not found. Falling back to legacy CLI..."
    chmod +x ./scripts/legacy/run_unix.sh 2>/dev/null
    ./scripts/legacy/run_unix.sh
else
    echo "[!] ERROR: GUI application not found."
    read -p "Press Enter to exit..."
fi
