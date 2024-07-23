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
                echo "2 - Configure HAProxy"
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
