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

function handle_alias_file()
{
  # Args:
  #   1. The class of the alias file. "platform", "tool", "project", or empty string
  #   2. The name of the alias set.

  local alias_class=$1
  local aliases_dir=$HOME/.nrg_bash/aliases/$alias_class
  local alias_filename=$2_aliases
  local alias_path=$aliases_dir/$alias_filename
  
  # Create the subdirectory if it doesn't exist
  if [ ! -d "$aliases_dir" ]; then
    mkdir $aliases_dir
  fi
  
  # If we don't have the file, try to download it from the NRG GitHub
  if [ ! -f "$alias_path" ]; then
    echo "Downloading alias file $alias_filename to $aliases_dir"
    
    local github_location=https://github.com/UTNuclearRobotics/bash_aliases/blob/master
    $HOME/.nrg_bash/github_downloader.sh $github_location/$alias_class/$alias_filename $aliases_dir
  fi

  source $alias_path
}

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
  source $HOME/.nrg_bash/functions.sh
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
