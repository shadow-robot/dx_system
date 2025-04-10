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

alias dx_integration_test='roslaunch dx_test_controller automated_integration_test.launch'
alias dx_acceptance_test='roslaunch dx_test_controller automated_acceptance_test.launch'
alias dx_tactile_test='roslaunch dx_test_controller tactile_test.launch'
alias dx_start_no_control='roslaunch dx_robot controllers_not_started.launch'
alias dx_start='roslaunch dx_robot start_dexee.launch'
alias dx_start_driver_only='roslaunch dx_robot driver_only.launch'
alias dx_start_distals='roslaunch dx_robot start_distals.launch'
alias dx_view_distals='roslaunch dx_robot distal_viewer.launch'
alias dx_clean_logs='rosrun sr_logging_common clean_logs.py'
alias dx_killall_ros="ps aux | grep ros | sed 's/[^0-9]*\([0-9]*\).*/\1/' | xargs kill -9"
alias dx_plotjuggler='rosrun plotjuggler plotjuggler'
alias dx_start_hand_and_arm='roslaunch dx_launch start_arm_and_hand_0.launch'
alias dx_reactivate_trajectory_control='rosrun dx_user_tools reactivate_trajectory_controller'
alias dx_roscd_base='cd /home/$USER/projects/shadow_robot/base'
alias dx_roscd_deps='cd /home/$USER/projects/shadow_robot/base_deps'
alias dx_roscd_user='cd /home/$USER/workspace'
