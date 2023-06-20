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
  local aliases_dir=$HOME/.nrg_env/bash_aliases/$alias_class
  local alias_filename=$2_aliases
  local alias_path=$aliases_dir/$alias_filename

  local owner=$3
  local repo=$4
  local token=$5
  
  # Create the subdirectory if it doesn't exist
  if [ ! -d "$aliases_dir" ]; then
    mkdir -p $aliases_dir
  fi
  
  # If we don't have the file, try to download it from the NRG GitHub
  if [ ! -f "$alias_path" ]; then
    if [ -n "$owner" ] || [ -n "$repo" ]; then
      echo "GitHub repository information was not provided. Cannot pull alias file for argument $2."
      return
    fi

    echo "Downloading alias file $alias_filename to $aliases_dir"

    if [-n $token ]; then
      curl \
      -H "Accept: application/vnd.github.v3.raw" \
      -H "Authorization: Bearer $5"\
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -L \
      -s \
      -o $alias_path \
      https://api.github.com/repos/$owner/$repo/contents/$alias_class/$alias_filename?ref=master
    else
      curl \
      -H "Accept: application/vnd.github.v3.raw" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -L \
      -s \
      -o $alias_path \
      https://api.github.com/repos/$owner/$repo/contents/$alias_class/$alias_filename?ref=master
    fi
  fi

  source $alias_path
}
