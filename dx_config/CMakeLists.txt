cmake_minimum_required(VERSION 3.0.2)
project(dx_config)

find_package(catkin REQUIRED COMPONENTS
  dx_controllers
  dx_robot
)

catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES dx_config
#  CATKIN_DEPENDS dx_controllers dx_robot
#  DEPENDS system_lib
)

###########
## Build ##
###########

## Specify additional locations of header files
## Your package locations should be listed before other locations
include_directories(
# include
  ${catkin_INCLUDE_DIRS}
)

#############
## Install ##
#############

## Mark other files for installation (e.g. launch and bag files, etc.)
# install(FILES
#   # myfile1
#   # myfile2
#   DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
# )
