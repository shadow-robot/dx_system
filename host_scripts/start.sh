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

# See http://wiki.ros.org/docker/Tutorials/Hardware%20Acceleration

set -euo pipefail

# See README.md for building this image.
CONTAINER_NAME="${1:-dx_persistent}"

XAUTH_DOCKER=/tmp/.docker.xauth

XAUTH=$HOST_SCRIPTS_PATH/.tmp/docker.xauth

if [ ! -d $HOST_SCRIPTS_PATH/.tmp ]
then
    mkdir $HOST_SCRIPTS_PATH/.tmp
fi

xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
if [ ! -z "$xauth_list" ]
then
    echo "$xauth_list" | xauth -f $XAUTH nmerge -
else
    touch $XAUTH
fi
chmod a+r $XAUTH

docker start $CONTAINER_NAME
