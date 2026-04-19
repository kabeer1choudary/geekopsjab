#!/bin/bash
# Reverse network changes: restore default route and resolv.conf

set -e

echo "Removing custom default route..."
sudo ip route del default || echo "No custom default route to delete."

echo "Restoring default route via DHCP (on enp1s0)..."
sudo dhclient -r enp1s0 || true
sudo dhclient enp1s0

echo "Restoring resolv.conf to systemd-resolved default..."
sudo tee /etc/resolv.conf > /dev/null <<EOL
# This file is managed by systemd-resolved
nameserver 127.0.0.53
options edns0 trust-ad
search localdomain
EOL

echo "Verifying routing table..."
ip route

echo "Verifying resolv.conf contents..."
cat /etc/resolv.conf

echo "Network configuration reverted successfully."