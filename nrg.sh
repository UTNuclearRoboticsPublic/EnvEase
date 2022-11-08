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

source $HOME/.nrg_bash/config.sh

# Input validation
if [[ -v ros_domain_id ]]; then
  if [ $ros_domain_id -lt 0 ] || [ $ros_domain_id -gt 232 ] || [[ $ros_domain_id -gt 101 && $ros_domain_id -lt 215 ]]; then
    echo "Invalid ROS_DOMAIN_ID value of $ros_domain_id. Must be in ranges [0,101] or [215,232]."
    return
  fi
fi

source $HOME/.nrg_bash/functions.sh

handle_alias_file "" "nrg_common"

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



# For each of the listed ROS distributions
for distro in "${ros_distros[@]}"; do

  # Determine if this is a ROS1 or ROS2 distribution.
  ros_version=$(get_ros_version_for_distribution $distro)
  
  # Call the ros.sh configuration script according to the ROS version
  if [ $ros_version -eq 1 ]; then
    # ROS1
    source $HOME/.nrg_bash/ros.sh ${distro} ${ros_master_uri} ${network_interface} ${ros1_workspaces}
  
  elif [ $ros_version -eq 2 ]; then
    # ROS2
    if [ -v ros_domain_id ]; then
      # Use normal ROS2 discovery using multicasting
      source $HOME/.nrg_bash/ros.sh ${distro} ${ros_domain_id} "" ${ros2_workspaces}
    else
      # Use discovery server with FastDDS
      source $HOME/.nrg_bash/ros.sh ${distro} ${ros_discovery_server} "" ${ros2_workspaces} --discovery_server
    fi
  
  else
    echo "Invalid ROS distribution '${ros_distro}' selected."
    return
  fi
  unset ros_version
done

# cleanup
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
