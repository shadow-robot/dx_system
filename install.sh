
# Copyright (C) 2025 Shadow Robot Company Ltd - All Rights Reserved. Proprietary and Confidential.
# Unauthorized copying of the content in this file, via any medium is strictly prohibited.

#!/bin/bash

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' 

# Global variables
DEVELOPMENT=false
KERNEL_URL="https://s3.eu-west-2.amazonaws.com/com.shadowrobot.eu-west-2.public/linux-image-6.5.2-rt8_6.5.2-3_amd64.deb"
KERNEL_LOCATION="/tmp/rtkernel.deb"

print_red() {
    echo -e "${RED}$1${NC}"
}

print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

print_blue() {
    echo -e "${BLUE}$1${NC}"
}

print_startup_message() {
    print_yellow "================================================================="
    print_yellow "|                                                               |"
    print_yellow "|                 Shadow Dexee Deployment Tool                  |"
    print_yellow "|                                                               |"
    print_yellow "================================================================="
    print_yellow ""
    print_yellow "Possible options:"
    print_yellow "  * --dev           Install the development container"
    print_yellow "  * --help          Print this help"
}

install_apps() {
    print_yellow "Updating package repositories..."
    sudo apt update >/dev/null || { print_red "Failed to update repositories"; exit 1; }
    
    print_yellow "Upgrading system packages..."
    sudo apt upgrade -y >/dev/null || { print_red "Failed to upgrade packages"; exit 1; }
    
    print_yellow "Installing required packages (Terminator, Docker, OpenSSH, Curl)..."
    sudo apt install -y terminator docker.io openssh-server curl || { print_red "Failed to install packages"; exit 1; }
    
    print_green "Package installation complete"
}

install_RTkernel() {
    print_yellow "Installing RT kernel..."
    
    # Check if kernel is already installed
    if dpkg -l | grep -q "linux-image-6.5.2-rt8"; then
        print_yellow "RT kernel is already installed"
        return 0
    fi

    wget -O "$KERNEL_LOCATION" "$KERNEL_URL" >/dev/null || { print_red "Failed to download kernel"; exit 1; }
    sudo dpkg -i "$KERNEL_LOCATION" >/dev/null || { print_red "Failed to install kernel"; exit 1; }
    rm -f "$KERNEL_LOCATION" || { print_yellow "Warning: Failed to remove kernel package"; }
    
    print_green "RT kernel installation complete"
}

configure_docker() {
    print_yellow "Setting up Docker..."
    if ! getent group docker >/dev/null; then
        sudo groupadd docker || { print_red "Failed to create docker group"; exit 1; }
    fi
    
    if ! groups "$USER" | grep -q docker; then
        sudo usermod -aG docker "$USER" || { print_red "Failed to add user to docker group"; exit 1; }
    fi
    
    print_green "Docker setup complete"
    print_yellow "Please log out and log back in for Docker group changes to take effect"
}

install_awscli() {
    print_yellow "Installing AWS CLI..."
    if ! command -v aws &> /dev/null; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || { print_red "Failed to download AWS CLI"; exit 1; }
        unzip -q awscliv2.zip || { print_red "Failed to extract AWS CLI"; exit 1; }
        sudo ./aws/install || { print_red "Failed to install AWS CLI"; exit 1; }
        rm -rf awscliv2.zip aws || { print_red "Failed to clean up AWS CLI installation files"; exit 1; }
    else
        print_yellow "AWS CLI is already installed"
    fi
    
    mkdir -p ~/.ros || { print_red "Failed to create .ros directory"; exit 1; }
    print_green "AWS CLI installation complete"
}

authenticate_aws() {
    print_yellow "Please sign into AWS..."
    aws configure || { print_red "AWS configuration failed"; exit 1; }
    
    if [ "$DEVELOPMENT" = true ]; then
        print_yellow "Authenticating with development ECR..."
        aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 080653068785.dkr.ecr.eu-west-2.amazonaws.com || { print_red "Failed to authenticate with development ECR"; exit 1; }
    else
        print_yellow "Authenticating with public ECR..."
        aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/shadowrobot || { print_red "Failed to authenticate with public ECR"; exit 1; }
    fi
}

clone_host_scripts() {
    print_yellow "Cloning host scripts..."
    
    local home_dir="/home/$USER"
    local target_dir="$home_dir/host_scripts"
    
    # Check if host_scripts already exists
    if [ -d "$target_dir" ]; then
        print_yellow "host_scripts directory already exists, skipping clone"
        return 0
    fi
    
    # Create temporary directory
    local temp_dir="$home_dir/dx_system"
    mkdir -p "$temp_dir" || { print_red "Failed to create temporary directory"; exit 1; }
    
    # Clone repository
    cd "$temp_dir" || { print_red "Failed to change to temporary directory"; exit 1; }
    git clone -n --depth=1 --filter=tree:0 https://github.com/shadow-robot/dx_system.git . || { print_red "Failed to clone repository"; exit 1; }
    
    # Configure sparse checkout
    git sparse-checkout --no-cone /host_scripts || { print_red "Failed to configure sparse checkout"; exit 1; }
    git checkout || { print_red "Failed to checkout host_scripts"; exit 1; }
    
    # Move host_scripts to home directory
    mv host_scripts "$home_dir/" || { print_red "Failed to move host_scripts"; exit 1; }
    
    # Cleanup
    cd "$home_dir" || { print_yellow "Warning: Failed to change back to home directory"; }
    rm -rf "$temp_dir" || { print_yellow "Warning: Failed to remove temporary directory"; }
    
    print_green "Host scripts cloned successfully"
}

# Main script execution
print_startup_message

# Parse command line arguments
for arg in "$@"; do
    case "$arg" in
        --dev)
            DEVELOPMENT=true
            print_red "Development environment will be installed"
            ;;
        --help)
            print_startup_message
            exit 0
            ;;
        *)
            print_red "Unknown option: $arg"
            print_startup_message
            exit 1
            ;;
    esac
done

# Execute installation steps
install_apps
install_RTkernel
configure_docker
install_awscli
authenticate_aws
clone_host_scripts

print_green "Installation completed successfully!"