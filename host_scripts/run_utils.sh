#!/usr/bin/env bash

# Software License Agreement (BSD License)
# Copyright © 2024-2025 belongs to Shadow Robot Company Ltd.
# All rights reserved.
#
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
#
# This software is provided by Shadow Robot Company Ltd "as is" and any express
# or implied warranties, including, but not limited to, the implied warranties of
# merchantability and fitness for a particular purpose are disclaimed. In no event
# shall the copyright holder be liable for any direct, indirect, incidental, special,
# exemplary, or consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business interruption)
# however caused and on any theory of liability, whether in contract, strict liability,
# or tort (including negligence or otherwise) arising in any way out of the use of this
# software, even if advised of the possibility of such damage.

function checkVolumeExists () {
    # Inspect if volume with same name already exists
    if echo "$(docker volume ls -f name=$1 | awk '{print $NF}' | grep -E '^'$1'$' | tr -d '\n')"; then
        return 0
    else
        return 1
    fi
}

function askUserInput() {
    while true; do
        read -p "Do you wish to continue? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

function checkValidUserSpaceOverlay() {
    # Check if selected docker volume already exists.
    # If a volume with the same name already exists, check that the mounted path on the host
    # is the same provided by the user. If not, throw an error, otherwise continue. 
    # If a volume does not exists, create one, mounting on the provided path on the host

    # If true, suppresses info/warnings related to new volume creation
    # and when attaching new containers to existing volumes
    # Errors will still be thrown
    SUPPRESS_WS_OVERLAY_CHECKS=$1

    color_highlight=$(tput setaf 4)  # Blue
    color_warn=$(tput setaf 3)       # Yellow
    color_err=$(tput setaf 1)        # Red
    color_normal=$(tput sgr0)

    # Check if docker volume with the same name already exists 
    VOLUME_NAME="$(basename $USER_PERSISTENT_WORKSPACE)"
    if [[ "$USER_PERSISTENT_WORKSPACE" = /* ]]; then  # Check is provided path is absolute, if not, make it absolute
        USER_PERSISTENT_WORKSPACE=$(echo "${USER_PERSISTENT_WORKSPACE%/}")  # Remove trailing slash
    else
        USER_PERSISTENT_WORKSPACE=$(echo "$(pwd)/${USER_PERSISTENT_WORKSPACE%/}")  # Remove trailing slash
    fi

    if [ $(checkVolumeExists $VOLUME_NAME) ]
    then
        if [ "$SUPPRESS_WS_OVERLAY_CHECKS" = false ] ; then
            printf "${color_warn}Warning: Docker Volume '${color_highlight}$VOLUME_NAME${color_warn}' already exists.${color_normal}\n"
        fi
        
        # Extract the path being mounted on the host for the selected docker volume
        EXISTING_VOLUME_DEVICE_PATH="$(docker volume inspect $VOLUME_NAME | grep '"device"' | awk -F: '{print $2}' | tr -d '",')"
        # Check if selected docker volume is already linking to a different path on the host machine
        if [ $EXISTING_VOLUME_DEVICE_PATH != $USER_PERSISTENT_WORKSPACE ]
        then
            printf "The new user workspace that you are trying to create for the new container\n shares the name with"\
            "a workspace that already exists in the host machine:\n"\
            "$(dirname $EXISTING_VOLUME_DEVICE_PATH)/${color_highlight}$VOLUME_NAME${color_normal}\n"
            printf "${color_err}Please update the path to match this one or provide a new path to a workspace with a different name than '${color_highlight}$VOLUME_NAME${color_err}'.${color_normal}\n"
            exit
        fi

        if [ "$SUPPRESS_WS_OVERLAY_CHECKS" = false ] ; then
            # Selected docker volume/workspace name has been found. Confirm the user wants to progress
            printf "The container you are about to create will share a user workspace\n"\
            "that already exists in the host machine:\n"\
            "$(dirname $EXISTING_VOLUME_DEVICE_PATH)/${color_highlight}$VOLUME_NAME${color_normal}\n"
            printf "${color_warn}If you do not wish to continue type n/no and select a different workspace using the -w flag.${color_normal}\n"

            askUserInput
        fi

        
    else
        if [ "$SUPPRESS_WS_OVERLAY_CHECKS" = false ] ; then
            # Selected docker volume/workspace name does not yet exist. Confirm the user wants to create a new one
            printf "Docker volume '${color_highlight}$VOLUME_NAME${color_normal}' does not yet exist."\
            "A new one will becreated.\n"
            printf "The container you are about to create will also create and share a new user\n"\
            "workspace with the host machine in:\n"\
            "$(dirname $USER_PERSISTENT_WORKSPACE)/${color_highlight}$VOLUME_NAME${color_normal}\n"

            askUserInput
        fi
    fi
}

function createDockerVolume () {

    # Does nothing if folder already exists. Creates parent directories as needed
    # Exits if folder cannot be created due to "Permission denied'.  
    if ! mkdir -p $USER_PERSISTENT_WORKSPACE ; then
        exit
    fi
    # Make sure path in USER_PERSISTENT_WORKSPACE is absolute
    cd $USER_PERSISTENT_WORKSPACE && USER_PERSISTENT_WORKSPACE="$(pwd)"

    # Create a new docker volume (does nothing if it already exists) 
    docker volume create --driver local \
        --opt type=none \
        --opt device=$USER_PERSISTENT_WORKSPACE \
        --opt o=bind \
        $VOLUME_NAME > /dev/null
}
