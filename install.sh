#!/bin/bash
# Aura-c-fetch System Installer

echo -e "\e[1;36m>> Starting Aura-c-fetch System Installation...\e[0m"

# 1. เช็คและติดตั้ง Chafa
if ! command -v chafa &> /dev/null; then
    echo ">> Installing dependency: chafa..."
    if [ -f /etc/debian_version ]; then sudo apt update && sudo apt install chafa -y
    elif [ -f /etc/arch-release ]; then sudo pacman -S --noconfirm chafa
    elif [ -f /etc/fedora-release ]; then sudo dnf install -y chafa
    else echo -e "\e[1;33m!! Warning: Please install 'chafa' manually.\e[0m"; fi
fi

# 2. สร้างโฟลเดอร์เก็บรูปใน System
echo ">> Setting up system directories..."
sudo mkdir -p /usr/local/share/aura-c-fetch

# 3. ก๊อปปี้รูปไปใส่
echo ">> Copying assets..."
if [ -f "assets/logo.jpg" ]; then
    sudo cp assets/logo.jpg /usr/local/share/aura-c-fetch/
else
    echo -e "\e[1;31m!! Error: assets/logo.jpg not found.\e[0m"
    exit 1
fi

# 4. ติดตั้งตัวโปรแกรม (เปลี่ยนชื่อจาก aura.sh -> aura)
echo ">> Installing executable..."
if [ -f "src/aura.sh" ]; then
    sudo cp src/aura.sh /usr/local/bin/aura
    sudo chmod +x /usr/local/bin/aura
    echo -e "\e[1;32m>> Success! Installed as 'aura'\e[0m"
else
    echo -e "\e[1;31m!! Error: src/aura.sh not found.\e[0m"
    exit 1
fi

echo -e "\n\e[1;32mDONE! You can now run 'aura' from anywhere in your terminal.\e[0m"
echo -e "Try typing: \e[1;37maura\e[0m"