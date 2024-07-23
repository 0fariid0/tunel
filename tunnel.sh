#!/bin/bash

# Function to display the menu and get user choice
display_menu() {
    echo "Select an option:"
    echo "1 - Server Iran (IR)"
    echo "2 - Server Kharej (KH)"
    echo "3 - Delete Tunnel"
    echo "4 - Back to Main Menu"
}

# Function to handle the deletion of the tunnel
delete_tunnel() {
    read -p "Enter the tunnel number to delete: " TUNNEL_NUMBER
    FILE_PATH="/etc/netplan/tunnel${TUNNEL_NUMBER}.yaml"

    if [ -f "$FILE_PATH" ]; then
        echo "Deleting the file ${FILE_PATH}..."
        sudo rm "$FILE_PATH"
        sudo netplan apply
        echo "Tunnel ${TUNNEL_NUMBER} deleted."
    else
        echo "File ${FILE_PATH} does not exist."
    fi

    # Ask the user if they want to reboot the server
    while true; do
        read -p "Do you want to reboot the server now? (y/n): " REBOOT_ANSWER
        case $REBOOT_ANSWER in
            [Yy]* )
                echo "Rebooting the server..."
                sudo reboot
                exit 0
                ;;
            [Nn]* )
                echo "Server will not be rebooted. Applying netplan configuration again..."
                sudo netplan apply
                exit 0
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
}

# Function to handle the creation or updating of a tunnel
create_or_update_tunnel() {
    read -p "Enter the tunnel number: " TUNNEL_NUMBER
    FILE_PATH="/etc/netplan/tunnel${TUNNEL_NUMBER}.yaml"

    read -p "Enter the local IP address: " LOCAL_IP
    read -p "Enter the remote IP address: " REMOTE_IP

    # Define the address based on the server type
    if [ "$SERVER_TYPE" == "ir" ]; then
        ADDRESS="2002:fb8:22${TUNNEL_NUMBER}::1/64"
    elif [ "$SERVER_TYPE" == "kh" ]; then
        ADDRESS="2002:fb8:22${TUNNEL_NUMBER}::2/64"
    else
        echo "Invalid server type. Exiting..."
        exit 1
    fi

    NEW_CONTENT="network:
  version: 2
  tunnels:
    tunnel${TUNNEL_NUMBER}:
      mode: sit
      local: ${LOCAL_IP}
      remote: ${REMOTE_IP}
      addresses:
        - ${ADDRESS}"

    if [ -f "$FILE_PATH" ]; then
        echo "Backing up the existing file to ${FILE_PATH}.bak"
        sudo cp "$FILE_PATH" "${FILE_PATH}.bak"
    fi

    echo "$NEW_CONTENT" | sudo tee "$FILE_PATH" > /dev/null
    sudo netplan apply

    # Ask the user if they want to reboot the server
    while true; do
        read -p "Do you want to reboot the server now? (y/n): " REBOOT_ANSWER
        case $REBOOT_ANSWER in
            [Yy]* )
                echo "Rebooting the server..."
                sudo reboot
                exit 0
                ;;
            [Nn]* )
                echo "Server will not be rebooted. Applying netplan configuration again..."
                sudo netplan apply
                exit 0
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
}

# Main script logic
while true; do
    clear
    display_menu
    read -p "Enter your choice [1-4]: " CHOICE

    case $CHOICE in
        1)
            SERVER_TYPE="ir"
            create_or_update_tunnel
            ;;
        2)
            SERVER_TYPE="kh"
            create_or_update_tunnel
            ;;
        3)
            delete_tunnel
            ;;
        4)
            echo "Returning to main menu..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select 1, 2, 3, or 4."
            ;;
    esac
done
