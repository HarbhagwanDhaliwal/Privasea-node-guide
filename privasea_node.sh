#!/bin/bash

# Script save path
SCRIPT_PATH="$HOME/Privasea.sh"

# Function to install the node
install_node() {
    # Check if Docker is installed
    if command -v docker &> /dev/null; then
        echo "Docker is already installed."
    else
        echo "Docker is not installed. Installing Docker..."
        sudo apt-get update
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable"
        sudo apt-get update -y
        sudo apt-get install -y docker-ce
        docker --version
    fi
    
    # Pull Privasea images
    sudo docker pull privasea/node-calc:v0.0.1
    sudo docker pull privasea/node-client:v0.0.1
    echo '====================== Deployment Completed ==========================='
}

# Function to create an account and key file
create_privasea_account() {
    mkdir -p $HOME/keys
    sudo docker run -it -v $HOME/keys:/app/keys privasea/node-client:v0.0.1 account
    echo 'Please back up your account information!'
}

# Function to view Privasea node logs
view_logs() {
    read -p "Enter node name: " NODE_NAME
    sudo docker logs -f $NODE_NAME
}

# Function to uninstall the node
uninstall_node() {
    read -p "Enter node name: " NODE_NAME
    read -r -p "Are you sure you want to uninstall the Privasea node? [Y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "Uninstalling node..."
            sudo docker stop $NODE_NAME
            sudo docker rm $NODE_NAME
            sudo docker rmi $NODE_NAME
            echo "Node uninstalled. Account data is saved in $HOME/keys. Backup and delete manually if needed."
            ;;
        *)
            echo "Uninstallation canceled."
            ;;
    esac
}

# Function to stop the node
stop_node() {
    read -p "Enter node name: " NODE_NAME
    sudo docker stop $NODE_NAME
    echo "Node stopped."
}

# Function to start the node
start_node() {
    read -p "Enter node name: " NODE_NAME
    read -p "Enter account file name: " ACCOUNT
    read -sp "Enter account password: " PASSWORD
    read -p "Enter public IP: " PUBLIC_IP
    read -r -p "Do you have tBNB and TT (test tokens)? [Y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            if ss -ltn | grep 8181 > /dev/null; then
                echo "Port 8181 is in use. Please check and restart."
                exit 1
            else
                echo "Starting node..."
            fi
            sudo docker run -d -p 8181:8181 -e HOST=$PUBLIC_IP:8181 -e KEYSTORE=$ACCOUNT -e KEYSTORE_PASSWORD=$PASSWORD -v $HOME/keys:/app/config --name $NODE_NAME privasea/node-calc:v0.0.1
            echo "Node $NODE_NAME started."
            ;;
        *)
            echo "Exit."
            ;;
    esac
}

# Function to install the Privasea client
install_privasea_client() {
    install_node  # Reuse Docker installation logic
    sudo docker pull privasea/node-client:v0.0.1
    echo '====================== Client Deployment Completed ==========================='
}

# Function to start the Privasea client
start_privasea_client() {
    read -p "Enter client name: " CLIENT_NAME
    read -p "Enter account file name: " ACCOUNT
    read -sp "Enter account password: " PASSWORD
    sudo docker run -it -e KEYSTORE_PASSWORD=$PASSWORD -v $HOME/keys:/app/config --name $CLIENT_NAME privasea/node-client:v0.0.1 task --keystore $ACCOUNT
}

# Function to stop the Privasea client
stop_privasea_client() {
    read -p "Enter client name: " CLIENT_NAME
    sudo docker stop $CLIENT_NAME
}

# Function to view Privasea client logs
view_privasea_client_logs() {
    read -p "Enter client name: " CLIENT_NAME
    sudo docker logs -f $CLIENT_NAME
}

# Function to uninstall the Privasea client
uninstall_privasea_client() {
    read -p "Enter client name: " CLIENT_NAME
    read -r -p "Are you sure you want to uninstall the client? [Y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            echo "Uninstalling client..."
            sudo docker stop $CLIENT_NAME
            sudo docker rm $CLIENT_NAME
            sudo docker rmi $CLIENT_NAME
            echo "Client uninstalled. Account data saved in $HOME/keys. Backup and delete manually if needed."
            ;;
        *)
            echo "Uninstallation canceled."
            ;;
    esac
}

# Main menu function
main_menu() {
    while true; do
        clear
        echo "=============== Privasea Deployment Script ==============="
        echo "Telegram Group: https://t.me/lumaogogogo"
        echo "Minimum Requirements: 6C8G100G, Public IP required."
        echo "Choose an option:"
        echo "1. Deploy Node"
        echo "2. Create Account"
        echo "3. Start Node"
        echo "4. Stop Node"
        echo "5. View Logs"
        echo "21. Deploy Client"
        echo "22. Start Client"
        echo "23. Stop Client"
        echo "24. View Client Logs"
        echo "0. Exit"
        read -p "Enter option: " OPTION
        case $OPTION in
            1) install_node ;;
            2) create_privasea_account ;;
            3) start_node ;;
            4) stop_node ;;
            5) view_logs ;;
            21) install_privasea_client ;;
            22) start_privasea_client ;;
            23) stop_privasea_client ;;
            24) view_privasea_client_logs ;;
            0) echo "Exiting script."; exit 0 ;;
            *) echo "Invalid option. Try again."; sleep 3 ;;
        esac
        echo "Press any key to return to the main menu..."
        read -n 1
    done
}

# Display main menu
main_menu
