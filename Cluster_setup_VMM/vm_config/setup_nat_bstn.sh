#!/bin/bash
# Functional NAT setup script with interface checks

# Get all interfaces
INTERFACES=($(ip -o link show | awk -F': ' '{print $2}'))

for iface in "${INTERFACES[@]}"; do
    echo "Checking interface: $iface"

    # Check if interface exists
    if ! ip link show "$iface" &>/dev/null; then
        echo "  -> Interface $iface does not exist."
        continue
    fi

    # Check if interface is UP
    state=$(ip link show "$iface" | awk '/state/ {print $9}')
    if [[ "$state" == "UP" ]]; then
        echo "  -> $iface is UP."
    else
        echo "  -> $iface is DOWN."
        sudo ip link set dev $iface up
        echo "  -> $iface is UP now."
    fi

    # Check if interface has an IPv4 address
    ip_addr=$(ip -4 addr show dev "$iface" | awk '/inet / {print $2}')
    if [[ -n "$ip_addr" ]]; then
        echo "  -> IP assigned: $ip_addr"
    else
        echo "  -> No IPv4 address assigned."
        # Configure netplan only once (avoid overwriting repeatedly)
        if [[ "$iface" == "enp7s0" ]]; then
            echo "Configuring netplan..."
            NETPLAN_FILE="/etc/netplan/50-cloud-init.yaml"
            sudo tee $NETPLAN_FILE > /dev/null <<EOL
network:
    ethernets:
        enp1s0: # public network - interface1
            dhcp4: true
        enp7s0: # private network - interface2
            addresses:
                - 192.168.100.1/24
    version: 2
EOL

            echo "Applying netplan configuration..."
            (sleep 5; echo) | sudo netplan try
            sudo netplan apply

            echo "Displaying routing table..."
            ip route

            echo "Enabling IP forwarding..."
            sudo sysctl -w net.ipv4.ip_forward=1
            sudo sysctl -p

            echo "Checking iptables rules..."
            sudo iptables -L

            echo "Configuring iptables for NAT and forwarding..."
            PUBLIC_IF="enp1s0"
            PRIVATE_IF="enp7s0"

            sudo iptables -A FORWARD -i $PRIVATE_IF -o $PUBLIC_IF -j ACCEPT
            sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
            sudo iptables -t nat -A POSTROUTING -o $PUBLIC_IF -j MASQUERADE
      fi
    fi
done

for iface in "${INTERFACES[@]}"; do
    # Check if interface has an IPv4 address
    ip_addr=$(ip -4 addr show dev "$iface" | awk '/inet / {print $2}')
    if [[ -n "$ip_addr" ]]; then
        echo "  $iface -> IP assigned: $ip_addr"
    else
        echo "  -> No IPv4 address assigned."
    fi

    echo
done