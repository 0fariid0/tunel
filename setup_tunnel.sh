#!/bin/bash

# Download the tunnel script
echo "Downloading the tunnel script..."
wget https://raw.githubusercontent.com/0fariid0/tunel/main/tunnel.sh

# Check if the download was successful
if [ $? -ne 0 ]; then
    echo "Failed to download the tunnel script. Exiting."
    exit 1
fi

# Make the tunnel script executable
echo "Making the tunnel script executable..."
chmod +x tunnel.sh

# Execute the tunnel script
echo "Executing the tunnel script..."
sudo ./tunnel.sh

# Check if the execution was successful
if [ $? -ne 0 ]; then
    echo "Failed to execute the tunnel script. Exiting."
    exit 1
fi

echo "Tunnel script executed successfully."
