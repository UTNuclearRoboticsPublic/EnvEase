### ROS User Parameters ###
## Common ROS Variables

# You may combine a ROS1 distribution with a ROS2 distribution.
# In that case, environment variables will be set to enable ros1_bridge
ros1_distribution="noetic"
ros2_distribution="galactic"

# List ROS workspaces in order. Later workspaces overlay earlier ones.
ros1_workspaces=("a_ros1_ws" "another_ros1_ws")
ros2_workspaces=("a_ros2_ws")

## ROS1 Specific Variables
ros_master_uri=http://localhost:11311/

# Set this to the network interface over which we will connect to roscore
# Set lo if roscore will be on localhost
# Use the command 'ip address show' to see your interface names
network_interface=lo

## ROS2 Specific Variables
# Allowed ranges are [0,101] and [215,232]
# Comment this out if you want to use FastDDS discovery servers
ros_domain_id=0

# This will be used to connect to FastDDS discovery server(s)
# This should be the IP or hostname of the machine(s) running the discovery server(s)
# Generally, discovery servers function similarly to ROS1's master URI
# Separate machine names with semicolons
# This is ignored if ros_domain_id is defined above!
ros_discovery_server="localhost:11311"



### List project, platform, or tool specific alias sets needed for your work ###
# These can be downloaded from a GitHub repository
alias_repo_owner=""
alias_repo_name=""
repo_auth_token="your GitHub token, if needed to access a private repository"

tool_aliases=("catkin_tools" "colcon")
platform_aliases=()
project_aliases=()
