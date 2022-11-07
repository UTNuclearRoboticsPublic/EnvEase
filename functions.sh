# Determine which ROS version a ROS distribution belongs to
function get_ros_version_for_distribution()
{
  local ros1_distros=("diamondback" "electric" "fuerte" "groovy" "hydro" "indigo" "kinetic" "jade" "lunar" "melodic" "noetic")
  local ros2_distros=("rolling" "ardent" "bouncy" "crystal" "dashing" "eloquent" "foxy" "galactic" "humble")
  
  local distribution=$1

  if [[ " ${ros1_distros[*]} " =~ " $distribution " ]]; then
    echo "1"
  elif [[ " ${ros2_distros[*]} " =~ " $distribution " ]]; then
    echo "2"
  else
    echo "0"
  fi
}
