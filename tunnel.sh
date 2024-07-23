#!/bin/bash

# Function to display the main menu
display_menu() {
    echo "Select an option:"
    echo "1 - Server Iran (IR)"
    echo "2 - Server Kharej (KH)"
    echo "3 - Delete Tunnel"
    echo "4 - Ping Forever"
    echo "5 - Exit"
}

# Function to handle the creation or updating of a tunnel
create_or_update_tunnel() {
    read -p "Enter the tunnel number: " TUNNEL_NUMBER
    FILE_PATH="/etc/netplan/tunnel${TUNNEL_NUMBER}.yaml"

    read -p "Enter the local IP address: " LOCAL_IP
    read -p "Enter the remote IP address: " REMOTE_IP

    if [ "$SERVER_TYPE" == "ir" ]; then
        ADDRESS="2002:fb8:22${TUNNEL_NUMBER}::1/64"
    else
        ADDRESS="2002:fb8:22${TUNNEL_NUMBER}::2/64"
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
                return_to_menu
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
}

# Function to handle the deletion of the tunnel
delete_tunnel() {
    read -p "Enter the tunnel number to delete: " TUNNEL_NUMBER
    FILE_PATH="/etc/netplan/tunnel${TUNNEL_NUMBER}.yaml"

    if [ -f "$FILE_PATH" ]; then
        echo "Deleting the file ${FILE_PATH}..."
        sudo rm "$FILE_PATH"
        sudo netplan apply
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
                return_to_menu
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
}

# Function to install the ping forever service
install_ping_forever() {
    echo "Installing the ping forever service..."

    # Create the ping_forever.sh script
    sudo bash -c 'cat > /usr/local/bin/ping_forever.sh <<EOF
#!/bin/bash

# Infinite loop to ping the given IPv6 addresses
while true
do
    ping6 2002:fb8:221::1 &
    ping6 2002:fb8:222::1 &
    ping6 2002:fb8:223::1 &
    ping6 2002:fb8:224::1 &
    ping6 2002:fb8:225::1 &
    wait
done
EOF'

    # Make the script executable
    sudo chmod +x /usr/local/bin/ping_forever.sh

    # Create the systemd service file
    sudo bash -c 'cat > /etc/systemd/system/ping_forever.service <<EOF
[Unit]
Description=Ping Forever Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ping_forever.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF'

    # Reload systemd, enable, and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable ping_forever.service
    sudo systemctl start ping_forever.service

    echo "Ping forever service installed and started."
}

# Function to restart the ping forever service
restart_ping_forever() {
    echo "Restarting the ping forever service..."
    sudo systemctl restart ping_forever.service
}

# Function to check the status of the ping forever service
status_ping_forever() {
    echo "Checking the status of the ping forever service..."
    sudo systemctl status ping_forever.service
}

# Function to handle the ping options menu
ping_forever_menu() {
    while true; do
        echo "Ping Forever Options:"
        echo "1 - Install"
        echo "2 - Restart"
        echo "3 - Status"
        read -p "Enter your choice [1-3]: " PING_CHOICE

        case $PING_CHOICE in
            1)
                install_ping_forever
                ;;
            2)
                restart_ping_forever
                ;;
            3)
                status_ping_forever
                ;;
            *)
                echo "Invalid choice. Please select 1, 2, or 3."
                ;;
        esac

        # Ask if the user wants to return to the main menu
        read -p "Do you want to return to the main menu? (y/n): " RETURN_TO_MENU
        if [[ "$RETURN_TO_MENU" == [Nn]* ]]; then
            exit 0
        fi
    done
}

# Function to return to the main menu
return_to_menu() {
    echo "Returning to the main menu..."
    sleep 1
}

# Main script logic
while true; do
    display_menu
    read -p "Enter your choice [1-5]: " CHOICE

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
            ping_forever_menu
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select 1, 2, 3, 4, or 5."
            ;;
    esac
done
