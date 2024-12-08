#!/bin/bash

# Colors for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
RESET='\033[0m'

# Function to check and install a command
install_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${BLUE}Installing '$1'...${RESET}"
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y "$1" && echo -e "${GREEN}'$1' installed successfully.${RESET}" || \
            { echo -e "${RED}Failed to install '$1'. Please install it manually.${RESET}"; return 1; }
        else
            echo -e "${RED}ERROR: Package manager not supported. Please install '$1' manually.${RESET}"
            return 1
        fi
    else
        echo -e "${GREEN}'$1' is already installed.${RESET}"
    fi
}

# Function to ensure write permissions
ensure_write_permission() {
    if [ -w "$(pwd)" ]; then
        echo -e "${GREEN}Write permissions available in the current directory.${RESET}"
    else
        echo -e "${RED}ERROR: No write permissions in the current directory. Please run in a writable directory.${RESET}"
        exit 1
    fi
}

# Install required tools
echo -e "${BLUE}Setting up environment for the main script...${RESET}"

COMMANDS=("subfinder" "httprobe" "firefox")
for cmd in "${COMMANDS[@]}"; do
    install_command "$cmd" || MISSING=true
done

# Ensure write permissions
ensure_write_permission

# Final message
if [ "$MISSING" = true ]; then
    echo -e "\n${RED}Some tools could not be installed. Please resolve the errors above manually.${RESET}"
    exit 1
else
    echo -e "\n${GREEN}Environment setup complete. You can now run the main script.${RESET}"
    exit 0
fi
