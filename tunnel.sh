#!/bin/bash

# Main menu
main_menu() {
    clear
    echo "Select an option:"
    echo "1 - Tunnel"
    echo "2 - Ping Forever"
    echo "3 - Exit"
    echo "Enter your choice [1-3]: "
    read main_option

    case $main_option in
        1)
            tunnel_menu
            ;;
        2)
            ping_forever_menu
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 2
            main_menu
            ;;
    esac
}

# Tunnel menu
tunnel_menu() {
    clear
    echo "Select an option:"
    echo "1 - Server Iran (IR)"
    echo "2 - Server Kharej (KH)"
    echo "3 - Delete Tunnel"
    echo "4 - Return to Main Menu"
    echo "Enter your choice [1-4]: "
    read tunnel_option

    case $tunnel_option in
        1)
            setup_tunnel "ir"
            ;;
        2)
            setup_tunnel "kh"
            ;;
        3)
            delete_tunnel
            ;;
        4)
            main_menu
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 2
            tunnel_menu
            ;;
    esac
}

# Ping Forever menu
ping_forever_menu() {
    clear
    echo "Ping Forever Options:"
    echo "1 - Install"
    echo "2 - Restart"
    echo "3 - Status"
    echo "4 - Return to Main Menu"
    echo "Enter your choice [1-4]: "
    read ping_option

    case $ping_option in
        1)
            install_ping_forever
            ;;
        2)
            restart_ping_forever
            ;;
        3)
            status_ping_forever
            ;;
        4)
            main_menu
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 2
            ping_forever_menu
            ;;
    esac
}

# Function to setup tunnel configuration
setup_tunnel() {
    local server_type=$1
    echo "Configuring Tunnel for $server_type..."

    echo "Enter the tunnel number: "
    read tunnel_number
    echo "Enter the local IP address: "
    read local_ip
    echo "Enter the remote IP address: "
    read remote_ip

    file_path="/etc/netplan/tunnel${tunnel_number}.yaml"

    if [[ $server_type == "ir" ]]; then
        addresses="2002:fb8:22${tunnel_number}::1/64"
    else
        addresses="2002:fb8:22${tunnel_number}::2/64"
    fi

    sudo tee $file_path > /dev/null <<EOL
network:
  version: 2
  tunnels:
    tunnel${tunnel_number}:
      mode: sit
      local: ${local_ip}
      remote: ${remote_ip}
      addresses:
        - ${addresses}
EOL

    echo "Tunnel configured successfully. Apply changes with netplan."
    echo "Do you want to reboot the server now? (y/n): "
    read reboot_choice
    if [[ $reboot_choice == "y" ]]; then
        sudo reboot
    else
        sudo netplan apply
    fi
}

# Function to delete tunnel configuration
delete_tunnel() {
    echo "Enter the tunnel number to delete: "
    read tunnel_number
    file_path="/etc/netplan/tunnel${tunnel_number}.yaml"

    if [[ -f $file_path ]]; then
        sudo rm $file_path
        echo "Tunnel configuration removed successfully."
        echo "Do you want to reboot the server now? (y/n): "
        read reboot_choice
        if [[ $reboot_choice == "y" ]]; then
            sudo reboot
        else
            sudo netplan apply
        fi
    else
        echo "Tunnel file not found."
    fi
}

# Function to install Ping Forever service
install_ping_forever() {
    echo "Installing Ping Forever service..."
    sudo tee /usr/local/bin/ping_forever.sh > /dev/null <<EOL
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
EOL

    sudo chmod +x /usr/local/bin/ping_forever.sh

    sudo tee /etc/systemd/system/ping_forever.service > /dev/null <<EOL
[Unit]
Description=Ping Forever Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ping_forever.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

    sudo systemctl daemon-reload
    sudo systemctl enable ping_forever.service
    sudo systemctl start ping_forever.service
    echo "Ping Forever service installed and started."
}

# Function to restart Ping Forever service
restart_ping_forever() {
    echo "Restarting Ping Forever service..."
    sudo systemctl restart ping_forever.service
    echo "Ping Forever service restarted."
}

# Function to check Ping Forever service status
status_ping_forever() {
    echo "Checking Ping Forever service status..."
    sudo systemctl status ping_forever.service
}

# Start the main menu
main_menu
