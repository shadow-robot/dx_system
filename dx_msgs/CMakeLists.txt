cmake_minimum_required(VERSION 2.8.3)
project(dx_msgs)

find_package(catkin REQUIRED COMPONENTS message_generation std_msgs sensor_msgs)

## Generate messages in the 'msg' folder
add_message_files(
  FILES
  DxFingerState.msg
  DxOneFingerState.msg
  DxData.msg
  DxState.msg
  DxCommand.msg
  DxHeader.msg
  DxEffortControllerState.msg
  DxPositionControllerState.msg
  DxPositionEffortControllerState.msg
  DxActuatorOdometry.msg
  DxMagTacElement.msg
  DxMagTacSensor.msg
  DxSafeMode.msg
  DxHandInfo.msg
)
add_service_files(
  FILES
  DxFANCallBootloader.srv
  DxFANBootloadImage.srv
  DxCameraReadRegister.srv
  DxCameraReset.srv
  DxCameraWriteRegister.srv
  DxGetHandInfo.srv
  DxSetSafeMode.srv
  DxGetSafeMode.srv
  DxGetSafeModeStoreInfo.srv
  DxGetSafeModeState.srv
  DxResetOdometry.srv
)

## Generate added messages and services with any dependencies listed here
generate_messages(
  DEPENDENCIES
  std_msgs
  sensor_msgs
)


catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES dms_msgs
  CATKIN_DEPENDS message_runtime std_msgs sensor_msgs
#  DEPENDS system_lib
)
