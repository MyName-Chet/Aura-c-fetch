#!/bin/bash
# Aura-c-fetch Installer

echo -e "\e[1;36m>> Starting Aura-c-fetch Installation...\e[0m"

# 1. ติดตั้ง Chafa ถ้ายังไม่มี
if ! command -v chafa &> /dev/null; then
    echo ">> Installing chafa tool..."
    sudo apt update && sudo apt install chafa -y
else
    echo ">> chafa is already installed."
fi

# 2. แก้สิทธิ์การรันให้สคริปต์หลัก
if [ -f "src/aura.sh" ]; then
    chmod +x src/aura.sh
    echo ">> Permission granted to src/aura.sh"
else
    echo -e "\e[1;31m!! Error: src/aura.sh not found.\e[0m"
fi

echo -e "\e[1;32m>> Installation Complete! Run with: ./src/aura.sh\e[0m"