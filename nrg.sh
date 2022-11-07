### ROS User Parameters ###
## Common ROS Variables
ros_distros=("galactic" "noetic")

# List ROS workspaces in order. Later workspaces override earlier ones
ros1_workspaces=()
ros2_workspaces=("lanl_ws")

## ROS1 Specific Variables
ros_master_uri=http://localhost:11311/

## ROS2 Specific Variables
# Comment this out if you want to use FastDDS discovery servers
ros_domain_id=0

# This will be used to connect to FastDDS discovery server(s)
# This should be the IP or hostname of the machine(s) running the discovery server(s)
# Generally, discovery servers function similarly to ROS1's master URI
# Separate machine names with semicolons
# This is ignored if ros_domain_id is defined above!
ros_discovery_server="localhost:11311"



### List project or platform specific alias sets needed for your work ###
# https://github.com/UTNuclearRobotics/bash_aliases
platform_aliases=("spot" "walrus")
project_aliases=("arl_phoenix")























####################
### DO NOT TOUCH ###
####################

# Input validation
if [[ -v ros_domain_id ]]; then
  if [ $ros_domain_id -lt 0 ] || [ $ros_domain_id -gt 232 ] || [[ $ros_domain_id -gt 101 && $ros_domain_id -lt 215 ]]; then
    echo "Invalid ROS_DOMAIN_ID value of $ros_domain_id. Must be in ranges [0,101] or [215,232]."
    return
  fi
fi


# Robot and project specific aliases
for k in "${platform_aliases[@]}" "${project_aliases[@]}" "nrg_common"; do

  aliases_dir=$HOME/.nrg_bash/aliases
  alias_filename=${k}_aliases
  alias_path=$aliases_dir/$alias_filename

  # If we don't have the file, try to download it from the NRG GitHub
  if [ ! -f "$alias_path" ]; then
    echo "Downloading alias file $alias_filename to $aliases_dir"
    
    github_location=https://github.com/UTNuclearRobotics/bash_aliases/blob/master
    $HOME/.nrg_bash/github_downloader.sh $github_location/$alias_filename $aliases_dir
  fi

  source $alias_path
  
  unset aliases_dir
  unset alias_filename
  unset alias_path
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
    source $HOME/.nrg_bash/ros.sh ${distro} ${ros_master_uri} ${ros1_workspaces}
  
  elif [ $ros_version -eq 2 ]; then
    # ROS2
    if [ -v ros_domain_id ]; then
      # Use normal ROS2 discovery using multicasting
      source $HOME/.nrg_bash/ros.sh ${distro} ${ros_domain_id} ${ros2_workspaces}
    else
      # Use discovery server with FastDDS
      source $HOME/.nrg_bash/ros.sh ${distro} ${ros_discovery_server} ${ros2_workspaces} --discovery_server
    fi
  
  else
    echo "Invalid ROS distribution '${ros_distro}' selected."
    return
  fi
  unset ros_version
done

unset distro

unset ros_distros
unset ros1_workspaces
unset ros2_workspaces
unset ros_master_uri
unset ros_domain_id
unset ros_discovery_server
unset platform_aliases
unset project_aliases
