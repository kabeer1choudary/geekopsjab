#!/bin/bash

# Run arp and filter for virbr interfaces
arp_output=$(arp -n | grep virbr)

# Initialize arrays
virbr0_ips=()
virbr1_ips=()

# Parse output line by line
while read -r line; do
    ip=$(echo "$line" | awk '{print $1}')
    iface=$(echo "$line" | awk '{print $NF}')

    if [[ "$iface" == "virbr0" ]]; then
        virbr0_ips+=("$ip")
    elif [[ "$iface" == "virbr1" ]]; then
        virbr1_ips+=("$ip")
    fi
done <<< "$arp_output"

# Write to Ansible inventory file
inventory_file="inventory.ini"
{
    echo "[virbr0]"
    for ip in "${virbr0_ips[@]}"; do
        echo "$ip ansible_user=addyouruser"
    done

    echo ""
    echo "[virbr1]"
    for ip in "${virbr1_ips[@]}"; do
        echo "$ip ansible_user=addyouruser"
    done
} > "$inventory_file"

echo "Inventory file created: $inventory_file"
