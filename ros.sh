############################################################################################
#      Copyright : Copyright© The University of Texas at Austin, 2022. All rights reserved.
#                
#          All files within this directory are subject to the following, unless an alternative
#          license is explicitly included within the text of each file.
#
#          This software and documentation constitute an unpublished work
#          and contain valuable trade secrets and proprietary information
#          belonging to the University. None of the foregoing material may be
#          copied or duplicated or disclosed without the express, written
#          permission of the University. THE UNIVERSITY EXPRESSLY DISCLAIMS ANY
#          AND ALL WARRANTIES CONCERNING THIS SOFTWARE AND DOCUMENTATION,
#          INCLUDING ANY WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#          PARTICULAR PURPOSE, AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY
#          THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF TRADE.
#          NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO THE USE OF
#          THE SOFTWARE OR DOCUMENTATION. Under no circumstances shall the
#          University be liable for incidental, special, indirect, direct or
#          consequential damages or loss of profits, interruption of business,
#          or related expenses which may arise from use of software or documentation,
#          including but not limited to those resulting from defects in software
#          and/or documentation, or loss or inaccuracy of data of any kind.
#
############################################################################################

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# ROS distribution to source
ros_distro=$1

# This will either be a...
# 1. ROS_MASTER_URI for a ROS1 system
# 2. ROS_DOMAIN_ID for a ROS2 system using multicasting
# 3. ROS_DISCOVERY_SERVER for a ROS2 system using FastDDS and discovery servers
discovery_method=$2

# The network interface we are using to connect (ROS 1 only)
net_intfce=$3

# List in order. Later workspaces override earlier ones
ros_workspaces=$4

# Determine if this is a ROS1 or ROS2 distribution.
source $SCRIPT_DIR/functions.sh
ros_version=$(get_ros_version_for_distribution $ros_distro)

if [ $ros_version -eq 1 ]; then
  # ROS1
  source /opt/ros/$ros_distro/setup.bash
  
  # Try to get IP address for the given network interface
  # Use this IP for the ROS_IP env variable
  get_ip_address $net_intfce
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
    ros2 daemon stop
    export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
    export FASTRTPS_DEFAULT_PROFILES_FILE=super_client_configuration_file.xml
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
unset net_intfce
