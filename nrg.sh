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

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# Look up our currently set NRG environment
source $HOME/.nrg_env/cur_env.sh

# Get our common aliases
source $SCRIPT_DIR/functions.sh
handle_alias_file "" "nrg_common" $NRG_VERBOSE

# Sets up bash tab completion for our nrgenv script
eval "$(register-python-argcomplete3 nrgenv)"

# Source the active NRG environment config
if [ $NRG_ENV == none ]; then
  echo "No NRG configuration set. Use the nrgenv command to set one."
  return
fi
source $HOME/.nrg_env/configs/$NRG_ENV.sh

# Input validation
if [[ -v ros_domain_id ]]; then
  if [ $ros_domain_id -lt 0 ] || [ $ros_domain_id -gt 232 ] || [[ $ros_domain_id -gt 101 && $ros_domain_id -lt 215 ]]; then
    echo "Invalid ROS_DOMAIN_ID value of $ros_domain_id. Must be in ranges [0,101] or [215,232]."
    return
  fi
fi

for k in "${platform_aliases[@]}"; do
  handle_alias_file "platform" $k $NRG_VERBOSE
done

for k in "${project_aliases[@]}"; do
  handle_alias_file "project" $k $NRG_VERBOSE
done

for k in "${tool_aliases[@]}"; do
  handle_alias_file "tool" $k $NRG_VERBOSE
done
unset k

# Set environment variables needed by ros1_bridge
if [ "${use_ros1_bridge}" == true ]; then
  # Make sure that both a ROS1 workspace and a ROS2 workspace are specified
  if [ ${#ros1_workspaces[@]} -eq 0 ] || [${#ros2_workspaces[@]} -eq 0]; then
    echo "Error: With use_ros1_bridge set true, you must specify both a ROS1 workspace and a ROS2 workspace."
    return
  fi

  ROS1_INSTALL_PATH=/opt/ros/${ros1_workspaces[0]}/setup.bash
  ROS2_INSTALL_PATH=/opt/ros/${ros2_workspaces[0]}/setup.bash
fi
# For each of the listed ROS distributions
for distro in "${ros_distros[@]}"; do
  # Determine if this is a ROS1 or ROS2 distribution.
  ros_version=$(get_ros_version_for_distribution $distro)
  
  # Call the ros.sh configuration script according to the ROS version
  if [ $ros_version -eq 1 ]; then
    if [ $NRG_VERBOSE ]; then
      echo "Using ROS 1 distribution: $distro"
      echo "  Workspaces: ${ros1_workspaces}"
    fi

    # ROS1
    source $SCRIPT_DIR/ros.sh ${distro} ${ros_master_uri} ${network_interface} ${ros1_workspaces}

  elif [ $ros_version -eq 2 ]; then
    # ROS2
    if [ $NRG_VERBOSE ]; then
      echo "Using ROS 2 distribution: $distro"
      echo "  Workspaces: ${ros2_workspaces}"
      echo "  ros_master_uri: $ros_master_uri"
    fi

    if [ -v ros_domain_id ]; then
      # Use normal ROS2 discovery using multicasting
      source $SCRIPT_DIR/ros.sh ${distro} ${ros_domain_id} "" ${ros2_workspaces}

      if [ $NRG_VERBOSE ]; then
        echo "  With ROS_DOMAIN_ID: ${ros_domain_id}"
      fi
    else
      # Use discovery server with FastDDS
      source $SCRIPT_DIR/ros.sh ${distro} ${ros_discovery_server} "" ${ros2_workspaces} --discovery_server

      if [ $NRG_VERBOSE ]; then
        echo "  With FastDDS discovery server at: ${ros_discovery_server}"
      fi
    fi
  
  else
    echo "Invalid ROS distribution '${distro}' selected."
    return
  fi
  unset ros_version
done

if [ $NRG_VERBOSE ] && [ $use_ros1_bridge ]; then
  echo "Using ros1_bridge"
  echo "  With ROS1_INSTALL_PATH: $ROS1_INSTALL_PATH"
  echo "  With ROS2_INSTALL_PATH: $ROS2_INSTALL_PATH"
fi

# cleanup
unset SCRIPT_DIR
unset distro
unset ros_distros
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
unset NRG_VERBOSE