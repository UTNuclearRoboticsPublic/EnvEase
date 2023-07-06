############################
### ROS1 User Parameters ###
############################
# Delete this whole section if this configuration does not use ROS1.

# Set the ROS1 distribution you wish to use.
# Use all lowercase (melodic, noetic, etc.)
ros1_distribution="noetic"

# List ROS1 workspaces in order, giving the paths to the roots of the workspaces.
# Paths can either be absolute (starting with /) or relative to the home directory.
# Later workspaces overlay earlier ones.
ros1_workspaces=("relative_path" "/absolute_path")

# Set this to the URI of the machine running roscore.
# ros_master_uri defaults to 'http://localhost:11311/' if not set.
ros_master_uri=http://localhost:11311/

# Set this to the network interface over which we will connect to the ROS master machine.
# Envease will determine you IP address for that interface as set ROS_IP to it.
# Use the CLI command 'ip address show' to see your interface names.
# network_interface defaults to the loopback interface 'lo' if not set.
network_interface=lo



############################
### ROS2 User Parameters ###
############################
# Delete this whole section if this configuration does not use ROS2.

# Set the ROS2 distribution you wish to use.
# Use all lowercase (galactic, humble, etc.)
ros2_distribution="humble"

# List ROS2 workspaces in order, giving the paths to the roots of the workspaces.
# Paths can either be absolute (starting with /) or relative to the home directory.
# Later workspaces overlay earlier ones.
ros2_workspaces=("relative_path" "/absolute_path")

# Allowed ranges are [0,101] and [215,232]
# Delete this out if you want to use FastDDS discovery servers (see below)
ros_domain_id=0

# List (semicolon-separated) the URIs of machine running FastDDS discovery server(s)
# This is ignored if ros_domain_id is defined above!
# https://fast-dds.docs.eprosima.com/en/latest/fastdds/ros2/discovery_server/ros2_discovery_server.html
ros_discovery_server="localhost:11311"



##########################
### Bash Alias Imports ###
##########################
# EnvEase allows you to download and source portable sets of Bash aliases.
# List the alias sets for this configuration these using the array variables below.

# Specific to certain development tools such as IDEs, build systems, container systems, etc.
tool_aliases=("catkin_tools" "colcon")
# Specific to certain hardware.
platform_aliases=()
# Specific to certain projects.
project_aliases=()

# The alias sets above will be downloaded from the GitHub repository specified using the following variables.
alias_repo_owner="The GitHub account or org that owns the alias repo."
alias_repo_name="The name of the alias repo."
repo_auth_token="Your GitHub access token, if needed to access a private repository."
