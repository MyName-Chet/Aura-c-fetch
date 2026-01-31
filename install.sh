#!/bin/bash
# Aura-c-fetch Installer (Rewritten)

echo -e "\e[1;36m>> Starting Aura-c-fetch Installation...\e[0m"

# 1. ติดตั้ง Chafa (รองรับหลาย Distro: Debian/Ubuntu, Arch, Fedora)
if ! command -v chafa &> /dev/null; then
    echo ">> Installing chafa tool..."
    
    if [ -f /etc/debian_version ]; then
        # สำหรับ Ubuntu / Debian / Mint
        sudo apt update && sudo apt install chafa -y
    elif [ -f /etc/arch-release ]; then
        # สำหรับ Arch Linux / Manjaro
        sudo pacman -S --noconfirm chafa
    elif [ -f /etc/fedora-release ]; then
        # สำหรับ Fedora
        sudo dnf install -y chafa
    else
        echo -e "\e[1;33m!! Warning: Could not detect package manager. Please install 'chafa' manually.\e[0m"
    fi
else
    echo ">> chafa is already installed."
fi

# 2. แก้สิทธิ์การรันให้สคริปต์หลัก
if [ -f "src/aura.sh" ]; then
    chmod +x src/aura.sh
    echo ">> Permission granted to src/aura.sh"
else
    echo -e "\e[1;31m!! Error: src/aura.sh not found. Make sure you are in the correct directory.\e[0m"
fi

echo -e "\e[1;32m>> Installation Complete! Run with: ./src/aura.sh\e[0m"