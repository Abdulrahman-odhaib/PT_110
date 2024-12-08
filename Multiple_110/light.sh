#!/bin/bash

# Define delay for better readability
DELAY=5

# Colors for styling
RED='\033[0;31m'
WHITE='\033[0;37m'
BLUE='\033[1;34m'
RESET='\033[0m'

# Display steps
echo -e "${WHITE}STEPS: 
        1. Gather subdomains using Subfinder (30 domains)
        2. Find live domains
        3. Open live domains in the browser ${RESET}"

# Prompt for domain input
read -p "Enter the Domain: " DOMAIN

# Function: Check wildcard DNS
check_wildcard_dns() {
    if ping -c 1 "ayakalammayhm.$DOMAIN" &> /dev/null; then
        echo -e "${RED}BAD: Wildcard DNS record exists. Mission canceled.${RESET}"
        while true; do echo -e "\a"; done
        exit 1
    else
        echo -e "${WHITE}GOOD: Wildcard DNS record doesn't exist. Continuing with the mission.${RESET}"
        sleep $DELAY
    fi
}

# Function: Gather subdomains using Subfinder
gather_subdomains() {
    echo -e "\n${BLUE}Gathering Subdomains Using Subfinder${RESET}"
    mkdir -p "$DOMAIN"
    subfinder -d "$DOMAIN" -nW -t 30 -timeout 1 | tee "$DOMAIN/subdomains.txt" | head -n 30
    echo -e "\nSubdomains gathered: $(wc -l < "$DOMAIN/subdomains.txt")"
}

# Function: Find live domains
find_live_domains() {
    echo -e "\n${BLUE}Finding Live Domains${RESET}"
    mkdir -p "$DOMAIN/online"
    httprobe < "$DOMAIN/subdomains.txt" | tee "$DOMAIN/online/live_domains.txt" | sort -u
    echo -e "\nLive domains found: $(wc -l < "$DOMAIN/online/live_domains.txt")"
}

# Function: Open live domains in browser
open_live_domains() {
    echo -e "\n${BLUE}Opening Live Domains in Browser${RESET}"
    while read -r live_domain; do
        echo "Opening: $live_domain"
        firefox "$live_domain" &
    done < "$DOMAIN/online/live_domains.txt"
}

# Function: Final organization
final_organize() {
    echo -e "\n${BLUE}Final Organization${RESET}"
    mkdir -p targets
    mv "$DOMAIN" targets/
}

# Main execution
check_wildcard_dns
gather_subdomains
find_live_domains
open_live_domains
final_organize

echo -e "\n${WHITE}Mission completed. All data stored in 'targets/$DOMAIN'.${RESET}"
