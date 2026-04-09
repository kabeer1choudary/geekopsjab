# Use Ubuntu as the base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        python3 \
        python3-pip \
        sshpass \
        git \
        ansible && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Default command
CMD ["ansible-playbook", "--version"]