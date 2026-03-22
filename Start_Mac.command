#!/bin/bash
# Move to script folder
cd "$(dirname "$0")"
# Fix permissions silently
chmod +x scripts/run_unix.sh bin/kulit.llamafile 2>/dev/null
# Run
./scripts/run_unix.sh
