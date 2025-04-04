#!/bin/bash
 
# Software License Agreement (BSD License)
# Copyright © 2025 belongs to Shadow Robot Company Ltd.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#   1. Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
#   2. Redistributions in binary form must reproduce the above copyright notice,
#      this list of conditions and the following disclaimer in the documentation
#      and/or other materials provided with the distribution.
#   3. Neither the name of Shadow Robot Company Ltd nor the names of its contributors
#      may be used to endorse or promote products derived from this software without
#      specific prior written permission.
# This software is provided by Shadow Robot Company Ltd "as is" and any express
# or implied warranties, including, but not limited to, the implied warranties of
# merchantability and fitness for a particular purpose are disclaimed. In no event
# shall the copyright holder be liable for any direct, indirect, incidental, special,
# exemplary, or consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business interruption)
# however caused and on any theory of liability, whether in contract, strict liability,
# or tort (including negligence or otherwise) arising in any way out of the use of this
# software, even if advised of the possibility of such damage.

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' 

DEVELOPMENT=false
KERNEL_URL="https://s3.eu-west-2.amazonaws.com/com.shadowrobot.eu-west-2.public/linux-image-6.5.2-rt8_6.5.2-3_amd64.deb"
KERNEL_LOCATION="/tmp/rtkernel.deb"


# Print colour functions
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

install_kernel() {
    print_yellow "Installing RT kernel..."  
    # Check if kernel is already installed
    if dpkg -l | grep -q "linux-image-6.5.2-rt8"; then
        print_yellow "RT kernel is already installed"
        return 0
    fi

    # Install the kernel and set it as the default grub option
    wget -O "$KERNEL_LOCATION" "$KERNEL_URL" >/dev/null || { print_red "Failed to download kernel"; exit 1; } 
    sudo dpkg -i "$KERNEL_LOCATION" >/dev/null || { print_red "Failed to install kernel"; exit 1; }
    rm -f "$KERNEL_LOCATION" || { print_yellow "Warning: Failed to remove kernel package"; }
    print_yellow "Updating GRUB configuration..."
    sudo cp /etc/default/grub /etc/default/grub.bak || { print_red "Failed to backup GRUB configuration"; exit 1; }
    sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub || { print_red "Failed to update GRUB timeout"; exit 1; }
    sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 6.5.2-rt8"/' /etc/default/grub || { print_red "Failed to update GRUB default kernel"; exit 1; }
    sudo update-grub || { print_red "Failed to update GRUB"; exit 1; }
    
    print_green "RT kernel installation complete"

}

    # Set up docker groups and add the user to it
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

    # Download and install the awscli
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

    # Prompt for AWS login
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

    # Clone Host Scripts and move to home
clone_host_scripts() {
    print_yellow "Cloning host scripts..."
    # Create temporary directory
    local temp_dir="/tmp/host_scripts/"
    mkdir -p "$temp_dir" || { print_red "Failed to create temporary directory"; exit 1; }
    
    # Clone repository
    cd "$temp_dir" || { print_red "Failed to change to temporary directory"; exit 1; }
    git clone -n --depth=1 --filter=tree:0 https://github.com/shadow-robot/dx_system.git . || { print_red "Failed to clone repository"; exit 1; }
    
    # Configure sparse checkout
    git sparse-checkout --no-cone /host_scripts || { print_red "Failed to configure sparse checkout"; exit 1; }
    git checkout || { print_red "Failed to checkout host_scripts"; exit 1; }
    
    mv host_scripts "/home/$USER/" || { print_red "Failed to move host_scripts"; exit 1; }
    
    # Cleanup
    cd "/home/$USER" || { print_yellow "Warning: Failed to change back to home directory"; }
    rm -rf "$temp_dir" || { print_yellow "Warning: Failed to remove temporary directory"; }
    
    print_green "Host scripts cloned successfully"
}

append_bashrc(){
    # Append the setup.bash into the bashrc
    print_yellow "Setting up bashrc"
    grep -qxF 'source /home/$USER/host_scripts/setup.bash' ~/.bashrc || echo 'source /home/$USER/host_scripts/setup.bash' >> ~/.bashrc
    source ~/.bashrc
    print_green "bashrc setup complete"
}

pull_dx_image() {
    source /home/$USER/host_scripts/environment.sh
    IMAGE="080653068785.dkr.ecr.eu-west-2.amazonaws.com/${IMAGE_REPOSITORY}:${IMAGE_TAG_FLAVOUR}-v${IMAGE_TAG_VERSION}

"
    print_yellow "Pulling image: $IMAGE"
    docker pull "$IMAGE" || { print_red "Failed to pull image"; exit 1; }
}

clear_credentials(){
    print_yellow "Removing AWS creds and signing out of docker"
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_PROFILE
    rm -f ~/.aws/credentials
    rm -f ~/.aws/config
    aws ecr get-login-password | docker logout 080653068785.dkr.ecr.eu-west-2.amazonaws.com ||{ print_red "Failed to logout of ECR"; exit 1; }
    docker logout $(docker info | grep 'Username' | awk '{print $2}')
    print_green "Credentials cleared"
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

install_apps
install_kernel
configure_docker
install_awscli
authenticate_aws
clone_host_scripts
append_bashrc
pull_dx_image
clear_credentials

print_green "Installation completed successfully! Please reboot your system to use the new RT kernel."
