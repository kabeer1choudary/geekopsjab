#!/bin/bash

# Safer bash settings
set -euo pipefail

# Error handler
error_exit() {
    echo -e "\n❌ Error: $1"
    exit 1
}

# Trap unexpected errors
trap 'error_exit "Unexpected error occurred at line $LINENO"' ERR

echo -e "\n🚀 Starting tasks...\n"

# 1. Create .ssh directory in current directory
mkdir -p .ssh || error_exit "Failed to create .ssh directory"
echo "✅ Step 1: .ssh directory created"

# 2. Run podman command to build an image
IMAGE_NAME="ansible-ubuntu"
DOCKERFILE="Dockerfile"

if [[ -f "$DOCKERFILE" ]]; then
    echo "📦 Step 2: Building Podman image '$IMAGE_NAME'..."
    podman build -t "$IMAGE_NAME" . || error_exit "Podman build failed"
    echo "✅ Podman image built successfully"
else
    error_exit "Dockerfile not found in current directory"
fi

# 3. Run a shell script
SCRIPT="./myscript.sh"
if [[ -x "$SCRIPT" ]]; then
    echo "📜 Step 3: Running shell script..."
    "$SCRIPT" || error_exit "Shell script execution failed"
    echo "✅ Shell script executed successfully"
else
    error_exit "Shell script $SCRIPT not found or not executable"
fi

# 4. Move a file to a certain directory
SOURCE_FILE="./output.txt"
DEST_DIR="/tmp/myfiles"

mkdir -p "$DEST_DIR" || error_exit "Failed to create destination directory"
if [[ -f "$SOURCE_FILE" ]]; then
    echo "📂 Step 4: Moving $SOURCE_FILE to $DEST_DIR..."
    mv "$SOURCE_FILE" "$DEST_DIR/" || error_exit "Failed to move file"
    echo "✅ File moved successfully"
else
    echo "⚠️ Step 4: Source file $SOURCE_FILE not found, skipping move"
fi

# 5. Status message once all tasks finished
echo -e "\n🎉 All tasks completed successfully!\n"
