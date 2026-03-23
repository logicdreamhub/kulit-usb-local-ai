#!/bin/bash
# Move to the root directory
cd "$(dirname "$0")/.."

# --- CONFIGURATION ---
MODEL_DIR="models"
if [ -f "./bin/llamafile.exe" ]; then
    BIN_PATH="./bin/llamafile.exe"
elif [ -f "./bin/llamafile" ]; then
    BIN_PATH="./bin/llamafile"
else
    BIN_PATH="./bin/kulit.llamafile"
fi

HOST="0.0.0.0"
PORT="3690"
LOG_FILE="server.log"

# --- COLORS ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Set Terminal Title
echo -ne "\033]0;Kulit Server\007"

chmod +x "$BIN_PATH" 2>/dev/null

stop_server() {
    if [ ! -z "$SERVER_PID" ]; then
        kill $SERVER_PID 2>/dev/null
        sleep 0.5
        kill -9 $SERVER_PID 2>/dev/null
        pkill -f "llamafile" 2>/dev/null
    fi
}

trap stop_server EXIT

while true; do
    clear
    echo -e "${CYAN}==========================================================${NC}"
    echo -e "${CYAN}   KULIT LLAMAFILE - MODEL SELECTOR${NC}"
    echo -e "${CYAN}==========================================================${NC}"
    echo ""

    shopt -s nullglob
    models=($MODEL_DIR/*.gguf)

    if [ ${#models[@]} -eq 0 ]; then
        echo -e "${RED}[!] ERROR: No .gguf models found in /$MODEL_DIR/${NC}"
        read -p "Press Enter to exit..."
        exit 1
    fi

    echo -e "[AVAILABLE MODELS]"
    for i in "${!models[@]}"; do
        echo -e "$((i+1))] $(basename "${models[$i]}")"
    done
    echo -e "q] Quit"

    echo ""
    printf "Select a model (1-${#models[@]}): "
    read choice
    [[ "$choice" == "q" ]] && exit 0
    idx=$((choice-1))
    [[ -z "${models[$idx]}" || $choice -lt 1 ]] && continue
    SELECTED_MODEL="${models[$idx]}"
    MODEL_NAME=$(basename "$SELECTED_MODEL")

    # --- MODE SELECTION ---
    clear
    echo -e "${CYAN}==========================================================${NC}"
    echo -e "${CYAN}   SELECT PERFORMANCE MODE${NC}"
    echo -e "${CYAN}==========================================================${NC}"
    echo ""
    echo -e "${GREEN}1] Lightweight Mode${NC} (Recommended)"
    echo -e "   - Uses ~500MB RAM. Fast & snappy."
    echo -e ""
    echo -e "${MAGENTA}2] Maximum Mode${NC}"
    echo -e "   - Uses ~4GB+ RAM. High context capacity."
    echo -e ""
    printf "Select mode (1 or 2): "
    read mode_choice

    if [[ "$mode_choice" == "2" ]]; then
        MODE_NAME="MAXIMUM"
        # v0.10.0 flags
        PARAMS="--ctx-size 16384 --parallel 2 --cache-type-k f16"
    else
        MODE_NAME="LIGHTWEIGHT"
        # v0.10.0 flags
        PARAMS="--ctx-size 4096 --parallel 1 --cache-type-k f16"
    fi

    clear
    echo -e "${CYAN}==========================================================${NC}"
    echo -e "${CYAN}   INITIALIZING KULIT SERVER ($MODE_NAME MODE)${NC}"
    echo -e "${CYAN}==========================================================${NC}"
    echo ""
    echo -e "${GREEN}Engine: ${NC} $BIN_PATH"
    echo -e "${GREEN}Model:  ${NC} $MODEL_NAME"
    echo -e "${GREEN}URL:    ${NC} http://$HOST:$PORT"
    echo ""
    echo -e "${YELLOW}Loading model... please wait.${NC}"

    > "$LOG_FILE"
    
    # v0.10.0 Optimized Flags:
    # --gpu disable       : Force CPU only
    # --flash-attn off    : Prevent scale crashes
    # --no-warmup         : Skip initial math test
    # --numa distribute   : Better CPU thread stability
    "$BIN_PATH" --server -m "$SELECTED_MODEL" --host "$HOST" --port "$PORT" \
      --gpu disable \
      --flash-attn off \
      --no-warmup \
      --numa distribute \
      --threads 0 $PARAMS > "$LOG_FILE" 2>&1 &
      
    SERVER_PID=$!

    spin='-\|/'
    i=0
    while ! grep -q "server is listening on" "$LOG_FILE" && kill -0 $SERVER_PID 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${CYAN}[${spin:$i:1}] Loading Environment... [##########----------] 50%%${NC}"
        sleep 0.2
    done

    if kill -0 $SERVER_PID 2>/dev/null; then
        printf "\r${GREEN}[+] Server is READY!      [####################] 100%%${NC}\n"
        [[ "$OSTYPE" == "darwin"* ]] && open "http://$HOST:$PORT" || { command -v xdg-open > /dev/null && xdg-open "http://$HOST:$PORT"; }
        echo ""
        echo -e "   [S] Stop Server & Exit"
        while true; do
            read -n 1 -r opt
            [[ $opt == [Ss]* ]] && { echo -e "\nStopping..."; stop_server; exit 0; }
        done
    else
        echo -e "\n${RED}[!] ERROR: Failed to start the server.${NC}"
        if grep -q "assert(fabsf(fval) <= 4194303.f)" "$LOG_FILE"; then
            echo -e "${YELLOW}"
            echo -e "  [!] HARDWARE INCOMPATIBILITY DETECTED:"
            echo -e "  The model \"$MODEL_NAME\" uses advanced quantization"
            echo -e "  that is not fully supported by your computer's processor."
            echo -e ""
            echo -e "  SOLUTION:"
            echo -e "  Please use a 'Q4_0' or 'Q8_0' version of this model instead."
            echo -e "${NC}"
        else
            echo -e "  Please check 'server.log' for details."
        fi
        read -p "Press Enter..."
    fi
done
