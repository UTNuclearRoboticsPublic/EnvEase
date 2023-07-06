############################################################################################
# Copyright : Copyright© The University of Texas at Austin, 2023. All rights reserved.
#                
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of python-odmltables nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
############################################################################################

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

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
source $script_dir/functions.sh
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
    if [[ "$DIR" = /* ]]; then
      # absolute path
      source $ws/devel/setup.bash
    else
      # path relative to home directory
      source $HOME/$ws/devel/setup.bash
    fi
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
