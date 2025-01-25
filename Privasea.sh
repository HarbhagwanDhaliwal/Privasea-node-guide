#!/bin/bash

# Define colors for output messages
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Function to display success messages
success_message() {
    echo -e "${GREEN}[✔] $1${NC}"
}

# Function to display informational messages
info_message() {
    echo -e "${CYAN}[-] $1...${NC}"
}

# Function to display error messages
error_message() {
    echo -e "${RED}[✘] $1${NC}"
}

# Clear the screen
clear

# ASCII art
echo -e "${CYAN}"
echo "##   ##    ###    ##   ##  ######   ######   #######  #######  ########          #####     ##  ##    ###    ####      ######  ##   ##    ###    ####"
echo "### ###   ## ##   ###  ##   ##  ##   ##  ##   ##   ##   #   ##   #  ## ## ##           ## ##    ##  ##   ## ##    ##         ##    ##   ##   ## ##    ##"
echo "#######  ##   ##  #### ##   ##  ##   ##  ##   ##       ##         ##              ##  ##   ##  ##  ##   ##   ##         ##    ##   ##  ##   ##   ##"
echo "## # ##  ##   ##  #######   #####    #####    ####     ####       ##              ##  ##   ######  ##   ##   ##         ##    ## # ##  ##   ##   ##"
echo "##   ##  #######  ## ####   ##       ## ##    ##       ##         ##              ##  ##   ##  ##  #######   ##         ##    #######  #######   ##"
echo "##   ##  ##   ##  ##  ###   ##       ## ##    ##   #   ##   #     ##              ## ##    ##  ##  ##   ##   ##  ##     ##    ### ###  ##   ##   ##  ##"
echo "### ###  ##   ##  ##   ##  ####     #### ##  #######  #######    ####            #####     ##  ##  ##   ##  #######   ######  ##   ##  ##   ##  #######"
echo -e "${NC}\n"

echo -e "${CYAN}========================================"
echo "   Privasea Acceleration Node Setup"
echo -e "========================================${NC}\n"

# Step 1: Check if Docker is installed
if ! command -v docker &>/dev/null; then
    info_message "Docker not found, starting installation..."
    
    # Install required dependencies
    sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    # Add Docker repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    
    # Update package index and install Docker
    sudo apt update && sudo apt install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker

    success_message "Docker successfully installed and started."
else
    success_message "Docker is already installed. Skipping installation."
fi

echo ""

# Step 2: Pull Docker image
info_message "Downloading Docker image"
if docker pull privasea/acceleration-node-beta:latest; then
    success_message "Docker image downloaded successfully."
else
    error_message "Failed to download Docker image."
    exit 1
fi

echo ""

# Step 3: Create configuration directory
info_message "Creating configuration directory"
if mkdir -p "$HOME/privasea/config"; then
    success_message "Configuration directory created successfully."
else
    error_message "Failed to create configuration directory."
    exit 1
fi

echo ""

# Step 4: Generate keystore file
info_message "Generating keystore file"
if docker run -it -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore; then
    success_message "Keystore file created successfully."
else
    error_message "Failed to create keystore file."
    exit 1
fi

echo ""

# Step 5: Rename keystore file
info_message "Renaming keystore file"

# Find the actual file name dynamically
keystore_file=$(find "$HOME/privasea/config" -type f -name "UTC--*" -print -quit)

if [ -n "$keystore_file" ]; then
    if mv "$keystore_file" "$HOME/privasea/config/wallet_keystore"; then
        success_message "Keystore file renamed to wallet_keystore."
    else
        error_message "Failed to rename keystore file."
        exit 1
    fi
else
    error_message "No keystore file found to rename."
    exit 1
fi

echo ""

# Step 6: Prompt to continue
read -p "Do you want to proceed with running the node? (y/n): " choice
if [[ "$choice" != "y" ]]; then
    echo -e "${CYAN}Process aborted.${NC}"
    exit 0
fi

# Step 7: Request keystore password
info_message "Enter password for keystore (to access the node):"
read -s KEystorePassword
echo ""

# Step 8: Run the Privasea Acceleration Node
info_message "Starting Privasea Acceleration Node"
if docker run -d -v "$HOME/privasea/config:/app/config" \
-e KEYSTORE_PASSWORD="$KEystorePassword" \
privasea/acceleration-node-beta:latest; then
    success_message "Node started successfully."
else
    error_message "Failed to start the node."
    exit 1
fi

echo ""

# Final step: Display completion message
echo -e "${GREEN}========================================"
echo "   Script by airdrop_node"
echo -e "========================================${NC}\n"
echo -e "${CYAN}Configuration files are available at:${NC} $HOME/privasea/config"
echo -e "${CYAN}Keystore saved as:${NC} wallet_keystore"
echo -e "${CYAN}Keystore password used:${NC} $KEystorePassword\n"
