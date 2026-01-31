#!/bin/bash
# Aura-c-fetch Core Script (Overlay Fix)
# Author: Oatsadawut Phansalee (MyName-Chet)

# --- CONFIGURATION ---
if [ -f "$(dirname "$0")/../assets/logo.jpg" ]; then
    IMG_PATH="$(dirname "$0")/../assets/logo.jpg"
elif [ -f "/usr/local/share/aura-c-fetch/logo.jpg" ]; then
    IMG_PATH="/usr/local/share/aura-c-fetch/logo.jpg"
else
    IMG_PATH=""
fi
ANIM_SPEED=0.03
# ---------------------

TERM_COLS=$(tput cols)

# =========================
#  ZONE: DATA GATHERING
# =========================
get_os() {
    if command -v lsb_release &> /dev/null; then lsb_release -ds
    elif [ -f /etc/os-release ]; then grep PRETTY_NAME /etc/os-release | cut -d'"' -f2
    else uname -o; fi
}
get_gpu() {
    if command -v nvidia-smi &> /dev/null; then nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1
    elif command -v lspci &> /dev/null; then lspci | grep -i 'vga\|3d' | cut -d ':' -f3 | sed 's/.*\[//;s/\].*//' | head -n 1
    else echo "Integrated/Unknown"; fi
}

OS=$(get_os)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
SHELL_NAME=${SHELL##*/}
CPU=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | sed 's/^[ \t]*//')
MEM=$(free -h | awk '/Mem:/ { print $3 " / " $2 }')
DISK=$(df -h / | awk 'NR==2 { print $3 " / " $2 }')
GPU=$(get_gpu)

# =========================
#  ZONE: RENDER LOGIC
# =========================
clear
tput civis 

draw_loading_bar() {
    local pad_left=$1
    local max_width=$2
    if [ "$max_width" -lt 40 ]; then BAR_W=$((max_width - 5)); else BAR_W=30; fi
    [ $BAR_W -lt 5 ] && BAR_W=5
    for ((i=0; i<=BAR_W; i+=2)); do
        PERCENT=$(( i * 100 / BAR_W ))
        FULL=$(printf "%0.s█" $(seq 1 $i))
        EMPTY=$(printf "%0.s░" $(seq 1 $((BAR_W - i))))
        tput cr; [ "$pad_left" -gt 0 ] && tput cuf "$pad_left"
        echo -ne "\e[1;34m${FULL}\e[0;37m${EMPTY} \e[1;32m${PERCENT}%\e[0m"
        sleep $ANIM_SPEED
    done
    tput cr; [ "$pad_left" -gt 0 ] && tput cuf "$pad_left"
    FULL_BLOCK=$(printf "%0.s█" $(seq 1 $BAR_W))
    echo -e "\e[1;32m${FULL_BLOCK} READY\e[0m"
}

# --- SMART LAYOUT CALCULATION ---
# เช็คความยาวสูงสุดของ Text (เพื่อดูว่าจะชนรูปไหม)
LONGEST_LINE=50 # ประมาณการคร่าวๆ
REQUIRED_WIDTH=$(( 42 + LONGEST_LINE + 2 )) # รูปกว้าง 42 + ข้อความ + ช่องว่าง

# ถ้าจอเล็กกว่าความต้องการ หรือเล็กกว่า 90 ช่อง -> บังคับ Mobile Mode
if [ "$TERM_COLS" -lt "$REQUIRED_WIDTH" ] || [ "$TERM_COLS" -lt 90 ]; then
    # >>> MOBILE MODE (Vertical) <<<
    # วาดรูปไว้บน (ลดขนาดรูปลงหน่อยเพื่อให้พอดี)
    if command -v chafa &> /dev/null && [ -n "$IMG_PATH" ]; then
        # ใช้ความกว้างจอ - 4 เพื่อความปลอดภัย
        IMG_SAFE_W=$((TERM_COLS - 4))
        [ $IMG_SAFE_W -gt 40 ] && IMG_SAFE_W=40
        chafa "$IMG_PATH" --size "${IMG_SAFE_W}x20" --align center
    fi
    echo "" 
    p() { echo -e " $1"; }
    PAD=0; BAR_MAX=$TERM_COLS
else
    # >>> DESKTOP MODE (Side-by-Side) <<<
    if command -v chafa &> /dev/null && [ -n "$IMG_PATH" ]; then
        RAW_IMG=$(chafa "$IMG_PATH" --size "42x42")
    else
        RAW_IMG=""
    fi
    IMG_H=$(echo "$RAW_IMG" | wc -l)
    echo "$RAW_IMG"
    tput cuu "$((IMG_H - 1))" 
    
    OFFSET=46 # 42 (รูป) + 4 (padding)
    p() { tput cuf "$OFFSET"; echo -e "$1"; }
    PAD=$OFFSET; BAR_MAX=30
fi

# =========================
#  ZONE: DISPLAY
# =========================
p "\e[1;36mSYSTEM IDENTITY\e[0m"
p "----------------------------------------"
p "\e[1;34mOS      \e[0m | $OS"
p "\e[1;34mKERNEL  \e[0m | $KERNEL"
p "\e[1;34mUPTIME  \e[0m | $UPTIME"
p "\e[1;34mSHELL   \e[0m | $SHELL_NAME"
p "----------------------------------------"
p ""
p "\e[1;35mHARDWARE SPECS\e[0m"
p "----------------------------------------"
p "\e[1;33mCPU     \e[0m | $CPU"
p "\e[1;33mGPU     \e[0m | $GPU"
p "\e[1;33mMEMORY  \e[0m | $MEM"
p "\e[1;33mDISK    \e[0m | $DISK"
p "----------------------------------------"
p ""
p "\e[41m  \e[0m \e[42m  \e[0m \e[43m  \e[0m \e[44m  \e[0m \e[45m  \e[0m \e[46m  \e[0m \e[47m  \e[0m"
p ""

draw_loading_bar "$PAD" "$BAR_MAX"

# Cleanup cursor position
if [ "$TERM_COLS" -ge 90 ]; then
    USED_LINES=18
    REM=$((IMG_H - USED_LINES))
    if [ $REM -gt 0 ]; then
        for ((i=0; i<REM; i++)); do echo ""; done
    fi
fi

tput cnorm
echo -e "\n"