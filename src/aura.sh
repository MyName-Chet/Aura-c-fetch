#!/bin/bash
# Aura-c-fetch Core Script

# ตั้งค่าตำแหน่งรูปภาพสัมพันธ์กับตำแหน่งสคริปต์
IMG_PATH="$(dirname "$0")/../assets/logo.jpg"

# ฟังก์ชันดึงข้อมูลระบบ
get_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1
    else
        echo "Integrated Graphics"
    fi
}

# รวบรวมข้อมูล
OS=$(lsb_release -ds)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
SHELL_NAME=$SHELL
CPU=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | sed 's/  *//g')
MEM=$(free -h | awk '/Mem:/ { print $3 " / " $2 }')
DISK=$(df -h / | awk 'NR==2 { print $3 " / " $2 " (" $5 ")" }')

# ล้างหน้าจอแล้วเริ่มวาด
clear
chafa "$IMG_PATH" --size 40x20

# จัดตำแหน่งข้อความไปทางขวา 42 ช่อง และขึ้นไป 20 บรรทัด
tput cuu 20
print_info() {
    tput cuf 42
    echo -e "$1"
}

print_info "\e[1;36mSYSTEM IDENTITY\e[0m"
print_info "----------------------------------------"
print_info "\e[1;34mOS      \e[0m | $OS"
print_info "\e[1;34mKERNEL  \e[0m | $KERNEL"
print_info "\e[1;34mUPTIME  \e[0m | $UPTIME"
print_info "\e[1;34mSHELL   \e[0m | $SHELL_NAME"
print_info "----------------------------------------"
print_info ""
print_info "\e[1;35mHARDWARE SPECS\e[0m"
print_info "----------------------------------------"
print_info "\e[1;33mCPU     \e[0m | $CPU"
print_info "\e[1;33mGPU     \e[0m | $(get_gpu)"
print_info "\e[1;33mMEMORY  \e[0m | $MEM"
print_info "\e[1;33mDISK    \e[0m | $DISK"
print_info "----------------------------------------"
print_info ""
print_info "\e[41m  \e[0m \e[42m  \e[0m \e[43m  \e[0m \e[44m  \e[0m \e[45m  \e[0m \e[46m  \e[0m \e[47m  \e[0m"

# จบการทำงาน
echo -e "\n\n"