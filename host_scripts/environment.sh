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

export ROS_IP=172.17.0.1
export ROS_MASTER_URI=http://$ROS_IP:11311
export ETHERCAT_PORT=eno1  # Ethercat port where DEX-EE is connected to
export IMAGE_TAG_FLAVOUR="noetic"  # Default docker image tag flavour
export IMAGE_TAG_VERSION="1.0.0"  # Default docker image tag version
export IMAGE_REPOSITORY="shadow-dx-host-binary"  # Alternativly use "shadow-dx-host"
export USER_PERSISTENT_WORKSPACE="/home/$USER/user_ws_code"  # Path to the user overlay workspace on the host machine
export PERSISTENT_CONTAINER_NAME="dx_persistent"  # Default name for persistent containers
export STATELESS_CONTAINER_NAME="dx_stateless"  # Default name for stateless containers
