# New NRG System Setup

This Ubuntu install features some custom configuration for work in the Nuclear and Applied Robotics Group at the University of Texas. This README gives an overview of this configuration and lists some steps to take following the installation of Ubuntu.

# Terminal Bash Scripting

Ubuntu uses a hidden script file `~/.bashrc` to execute a set of commands whenever a new terminal window is opened. In this distribution, the bashrc includes a call to custom scripts located in the `/opt/nuclearrobotics` directory. These scripts automate the setup of ROS 1 and/or ROS 2 features in your terminal, as well as bash alias management. The inputs to these scripts are set in the configuration file `~/nrg_config.sh`. See the comments in that file along with the ROS1 and/or ROS2 tutorial series for explainations of these config variables.

# Alias Management

The automated scripting will help you acquire the standard bash aliases used in NRG. Some of these aliases are common to all NRG members, but most are specific to a project, robot, or toolset. The scripts will download and then source any alias files that you specify in the ```platform_aliases```, ```project_aliases```, and ```tool_aliases``` variables of ```~/nrg_config.sh```. For example, setting

    platform_aliases=("spot" "walrus")  
    
will cause the script to search in the hidden ```~/.nrg_aliases``` folder for the files ```spot_aliases``` and ```walrus_aliases```, and source them. The script will also automatically source the file ```nrg_common_aliases```. If any of these files is not found, the script will attempt to download it from the NRG GitHub repository ```nrg_bash_aliases```.

You are free (and encouraged!) to add or append to alias files for your robot platforms and projects.
https://github.com/UTNuclearRobotics/nrg_bash_aliases

You may also put personal aliases in ```~/.bash_aliases``` as usual.

# Visual Studio Code Setup

Visual Studio Code is the most commonly used code editor in NRG, since it has plugin support for ROS. To install some useful plugins for it, you may run the bash script `install_vscode_extensions.sh` provided in your home directory. You may delete this script after running it.

# ROS 2 Discovery Servers

When running ROS 2 on the campus networks, we use [FastDDS discovery servers](https://fast-dds.docs.eprosima.com/en/latest/fastdds/ros2/ros2.html). Our standard bash aliases include commands to start, stop, or set auto-start for a server on your machine. See the [common aliases file](https://github.com/UTNuclearRobotics/nrg_bash_aliases/blob/master/nrg_common_aliases).