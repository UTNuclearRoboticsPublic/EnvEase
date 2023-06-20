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

####################
### DO NOT TOUCH ###
####################

# Directory of this script (normally /opt/EnvEase)
script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# Various functions
source $script_dir/functions.sh

# Look up our currently active EnvEase environment
source $HOME/.envease/cur_env.sh

if [ -z $ENVEASE_ENV ]; then
  echo "Error: Variable ENVEASE_ENV not found in $HOME/.envease/cur_env.sh. The file is deformed."
  return
fi

if [ -z $ENVEASE_VERBOSE ]; then
  echo "Error: Variable ENVEASE_VERBOSE not found in $HOME/.envease/cur_env.sh. The file is deformed."
  return
fi

export ENVEASE_ENV
export ENVEASE_VERBOSE

if [ "$ENVEASE_VERBOSE" == true ]; then
  echo "Active environment configuration: $ENVEASE_ENV"
fi

# Enables tab completion in bash for our envease script
eval "$(register-python-argcomplete3 envease)"

# Source the active NRG environment config
if [ $ENVEASE_ENV == none ]; then
  echo "No NRG configuration set. Use the envease command to set one."
  return
fi
source $HOME/.envease/configs/$ENVEASE_ENV.sh

if [ -z $alias_repo_owner ] || [ -z $alias_repo_name ]; then
  alias_repo_owner=""
  alias_repo_name=""
  repo_auth_token=""
fi

# Get our common aliases
handle_alias_file "" "common" $alias_repo_owner $alias_repo_name $repo_auth_token

for k in "${platform_aliases[@]}"; do
  handle_alias_file "platform" $k $alias_repo_owner $alias_repo_name $repo_auth_token
done

for k in "${project_aliases[@]}"; do
  handle_alias_file "project" $k $alias_repo_owner $alias_repo_name $repo_auth_token
done

for k in "${tool_aliases[@]}"; do
  handle_alias_file "tool" $k $alias_repo_owner $alias_repo_name $repo_auth_token
done
unset k


# If we have specified both ROS1 and ROS2 distributions,
# then set the extra environment variables needed by ros1_bridge
if [ ! -z $ros1_distribution ] && [ ! -z $ros2_distribution ]; then
  export ROS1_INSTALL_PATH=/opt/ros/${ros1_distribution}/setup.bash
  export ROS2_INSTALL_PATH=/opt/ros/${ros2_distribution}/setup.bash

  if [ "$ENVEASE_VERBOSE" == true ]; then
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
unset ROS_PACKAGE_PATH

# ROS1
if [ ! -z $ros1_distribution ]; then
  if [ -z $ros_master_uri ]; then
    echo "Error: ros_master_uri must be provided for a ROS 1 distribution."
  elif [ -z $network_interface ]; then
    echo "Error: network_interface must be provided for a ROS 1 distribution."
  else
    if [ "$ENVEASE_VERBOSE" == true ]; then
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
  if [ "$ENVEASE_VERBOSE" == true ]; then
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

    if [ "$ENVEASE_VERBOSE" == true ]; then
      echo "  ROS_DOMAIN_ID: $ros_domain_id"
    fi
  elif [ ! -z $ros_discovery_server ]; then
    # Use discovery server with FastDDS
    source $script_dir/ros.sh $ros2_distribution $ros_discovery_server "" $ros2_workspaces --discovery_server

    if [ "$ENVEASE_VERBOSE" == true ]; then
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
unset alias_repo_owner
unset alias_repo_name
unset repo_auth_token