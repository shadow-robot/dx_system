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

alias dx_cd_host_scripts='cd $HOST_SCRIPTS_PATH'

# Run/start persistent or stateless containers
alias dx_run_stateless_container='"$HOST_SCRIPTS_PATH"/run_stateless.sh'
alias dx_run_persistent_container='"$HOST_SCRIPTS_PATH"/run_persistent.sh'
alias dx_start_persistent_container='"$HOST_SCRIPTS_PATH"/start.sh'
alias dx_start_remote_container='"$HOST_SCRIPTS_PATH"/start_remote.sh'

# Interact with stateless containers
function dx_bash_in_stateless_container() {
    container_name="${1:-$STATELESS_CONTAINER_NAME}"
    docker exec -it --user user $container_name bash
}
function dx_terminator_in_stateless_container() {
    container_name="${1:-$STATELESS_CONTAINER_NAME}"
    docker exec -it --user user $container_name terminator
}
function dx_stop_stateless_container() {
    container_name="${1:-$STATELESS_CONTAINER_NAME}"
    docker stop $container_name
}

# Interact with persistent containers
function dx_bash_in_persistent_container() {
    container_name="${1:-$PERSISTENT_CONTAINER_NAME}"
    docker exec -it --user user $container_name bash
}
function dx_terminator_in_persistent_container() {
    container_name="${1:-$PERSISTENT_CONTAINER_NAME}"
    docker exec -it --user user $container_name terminator
}
function dx_stop_persistent_container() {
    container_name="${1:-$PERSISTENT_CONTAINER_NAME}"
    docker stop $container_name
}
