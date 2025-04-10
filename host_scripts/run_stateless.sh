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

# See http://wiki.ros.org/docker/Tutorials/Hardware%20Acceleration

set -euo pipefail

# Arguments:
CONTAINER_NAME=$STATELESS_CONTAINER_NAME
SUPPRESS_WS_OVERLAY_CHECKS=false

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -p|--ethercat_port)
            ETHERCAT_PORT="$2"
            shift
            ;;
        -c|--container_name)
            CONTAINER_NAME="$2"
            shift
            ;;
        -v|--image_tag_version)
            IMAGE_TAG_VERSION="$2"
            shift
            ;;
        -f|--image_tag_flavour)
            IMAGE_TAG_FLAVOUR="$2"
            shift
            ;;
        -r|--image_repository)
            IMAGE_REPOSITORY="$2"
            shift
            ;;
        -w|--user_workspace)
            USER_PERSISTENT_WORKSPACE="$2"
            shift
            ;;
        -s|--suppress_ws_overlay_checks)
            SUPPRESS_WS_OVERLAY_CHECKS=true
            ;;
        -h|--help)
            echo "Syntax: run_stateless_container [-p|-c|-v|-f|-r|-w]"
            echo "options:"
            echo "  -p|--ethercat_port:       DEX-EE's EtherCAT port. Defaults to '$ETHERCAT_PORT' (defined in environment.sh)"
            echo "  -c|--container_name:      New container name. Defaults to '$CONTAINER_NAME'"
            echo "  -v|--image_tag_version:   Docker image tag version. Defaults to '$IMAGE_TAG_VERSION'"
            echo "  -f|--image_tag_flavour:   Docker image tag flavour. Defaults to '$IMAGE_TAG_FLAVOUR'"
            echo "  -r|--image_repository:    Docker image repository. Defaults to '$IMAGE_REPOSITORY'"
            echo "  -w|--user_workspace:      Path to persistent user workspace overlay (in the host machine). Defaults to '$USER_PERSISTENT_WORKSPACE/'"
            echo "  -s|--suppress_ws_overlay_checks: Suppress workspace overlay checks. Defaults to '$SUPPRESS_WS_OVERLAY_CHECKS'"
            exit
            ;;
        *)
            # unknown option
            printf "Error: Argument '$key' not recognised\n"
            exit
            ;;
    esac
    shift
done

#Source script with utility functions necessary to run this script
. $HOST_SCRIPTS_PATH/run_utils.sh

DOCKER_IMAGE=080653068785.dkr.ecr.eu-west-2.amazonaws.com/$IMAGE_REPOSITORY:${IMAGE_TAG_FLAVOUR}-v${IMAGE_TAG_VERSION}

XSOCK=/tmp/.X11-unix

XAUTH=$HOST_SCRIPTS_PATH/.tmp/docker.xauth

if [ ! -d $HOST_SCRIPTS_PATH/.tmp ]
then
    mkdir $HOST_SCRIPTS_PATH/.tmp
fi

XAUTH_DOCKER=/tmp/.docker.xauth

if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

checkValidUserSpaceOverlay $SUPPRESS_WS_OVERLAY_CHECKS

createDockerVolume

docker run --rm -itd \
    --name "$CONTAINER_NAME" \
    --env="LOCAL_USER_ID=$(id -u)" \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH_DOCKER" \
    --env="ETHERCAT_PORT=$ETHERCAT_PORT" \
    --env="ROS_MASTER_URI=$ROS_MASTER_URI" \
    --env="ROS_IP=$ROS_IP" \
    --volume="$XSOCK:$XSOCK:rw" \
    --volume="$XAUTH:$XAUTH_DOCKER:rw" \
    --volume="/home/$USER/.ros:/home/user/.ros/:rw" \
    --volume="$VOLUME_NAME:/home/user/workspace:rw" \
    --volume="/dev:/dev:rw" \
    --security-opt seccomp=unconfined --network=host --pid=host --privileged --ipc=host\
    $DOCKER_IMAGE bash

docker cp $HOST_SCRIPTS_PATH/.bash_aliases ${CONTAINER_NAME}:/home/user/ > /dev/null
