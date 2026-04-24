#!/bin/bash
# Automate virtualization package installation, service setup, resource check, and VM creation

# Function to check if a package group is installed
check_virtualization() {
    echo "Checking virtualization group status..."
    dnf group info virtualization | grep -q "Installed"
    if [ $? -eq 0 ]; then
        echo "Virtualization group is already installed."
    else
        echo "Virtualization group not installed. Installing now..."
        sudo dnf install -y @virtualization
    fi
}

# Function to start and enable libvirtd
setup_libvirtd() {
    echo "Starting and enabling libvirtd service..."
    sudo systemctl start libvirtd
    sudo systemctl enable libvirtd
}

# Function to check KVM support
check_kvm() {
    echo "Checking KVM support..."
    lsmod | grep kvm || echo "KVM not loaded. Ensure CPU supports virtualization."
}

# Function to check system resources
check_resources() {
    echo "Checking system resources..."
    echo "Disk usage:"
    df -h
    echo "Memory usage:"
    free -m
    echo "CPU info:"
    lscpu
}

# Function to create VM image
create_image() {
    echo "Creating VM disk image..."
    read -p "Enter name for the disk image (default: /var/lib/libvirt/images/alpine321.qcow2): " img_name
    img_name=${img_name:-alpine321.qcow2}
    img_path="/var/lib/libvirt/images/$img_name.qcow2"
    read -p "Enter disk size in MB (default: 4096): " img_size
    img_size=${img_size:-4096}
    sudo qemu-img create -f qcow2 -o preallocation=full "$img_path" "$img_size"M
}

# Function to create VM
create_vm() {
    echo "Configuring VM installation..."
    read -p "Identify the VM type (Controller: CTL, Worker: WRK): " vm_type
    vm_type=${vm_type:-WRK}
    read -p "Enter VM name (default: alpine321): " vm_name
    vm_name=${vm_name:-alpine321}
    read -p "Enter RAM size in MB (default: 1024): " vm_ram
    vm_ram=${vm_ram:-1024}
    read -p "Enter number of vCPUs (default: 1): " vm_vcpus
    vm_vcpus=${vm_vcpus:-1}
    read -p "Enter disk path: " vm_disk
    read -p "Enter OS variant (default: alpinelinux3.21): " vm_os
    vm_os=${vm_os:-alpinelinux3.21}
    read -p "Enter first network bridge (public/NAT: virbr0, private: virbr1): " vm_net1
    vm_net1=${vm_net1:-virbr0}
    read -p "Enter second network bridge (public/NAT: virbr0, private: virbr1): " vm_net2
    read -p "Enter ISO path: " vm_iso
    vm_iso=${vm_iso:-/var/lib/libvirt/images/alpine-virt-3.21.0-x86_64.iso}

    if [[ "$node_type" == "WRK" ]]; then
    echo "Launching worker node with single network..."
    sudo virt-install \
        --name "$vm_name"_WRK \
        --description "$vm_name Worker Node" \
        --ram "$vm_ram" \
        --vcpus "$vm_vcpus" \
        --disk path="$vm_disk",size=4 \
        --os-variant "$vm_os" \
        --network bridge="$vm_net1" \
        --graphics vnc,listen=127.0.0.1,port=5901 \
        --cdrom "$vm_iso" \
        --noautoconsole
    elif [[ "$node_type" == "CTL" ]]; then
        echo "Launching controller node with two networks..."
        sudo virt-install \
            --name "$vm_name" \
            --description "$vm_name Controller Node" \
            --ram "$vm_ram" \
            --vcpus "$vm_vcpus" \
            --disk path="$vm_disk",size=4 \
            --os-variant "$vm_os" \
            --network bridge="$vm_net1" \
            --network bridge="$vm_net2" \
            --graphics vnc,listen=127.0.0.1,port=5901 \
            --cdrom "$vm_iso" \
            --noautoconsole
    else
        echo "Unknown node type: $node_type"
        echo "Usage: $0 [worker|controller]"
        exit 1
    fi

    # sudo virt-install \
    #     --name "$vm_name" \
    #     --description "$vm_name Workstation" \
    #     --ram "$vm_ram" \
    #     --vcpus "$vm_vcpus" \
    #     --disk path="$vm_disk",size=4 \
    #     --os-variant "$vm_os" \
    #     --network bridge="$vm_net1" \
    #     --network bridge="$vm_net2" \
    #     --graphics vnc,listen=127.0.0.1,port=5901 \
    #     --cdrom "$vm_iso" \
    #     --noautoconsole
}

# Main execution
check_virtualization
setup_libvirtd
check_kvm
check_resources
create_image
create_vm

echo "VM creation process completed!"
