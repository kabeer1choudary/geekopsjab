#!/bin/bash
# Script to reset default route and update DNS resolvers

set -e

echo "Removing existing default route..."
sudo ip route del default || echo "No default route to delete."

echo "Adding new default route via 192.168.100.1..."
sudo ip route add default via 192.168.100.1

echo "Updating DNS resolvers..."
sudo tee /etc/resolv.conf > /dev/null <<EOL
nameserver 8.8.8.8
nameserver 1.1.1.1
EOL

echo "Verifying new routing table..."
ip route

echo "Verifying resolv.conf contents..."
cat /etc/resolv.conf

echo "Network configuration updated successfully."