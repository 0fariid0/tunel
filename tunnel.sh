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

    # Define the IP addresses for backends
    declare -A backend_ips=(
        [2]="[2002:fb8:222::2]"
        [5]="[2002:fb8:225::2]"
    )

    # Ask which tunnels to configure
    echo "Enter the tunnel numbers you want to configure (space-separated, e.g., 2 5):"
    read tunnels

    # Add configurations for selected tunnels
    for tunnel in $tunnels; do
        if [[ -n "${backend_ips[$tunnel]}" ]]; then
            echo "frontend xray${tunnel}-frontend" >> $config_file
            echo "   bind *:1030" >> $config_file
            echo "   bind *:56855" >> $config_file
            echo "   bind *:27028" >> $config_file
            echo "   bind *:32942" >> $config_file
            echo "   bind *:39464" >> $config_file
            echo "   bind *:47903" >> $config_file
            echo "   bind *:31" >> $config_file
            echo "   log global" >> $config_file
            echo "   use_backend xray${tunnel}-backend-servers" >> $config_file
            echo "" >> $config_file

            echo "backend xray${tunnel}-backend-servers" >> $config_file
            echo "   server gate${tunnel} ${backend_ips[$tunnel]}" >> $config_file
            echo "" >> $config_file
        else
            echo "Invalid tunnel number: $tunnel"
        fi
    done

    # Restart haproxy to apply changes
    restart_haproxy
}

# Main menu
while true; do
    clear
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
done
