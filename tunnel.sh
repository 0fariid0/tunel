#!/bin/bash

# Helper function to restart haproxy
restart_haproxy() {
    echo "Restarting HAProxy..."
    sudo systemctl restart haproxy
}

# Helper function to start haproxy
start_haproxy() {
    echo "Starting HAProxy..."
    sudo systemctl start haproxy
}

# Helper function to stop haproxy
stop_haproxy() {
    echo "Stopping HAProxy..."
    sudo systemctl stop haproxy
}

# Helper function to install haproxy
install_haproxy() {
    echo "Installing HAProxy..."
    sudo apt update -y
    sudo apt install haproxy -y
}

# Helper function to configure haproxy
configure_haproxy() {
    echo "Configuring HAProxy..."

    # Initialize configuration file
    config_file="/etc/haproxy/haproxy.cfg"
    echo "global" > $config_file
    echo "   log \"stdout\" format rfc5424 daemon  notice" >> $config_file
    echo "" >> $config_file
    echo "defaults" >> $config_file
    echo "   mode tcp" >> $config_file
    echo "   log global" >> $config_file
    echo "   balance leastconn" >> $config_file
    echo "   timeout connect 5s" >> $config_file
    echo "   timeout server 30s" >> $config_file
    echo "   timeout client 30s" >> $config_file
    echo "   default-server inter 15s" >> $config_file
    echo "" >> $config_file

    # Read tunnel numbers
    echo "Enter the tunnel numbers you want to configure (space-separated, e.g., 1 2 3):"
    read tunnel_numbers

    # Configure each tunnel
    for tunnel_number in $tunnel_numbers; do
        if [[ $tunnel_number -ge 1 && $tunnel_number -le 9 ]]; then
            echo "Enter the ports for tunnel $tunnel_number (space-separated):"
            read ports

            # Add frontend configuration
            echo "frontend tunnel${tunnel_number}-frontend" >> $config_file
            for port in $ports; do
                echo "   bind *:$port" >> $config_file
            done
            echo "   log global" >> $config_file
            echo "   use_backend tunnel${tunnel_number}-backend-servers" >> $config_file
            echo "" >> $config_file

            # Add backend configuration
            echo "backend tunnel${tunnel_number}-backend-servers" >> $config_file
            echo "   server tunnel${tunnel_number} [2002:fb8:22${tunnel_number}::2]" >> $config_file
            echo "" >> $config_file
        else
            echo "Invalid tunnel number: $tunnel_number. Valid range is 1-9. Skipping..."
        fi
    done

    # Restart haproxy to apply changes
    restart_haproxy
}

# Function to install and configure netplan if not done before
setup_netplan_once() {
    CONFIG_FLAG="/etc/netplan/netplan_configured"

    if [ ! -f "$CONFIG_FLAG" ]; then
        echo "Installing and configuring netplan..."
        sudo apt install netplan.io -y
        sudo systemctl unmask systemd-networkd.service
        sudo systemctl restart networking
        sudo netplan apply
        sudo systemctl restart networking
        sudo netplan apply
        sudo systemctl restart networking
        sudo netplan apply

        # Create the flag file to indicate configuration has been done
        sudo touch "$CONFIG_FLAG"
    else
        echo "Netplan is already configured."
    fi
}

# Function to display the tunnel menu
display_tunnel_menu() {
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
    echo "Select an option:"
    echo "1 - Tunnel Management"
    echo "2 - HAProxy Management"
    echo "3 - Exit"
    read main_option

    case $main_option in
        1)
            setup_netplan_once
            while true; do
                clear
                display_tunnel_menu
                read -p "Enter your choice [1-4]: " tunnel_option

                case $tunnel_option in
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
                        break
                        ;;
                    *)
                        echo "Invalid option. Please try again."
                        ;;
                esac
                echo "Press any key to continue..."
                read -n 1
            done
            ;;
        2)
            while true; do
                clear
                echo "Select an option for HAProxy:"
                echo "1 - Install"
                echo "2 - Configure HAProxy"
                echo "3 - Start HAProxy"
                echo "4 - Stop HAProxy"
                echo "5 - Back to Main Menu"
                read haproxy_option

                case $haproxy_option in
                    1)
                        install_haproxy
                        ;;
                    2)
                        configure_haproxy
                        ;;
                    3)
                        start_haproxy
                        ;;
                    4)
                        stop_haproxy
                        ;;
                    5)
                        echo "Returning to main menu..."
                        break
                        ;;
                    *)
                        echo "Invalid option. Please try again."
                        ;;
                esac
                echo "Press any key to continue..."
                read -n 1
            done
            ;;
        3)
            echo "Exiting..."
            exit
