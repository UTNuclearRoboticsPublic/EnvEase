### ROS User Parameters ###
## Common ROS Variables
ros_distros=("galactic" "noetic")

# List ROS workspaces in order. Later workspaces override earlier ones
ros1_workspaces=("a_ros1_ws" "another_ros1_ws")
ros2_workspaces=("a_ros2_ws")

## ROS1 Specific Variables
ros_master_uri=http://localhost:11311/

# Use the command 'ip address show' to see your interface names
network_interface=wlo1

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
# https://github.com/UTNuclearRobotics/nrg_bash_aliases
tool_aliases=("catkin_tools" "colcon")
platform_aliases=()
project_aliases=()
