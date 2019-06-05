cmake_minimum_required(VERSION 2.8.3)
project(local_mapper)

find_package(catkin REQUIRED COMPONENTS
  rospy
  std_msgs
)

catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES roboteq_transfer_command
#  CATKIN_DEPENDS roboteq_msgs roscpp rospy std_msgs
#  DEPENDS system_lib
)

include_directories(
  ${catkin_INCLUDE_DIRS}
)

catkin_install_python(PROGRAMS
  nodes/local_mapper_singleshot_node
  nodes/local_mapper_cumulative_node
  nodes/ipm.py
  nodes/numpy_extra.py
  nodes/camera_ethernet_imx291.json
  nodes/transformations.py
  nodes/ground_project_node
  nodes/cv_bridge.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

