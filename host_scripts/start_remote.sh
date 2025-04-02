#!/usr/bin/env bash

# Software License Agreement (BSD License)
# Copyright © 2024-2025 belongs to Shadow Robot Company Ltd.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
# 3. Neither the name of Shadow Robot Company Ltd nor the names of its contributors
#     may be used to endorse or promote products derived from this software without
#     specific prior written permission.
# This software is provided by Shadow Robot Company Ltd "as is" and any express
# or implied warranties, including, but not limited to, the implied warranties of
# merchantability and fitness for a particular purpose are disclaimed. In no event
# shall the copyright holder be liable for any direct, indirect, incidental, special,
# exemplary, or consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business interruption)
# however caused and on any theory of liability, whether in contract, strict liability,
# or tort (including negligence or otherwise) arising in any way out of the use of this
# software, even if advised of the possibility of such damage.

CONTAINER_NAME=$PERSISTENT_CONTAINER_NAME

color_highlight=$(tput setaf 4)  # Blue
color_warn=$(tput setaf 3)       # Yellow
color_err=$(tput setaf 1)        # Red
color_normal=$(tput sgr0)

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -i|--remote_host_ip)
            REMOTE_HOST_ADDRESS="$2"
            shift
            ;;
        -u|--remote_user_name)
            REMOTE_USER_NAME="$2"
            shift
            ;;
        -c|--container_name)
            CONTAINER_NAME="$2"
            shift
            ;;
        -h|--help)
            echo "Syntax: terminator_in_remote_container [-i|-u|-c]"
            echo "options:"
            echo "  -i|--remote_host_ip:      Remote IP address of the host where the container is instaled"
            echo "  -u|--remote_user_name:    User name to access the remote host"
            echo "  -c|--container_name:      Container name. Defaults to '$CONTAINER_NAME'"
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

if [ -z "$REMOTE_HOST_ADDRESS" ] || [ -z "$REMOTE_USER_NAME" ]; then
        echo "${color_err}Missing specifying remote host address or remote host username.${color_normal}
${color_warn}Define them using -i|--remote_host_ip or -u|--remote_user_name${color_normal}" >&2
        exit 1
fi

echo "Will be trying to open a session to docker container ${color_highlight}$CONTAINER_NAME${color_normal} on"\
"${color_highlight}$REMOTE_USER_NAME@$REMOTE_HOST_ADDRESS${color_normal}..."

ssh -Xt $REMOTE_USER_NAME@$REMOTE_HOST_ADDRESS "docker start ${CONTAINER_NAME};
docker exec -i --user user $CONTAINER_NAME bash -c 'cat > ~/.Xauthority' < ~/.Xauthority;
docker exec -it --user user $CONTAINER_NAME /bin/bash -c $'export ROSCONSOLE_FORMAT=\'"'[${severity}](${node}): [${time}] ${message}'"\';
export ROSCONSOLE_STDOUT_LINE_BUFFERED=1;
source /home/user/projects/shadow_robot/base/devel/setup.bash;
export XAUTHORITY=/home/user/.Xauthority;
xauth list | tail -1 | awk \'{print \$1}\' | cut -d ':' -f2 > ~/.display_number;
export DISPLAY=localhost:\$(<~/.display_number).0;bash'"
