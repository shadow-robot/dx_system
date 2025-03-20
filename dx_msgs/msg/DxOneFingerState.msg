Header header
string name

float64 motor_voltage
uint16 motor_voltage_raw

string[] joint_name
float64[] joint_position
uint16[] joint_position_raw
float64[] joint_velocity
float64[] joint_effort
float64[] joint_commanded_effort
float64[] joint_commanded_position
float64[] joint_commanded_velocity
float64[] joint_commanded_position_effort
float64[] joint_commanded_feedforward_effort

string[] actuator_name

float64[] actuator_position
float64[] actuator_temperature
float64[] actuator_velocity
float64[] actuator_effort
int32[] actuator_effort_raw
int16[] clutch_position
int16[] clutch_slip
float64[] actuator_current
uint16[] actuator_flags
int16[] actuator_pwm
float64[] actuator_commanded_efforts
string[] actuator_command_types

float64[] reference_loadcell_effort
uint16[] reference_loadcell_effort_raw
DxActuatorOdometry[] actuator_odometry
string[] magtac_name
DxMagTacSensor[] magtac_sensors

sensor_msgs/Imu[] imu_state
