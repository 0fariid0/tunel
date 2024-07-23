#!/bin/bash

# Download the script
echo "Downloading the script..."
wget https://raw.githubusercontent.com/0fariid0/tunel/main/tunnel.sh

# Make the script executable
echo "Making the script executable..."
chmod +x tunnel.sh

# Execute the script
echo "Executing the script..."
sudo ./tunnel.sh
