#!/bin/bash

# Function to handle Server Iran (IR)
handle_ir() {
    echo "You selected Server Iran (IR)"
    # Insert the script logic for Server Iran (IR) here
}

# Function to handle Server Kharej (KH)
handle_kh() {
    echo "You selected Server Kharej (KH)"
    # Insert the script logic for Server Kharej (KH) here
}

# Function to handle Delete Tunnel
handle_delete_tunnel() {
    echo "You selected Delete Tunnel"
    # Insert the script logic for Delete Tunnel here
    echo "Do you want to reboot the server now? (y/n): "
    read reboot_choice
    if [[ $reboot_choice == "y" ]]; then
        sudo reboot
    else
        sudo netplan apply
    fi
}

# Function to handle Ping Forever menu
ping_forever_menu() {
    while true; do
        clear
        echo "Ping Forever Options:"
        echo "1 - Install"
        echo "2 - Restart"
        echo "3 - Status"
        echo "4 - Exit"
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
        echo "Press any key to return to the main menu..."
        read -n 1
    done
}

# Main loop
while true; do
    clear
    echo "Select an option:"
    echo "1 - Server Iran (IR)"
    echo "2 - Server Kharej (KH)"
    echo "3 - Delete Tunnel"
    echo "4 - Ping Forever"
    echo "Enter your choice [1-4]: "
    read option

    case $option in
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
            ping_forever_menu
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
