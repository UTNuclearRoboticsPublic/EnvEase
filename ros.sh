#!/bin/bash

# ROS distribution to source
ros_distro=$1

# This will either be a...
# 1. ROS_MASTER_URI for a ROS1 system
# 2. ROS_DOMAIN_ID for a ROS2 system using multicasting
# 3. ROS_DISCOVERY_SERVER for a ROS2 system using FastDDS and discovery servers
discovery_method=$2

# The network interface we are using to connect (ROS 1 only)
network_interface=$3

# List in order. Later workspaces override earlier ones
ros_workspaces=$4



function get_ip_address()
{
  # Gets the IP address of a given interface name
  ip_addr=$(ip -4 addr show $1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
}

# Determine if this is a ROS1 or ROS2 distribution.
source $HOME/.nrg_bash/functions.sh
ros_version=$(get_ros_version_for_distribution $ros_distro)

if [ $ros_version -eq 1 ]; then
  # ROS1
  source /opt/ros/$ros_distro/setup.bash
  
  # Try to get IP address for the given network interface
  # Use this IP for the ROS_IP env variable
  get_ip_address $network_interface
  if [[ ! -v ip_addr || $ip_addr == "" ]]; then
    echo "Invalid network interface given."
    return
  fi
  export ROS_IP=$ip_addr
  unset ip_addr
  
  for ws in ${ros_workspaces[@]}; do
    source $HOME/$ws/devel/setup.bash
  done
  unset ws
  
  export PATH=$HOME/catkin-docker:$PATH
  export ROS_MASTER_URI=$discovery_method
elif [ $ros_version -eq 2 ]; then
  # ROS2  
  source /opt/ros/$ros_distro/setup.bash
  source /usr/share/colcon_cd/function/colcon_cd.sh
  export _colcon_cd_root=/opt/ros/$ros_distro/
  source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
  
  for ws in ${ros_workspaces[@]}; do
    . $HOME/$ws/install/setup.bash
  done
  unset ws
  
  # Set ROS_DOMAIN_ID or discovery server
  if [[ $* == *--discovery_server* ]]; then
    # configure discovery server using FastDDS
    export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
    export FASTRTPS_DEFAULT_PROFILES_FILE=super_client_configuration_file.xml
    ros2 daemon stop
    ros2 daemon start
    export ROS_DISCOVERY_SERVER=$discovery_method
  else
    # normal ROS2 discovery using multicasting
    export ROS_DOMAIN_ID=$discovery_method
  fi
else
  # Invalid ROS distribution selected
  echo "Invalid ROS distribution '${ros_distro}' selected." 
  return
fi

unset ros_distro
unset discovery_method
unset ros_workspaces
unset ros_version
