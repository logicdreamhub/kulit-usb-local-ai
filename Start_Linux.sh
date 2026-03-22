#!/bin/bash
cd "$(dirname "$0")"
chmod +x scripts/run_unix.sh bin/kulit.llamafile 2>/dev/null
./scripts/run_unix.sh
