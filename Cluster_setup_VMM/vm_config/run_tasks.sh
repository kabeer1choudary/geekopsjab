#!/bin/bash

# Safer bash settings
set -euo pipefail

# Error handler
error_exit() {
    echo -e "\n Error: $1"
    exit 1
}

# Trap unexpected errors
trap 'error_exit "Unexpected error occurred at line $LINENO"' ERR

echo -e "\nStarting tasks...\n"

# 1. Run podman command to build an image
IMAGE_NAME="ansible-ubuntu2204"
DOCKERFILE="Dockerfile"

if [[ -f "$DOCKERFILE" ]]; then
    echo "Step 2: Building Podman image '$IMAGE_NAME'..."
    podman build -t "$IMAGE_NAME" . || error_exit "Podman build failed"
    echo "Podman image built successfully"
else
    error_exit "Dockerfile not found in current directory"
fi

# 2. Run a shell script to fetch VM IPs and write to inventory file
SCRIPT="../vm_provision/fetch_vm_ips.sh"
if [[ -x "$SCRIPT" ]]; then
    echo "Step 3: Running shell script..."
    "$SCRIPT" || error_exit "Shell script execution failed"
    echo "Shell script executed successfully"
else
    error_exit "Shell script $SCRIPT not found or not executable"
fi

# 3. Status message once all tasks finished
echo -e "\n All tasks completed successfully!\n"
