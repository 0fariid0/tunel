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

    # Read number of servers
    echo "Enter the number of servers you want to configure:"
    read num_servers

    # Initialize configuration file
    config_file="/etc/haproxy/haproxy.cfg"

    # Backup the old configuration file
    sudo cp $config_file $config_file.bak

    # Initialize the new configuration
    echo "global" | sudo tee $config_file > /dev/null
    echo "   log \"stdout\" format rfc5424 daemon  notice" | sudo tee -a $config_file > /dev/null
    echo "" | sudo tee -a $config_file > /dev/null
    echo "defaults" | sudo tee -a $config_file > /dev/null
    echo "   mode tcp" | sudo tee -a $config_file > /dev/null
    echo "   log global" | sudo tee -a $config_file > /dev/null
    echo "   balance leastconn" | sudo tee -a $config_file > /dev/null
    echo "   timeout connect 5s" | sudo tee -a $config_file > /dev/null
    echo "   timeout server 30s" | sudo tee -a $config_file > /dev/null
    echo "   timeout client 30s" | sudo tee -a $config_file > /dev/null
    echo "   default-server inter 15s" | sudo tee -a $config_file > /dev/null
    echo "" | sudo tee -a $config_file > /dev/null

    # Read which tunnels to forward
    echo "Enter the tunnel numbers you want to forward (space-separated):"
    read tunnels

    # Add frontends and backends for selected tunnels
    for tunnel in $tunnels; do
        if [ "$tunnel" -eq 2 ]; then
            echo "frontend xray-frontend" | sudo tee -a $config_file > /dev/null
            echo "   bind *:1030" | sudo tee -a $config_file > /dev/null
            echo "   bind *:56855" | sudo tee -a $config_file > /dev/null
            echo "   bind *:27028" | sudo tee -a $config_file > /dev/null
            echo "   bind *:32942" | sudo tee -a $config_file > /dev/null
            echo "   bind *:39464" | sudo tee -a $config_file > /dev/null
            echo "   bind *:47903" | sudo tee -a $config_file > /dev/null
            echo "   bind *:31" | sudo tee -a $config_file > /dev/null
            echo "   log global" | sudo tee -a $config_file > /dev/null
            echo "   use_backend xray-backend-servers" | sudo tee -a $config_file > /dev/null
            echo "" | sudo tee -a $config_file > /dev/null
            echo "backend xray-backend-servers" | sudo tee -a $config_file > /dev/null
            echo "   server gate1 [2002:fb8:222::2]" | sudo tee -a $config_file > /dev/null
            echo "" | sudo tee -a $config_file > /dev/null
        fi
        if [ "$tunnel" -eq 5 ]; then
            echo "frontend xray5-frontend" | sudo tee -a $config_file > /dev/null
            echo "   bind *:12395" | sudo tee -a $config_file > /dev/null
            echo "   bind *:53057" | sudo tee -a $config_file > /dev/null
            echo "   bind *:50048" | sudo tee -a $config_file > /dev/null
            echo "   bind *:38558" | sudo tee -a $config_file > /dev/null
            echo "   bind *:1011" | sudo tee -a $config_file > /dev/null
            echo "   log global" | sudo tee -a $config_file > /dev/null
            echo "   use_backend xray5-backend-servers" | sudo tee -a $config_file > /dev/null
            echo "" | sudo tee -a $config_file > /dev/null
            echo "backend xray5-backend-servers" | sudo tee -a $config_file > /dev/null
            echo "   server gate5 [2002:fb8:225::2]" | sudo tee -a $config_file > /dev/null
            echo "" | sudo tee -a $config_file > /dev/null
        fi
    done

    # Restart haproxy to apply changes
    restart_haproxy
}

echo "Select an option:"
echo "1 - Tunnel"
echo "2 - HAProxy"
echo "3 - Exit"
echo "Enter your choice [1-3]: "
read main_option

case $main_option in
    1)
        while true; do
            clear
            echo "Select an option:"
            echo "1 - Server Iran (IR)"
            echo "2 - Server Kharej (KH)"
            echo "3 - Delete Tunnel"
            echo "4 - Back to Main Menu"
            echo "Enter your choice [1-4]: "
            read tunnel_option

            case $tunnel_option in
                1)
                    echo "You selected Server Iran (IR)"
                    # Insert the script logic for Server Iran (IR) here
                    ;;
                2)
                    echo "You selected Server Kharej (KH)"
                    # Insert the script logic for Server Kharej (KH) here
                    ;;
                3)
                    echo "You selected Delete Tunnel"
                    # Insert the script logic for Delete Tunnel here
                    echo "Do you want to reboot the server now? (y/n): "
                    read reboot_choice
                    if [[ $reboot_choice == "y" ]]; then
                        sudo reboot
                    else
                        sudo netplan apply
                    fi
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
            echo "2 - Forward Ports"
            echo "3 - Start HAProxy"
            echo "4 - Stop HAProxy"
            echo "5 - Back to Main Menu"
            echo "Enter your choice [1-5]: "
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
        exit 0
        ;;
    *)
        echo "Invalid option. Please try again."
        ;;
esac
