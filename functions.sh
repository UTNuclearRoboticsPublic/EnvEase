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

# Determine which ROS version a ROS distribution belongs to
function get_ros_version_for_distribution()
{
  local ros1_distributions=("diamondback" "electric" "fuerte" "groovy" "hydro" "indigo" "kinetic" "jade" "lunar" "melodic" "noetic")
  local ros2_distributions=("rolling" "ardent" "bouncy" "crystal" "dashing" "eloquent" "foxy" "galactic" "humble")
  
  local distribution=$1

  if [[ " ${ros1_distributions[*]} " =~ " $distribution " ]]; then
    echo "1"
  elif [[ " ${ros2_distributions[*]} " =~ " $distribution " ]]; then
    echo "2"
  else
    echo "0"
  fi
}

function get_ip_address()
{
  # Gets the IP address of a given interface name
  ip_addr=$(ip -4 addr show $1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
}

function handle_alias_file()
{
  # Args:
  #   1. The class of the alias file. "platform", "tool", "project", or empty string
  #   2. The name of the alias set.
  #   3. The owner of the GitHub aliases repository
  #   4. The name of the aliases repository.
  #   5. The GitHub authorization token.
  
  script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

  local alias_class=$1
  local aliases_dir=$HOME/.envease/bash_aliases/$alias_class
  local alias_filename=$2_aliases
  local alias_path=$aliases_dir/$alias_filename

  local owner=$3
  local repo=$4
  local token=$5
  
  # Create the subdirectory if it doesn't exist
  if [ ! -d "$aliases_dir" ]; then
    mkdir -p $aliases_dir
  fi
  
  # If we don't have the file, try to download it from GitHub
  if [ ! -f "$alias_path" ]; then
    if [ -z $owner ] || [ -z $repo ]; then
      echo "GitHub repository information was not provided. Cannot pull alias file for argument $2."
      return
    fi

    echo "Downloading alias file $alias_filename to $aliases_dir"

    local url="https://api.github.com/repos/$owner/$repo/contents/$alias_class/$alias_filename?ref=master"
    if [ -n "$token" ]; then
      local result=$(curl \
      --fail \
      -H "Accept: application/vnd.github.v3.raw" \
      -H "Authorization: Bearer $5"\
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -L \
      -s -S \
      -o $alias_path \
      $url)
    else
      local result=$(curl \
      --fail \
      -H "Accept: application/vnd.github.v3.raw" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -L \
      -s -S \
      -o $alias_path \
      $url)
    fi

    if [ -n "$result" ]; then
      echo "Failed to download alias file!"
      return
    fi
  fi

  source $alias_path
}
