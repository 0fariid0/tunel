#!/bin/bash

# Function to clean up previous versions of the script
cleanup_previous_versions() {
    echo "Cleaning up previous versions of the script..."
    if [ -f "/usr/local/bin/old_script.sh" ]; then
        sudo rm /usr/local/bin/old_script.sh
        echo "Old script removed."
    fi
}

# Function to handle Server Iran (IR)
handle_ir() {
    echo "You selected Server Iran (IR)"
    # Add your logic for Server Iran (IR) here
    echo "Server Iran (IR) logic not implemented."
}

# Function to handle Server Kharej (KH)
handle_kh() {
    echo "You selected Server Kharej (KH)"
    # Add your logic for Server Kharej (KH) here
    echo "Server Kharej (KH) logic not implemented."
}

# Function to handle Delete Tunnel
handle_delete_tunnel() {
    echo "You selected Delete Tunnel"
    echo "Enter the tunnel number to delete (e.g., 1, 2, 3, ...):"
    read tunnel_number
    if [ -f "/etc/netplan/tunnel$tunnel_number.yaml" ]; then
        sudo rm "/etc/netplan/tunnel$tunnel_number.yaml"
        echo "Tunnel $tunnel_number deleted."
        echo "Do you want to reboot the server now? (y/n): "
        read reboot_choice
        if [[ $reboot_choice == "y" ]]; then
            sudo reboot
        else
            sudo netplan apply
        fi
    else
        echo "Tunnel $tunnel_number does not exist."
    fi
}

# Function to handle Ping Forever for Server Kharej (KH)
ping_forever_kh() {
    while true; do
        clear
        echo "Ping Forever Options:"
        echo "1 - Install"
        echo "2 - Restart"
        echo "3 - Status"
        echo "4 - Exit to Main Menu"
        echo "Enter your choice [1-4]: "
        read sub_option

        case $sub_option in
            1)
                echo "Installing Ping Forever..."
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
                ;;
            2)
                echo "Restarting Ping Forever service..."
                sudo systemctl restart ping_forever.service
                echo "Ping Forever service restarted."
                ;;
            3)
                echo "Checking Ping Forever service status..."
                sudo systemctl status ping_forever.service
                ;;
            4)
                echo "Exiting Ping Forever menu."
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
        echo "Press any key to return to the Ping Forever menu..."
        read -n 1
    done
}

# Main Loop
cleanup_previous_versions

while true; do
    clear
    echo "Select an option:"
    echo "1 - Tunnel"
    echo "2 - Ping Forever"
    echo "3 - Exit"
    echo "Enter your choice [1-3]: "
    read main_option

    case $main_option in
        1)
            while true; do
                clear
                echo "Tunnel Options:"
                echo "1 - Server Iran (IR)"
                echo "2 - Server Kharej (KH)"
                echo "3 - Delete Tunnel"
                echo "4 - Exit to Main Menu"
                echo "Enter your choice [1-4]: "
                read tunnel_option

                case $tunnel_option in
                    1)
                        handle_ir
                        ;;
                    2)
                        handle_kh
                        ;;
                    3)
                        handle_delete_tunnel
                        ;;
                    4)
                        echo "Exiting Tunnel menu."
                        break
                        ;;
                    *)
                        echo "Invalid option. Please try again."
                        ;;
                esac
                echo "Press any key to return to the Tunnel menu..."
                read -n 1
            done
            ;;
        2)
            ping_forever_kh
            ;;
        3)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
