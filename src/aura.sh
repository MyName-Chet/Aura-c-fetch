#!/bin/bash
# Aura-c-fetch Core Script (Ultimate Responsive & Fast)

# --- CONFIGURATION ---
IMG_PATH="$(dirname "$0")/../assets/logo.jpg"
ANIM_SPEED=0.03       # เร็วขึ้นอีกนิด
MOBILE_THRESHOLD=80   # ถ้าจอกว้างน้อยกว่านี้ จะเปลี่ยนเป็นแนวตั้งทันที
# ---------------------

# 1. เช็คขนาดหน้าจอปัจจุบันก่อนเลย (หัวใจของความ Responsive)
TERM_COLS=$(tput cols)
TERM_LINES=$(tput lines)

# =========================================
#  ZONE: GATHER DATA (รวบรวมข้อมูลให้เสร็จก่อนวาด จะได้เร็ว)
# =========================================

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

# เก็บใส่ตัวแปรให้หมด (Cache ไว้)
OS=$(get_os)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
SHELL_NAME=${SHELL##*/}
CPU=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | sed 's/^[ \t]*//')
MEM=$(free -h | awk '/Mem:/ { print $3 " / " $2 }')
DISK=$(df -h / | awk 'NR==2 { print $3 " / " $2 }')
GPU=$(get_gpu)

# =========================================
#  ZONE: RENDER ENGINE (คำนวณการวาด)
# =========================================

clear
tput civis # ซ่อน Cursor

# ฟังก์ชันวาดบาร์โหลด (ใช้ได้ทั้งแนวตั้งและแนวนอน)
draw_loading_bar() {
    local pad_left=$1
    local max_width=$2
    
    # คำนวณความกว้างบาร์ (ไม่ให้ทะลุจอ)
    # ถ้าจอเล็ก ให้ใช้ความกว้างจอ - 10, ถ้าจอใหญ่ fix ไว้ 30
    if [ "$max_width" -lt 40 ]; then
        BAR_W=$((max_width - 5))
    else
        BAR_W=30
    fi
    
    [ $BAR_W -lt 5 ] && BAR_W=5 # กันบั๊กบาร์เล็กเกิน

    for ((i=0; i<=BAR_W; i+=2)); do # เพิ่มทีละ 2 เพื่อความเร็ว
        PERCENT=$(( i * 100 / BAR_W ))
        FULL=$(printf "%0.s█" $(seq 1 $i))
        EMPTY=$(printf "%0.s░" $(seq 1 $((BAR_W - i))))
        
        tput cr
        [ "$pad_left" -gt 0 ] && tput cuf "$pad_left"
        echo -ne "\e[1;34m${FULL}\e[0;37m${EMPTY} \e[1;32m${PERCENT}%\e[0m"
        sleep $ANIM_SPEED
    done
    
    # Finish State
    tput cr
    [ "$pad_left" -gt 0 ] && tput cuf "$pad_left"
    FULL_BLOCK=$(printf "%0.s█" $(seq 1 $BAR_W))
    echo -e "\e[1;32m${FULL_BLOCK} READY\e[0m"
}

# --- DECISION LOGIC: เลือก Layout ---

if [ "$TERM_COLS" -lt "$MOBILE_THRESHOLD" ]; then
    # >>> MOBILE / PORTRAIT MODE (แนวตั้ง) <<<
    # วาดรูปไว้ข้างบน เต็มความกว้าง
    if command -v chafa &> /dev/null; then
        chafa "$IMG_PATH" --size "${TERM_COLS}x20" --align center
    fi
    echo "" # เว้นบรรทัด
    
    # ฟังก์ชันพิมพ์แบบชิดซ้ายปกติ
    p() { echo -e " $1"; }
    
    PAD=0 # ไม่ต้องดันขวา
    BAR_MAX=$TERM_COLS

else
    # >>> DESKTOP / LANDSCAPE MODE (แนวนอน) <<<
    # คำนวณขนาดรูป Dynamic (1/3 ของจอ แต่ไม่เกิน 40 ช่อง)
    IMG_W=$((TERM_COLS / 3))
    [ $IMG_W -gt 42 ] && IMG_W=42
    [ $IMG_W -lt 20 ] && IMG_W=20 # กันเล็กเกิน
    
    if command -v chafa &> /dev/null; then
        RAW_IMG=$(chafa "$IMG_PATH" --size "${IMG_W}x${IMG_W}")
    else
        RAW_IMG="[No Image]"
    fi
    
    IMG_H=$(echo "$RAW_IMG" | wc -l)
    
    echo "$RAW_IMG"
    tput cuu "$((IMG_H - 1))" # ดึงเคอร์เซอร์กลับ
    
    OFFSET=$((IMG_W + 4))
    
    # ฟังก์ชันพิมพ์แบบดันขวา
    p() { 
        tput cuf "$OFFSET"
        echo -e "$1" 
    }
    
    PAD=$OFFSET
    BAR_MAX=30
fi

# =========================================
#  ZONE: DISPLAY (แสดงผลจริง)
# =========================================

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

# เรียก Animation (ส่งค่าระยะห่างซ้ายไป)
draw_loading_bar "$PAD" "$BAR_MAX"

# Cleanup (ดันบรรทัดทิ้งท้าย)
if [ "$TERM_COLS" -ge "$MOBILE_THRESHOLD" ]; then
    # ถ้าโหมด Desktop ต้องคำนวณบรรทัดที่เหลือ
    USED_LINES=18
    REM=$((IMG_H - USED_LINES))
    if [ $REM -gt 0 ]; then
        for ((i=0; i<REM; i++)); do echo ""; done
    fi
fi

tput cnorm # คืนชีพ Cursor
echo -e "\n"