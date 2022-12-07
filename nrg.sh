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

####################
### DO NOT TOUCH ###
####################

# Directory of this script (normally /opt/nuclearrobotics)
script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# Various functions
source $script_dir/functions.sh

# Look up our currently active NRG environment
source $HOME/.nrg_env/cur_env.sh

if [ -z $NRG_ENV ]; then
  echo "Error: Variable NRG_ENV not found in $HOME/.nrg_env/cur_env.sh. The file is deformed."
  return
fi

if [ -z $NRG_VERBOSE ]; then
  echo "Error: Variable NRG_VERBOSE not found in $HOME/.nrg_env/cur_env.sh. The file is deformed."
  return
fi

if [ "$NRG_VERBOSE" == true ]; then
  echo "Active environment configuration: $NRG_ENV"
fi

# Get our common aliases
handle_alias_file "" "nrg_common"

# Enables tab completion in bash for our nrgenv script
eval "$(register-python-argcomplete3 nrgenv)"

# Source the active NRG environment config
if [ $NRG_ENV == none ]; then
  echo "No NRG configuration set. Use the nrgenv command to set one."
  return
fi
source $HOME/.nrg_env/configs/$NRG_ENV.sh

for k in "${platform_aliases[@]}"; do
  handle_alias_file "platform" $k
done

for k in "${project_aliases[@]}"; do
  handle_alias_file "project" $k
done

for k in "${tool_aliases[@]}"; do
  handle_alias_file "tool" $k
done
unset k


# If we have specified both ROS1 and ROS2 distributions,
# then set the extra environment variables needed by ros1_bridge
if [ ! -z $ros1_distribution ] && [ ! -z $ros2_distribution ]; then
  export ROS1_INSTALL_PATH=/opt/ros/${ros1_distribution}/setup.bash
  export ROS2_INSTALL_PATH=/opt/ros/${ros2_distribution}/setup.bash

  if [ "$NRG_VERBOSE" == true ]; then
    echo "Using ros1_bridge from $ros1_distribution to $ros2_distribution"
  fi
else
  unset ROS1_INSTALL_PATH
  unset ROS2_INSTALL_PATH
fi

# clear any pre-existing variables
unset ROS_DISTRO
unset ROS_IP
unset ROS_MASTER_URI
unset RMW_IMPLEMENTATION
unset FASTRTPS_DEFAULT_PROFILES_FILE
unset ROS_DISCOVERY_SERVER
unset ROS_DOMAIN_ID

# ROS1
if [ ! -z $ros1_distribution ]; then
  if [ -z $ros_master_uri ]; then
    echo "Error: ros_master_uri must be provided for a ROS 1 distribution."
  elif [ -z $network_interface ]; then
    echo "Error: network_interface must be provided for a ROS 1 distribution."
  else
    if [ "$NRG_VERBOSE" == true ]; then
      echo "Using ROS 1 distribution: $ros1_distribution"
      echo "  Workspaces: $ros1_workspaces"
      echo "  ros_master_uri: $ros_master_uri"
    fi
    source $script_dir/ros.sh $ros1_distribution $ros_master_uri $network_interface $ros1_workspaces
  fi
fi

# suppresses an annoying warning when using a mixed-distribution environment
unset ROS_DISTRO

# ROS2
if [ ! -z $ros2_distribution ]; then
  if [ "$NRG_VERBOSE" == true ]; then
    echo "Using ROS 2 distribution: $ros2_distribution"
    echo "  Workspaces: $ros2_workspaces"
  fi

  if [ ! -z $ros_domain_id ]; then
    # Input validation
    if [ $ros_domain_id -lt 0 ] || [ $ros_domain_id -gt 232 ] || [[ $ros_domain_id -gt 101 && $ros_domain_id -lt 215 ]]; then
      echo "Invalid ROS_DOMAIN_ID value of $ros_domain_id. Must be in ranges [0,101] or [215,232]."
      return
    fi

    # Use normal ROS2 discovery using multicasting
    source $script_dir/ros.sh $ros2_distribution $ros_domain_id "" $ros2_workspaces

    if [ "$NRG_VERBOSE" == true ]; then
      echo "  ROS_DOMAIN_ID: $ros_domain_id"
    fi
  elif [ ! -z $ros_discovery_server ]; then
    # Use discovery server with FastDDS
    source $script_dir/ros.sh $ros2_distribution $ros_discovery_server "" $ros2_workspaces --discovery_server

    if [ "$NRG_VERBOSE" == true ]; then
      echo "  FastDDS discovery server at: $ros_discovery_server"
    fi
  else
    echo "Error: ros_domain_id or ros_discovery_server must be provided for a ROS2 distribution."
  fi
fi

# cleanup
unset script_dir
unset ros1_distribution
unset ros2_distribution
unset ros1_workspaces
unset ros2_workspaces
unset ros_master_uri
unset ros_domain_id
unset ros_discovery_server
unset platform_aliases
unset project_aliases
unset tool_aliases
unset network_interface
unset use_ros1_bridge