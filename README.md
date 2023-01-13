# nrg_bash

This is a set of bash scripts for automating and managing the Linux environment setup for NRG members. It handles the setup of ROS1 and/or ROS2 environments, and downloads and sources bash alias files for your specific robot platforms and projects.

## Package Details
### Maintainer
Blake Anderson  
Nuclear and Applied Robotics Group  
The University of Texas at Austin

### GitHub
https://github.com/UTNuclearRobotics/nrg_bash

### Copyright

Copyright© The University of Texas at Austin, 2022. All rights reserved.
    
All files within this directory are subject to the following, unless an alternative
license is explicitly included within the text of each file.

    This software and documentation constitute an unpublished work
    and contain valuable trade secrets and proprietary information
    belonging to the University. None of the foregoing material may be
    copied or duplicated or disclosed without the express, written
    permission of the University. THE UNIVERSITY EXPRESSLY DISCLAIMS ANY
    AND ALL WARRANTIES CONCERNING THIS SOFTWARE AND DOCUMENTATION,
    INCLUDING ANY WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
    PARTICULAR PURPOSE, AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY
    THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF TRADE.
    NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO THE USE OF
    THE SOFTWARE OR DOCUMENTATION. Under no circumstances shall the
    University be liable for incidental, special, indirect, direct or
    consequential damages or loss of profits, interruption of business,
    or related expenses which may arise from use of software or documentation,
    including but not limited to those resulting from defects in software
    and/or documentation, or loss or inaccuracy of data of any kind.


## Installation and Uninstallation
Follow these steps to set up these automated features on your Ubuntu machine.

<ol>
  <li>Clone this repo to your home directory.</li>
  
      git clone git@github.com:UTNuclearRobotics/nrg_bash.git ~/nrg_bash
      
  <li>Open your bashrc script and remove any existing lines for ROS configuration.</li>
  
      gedit ~/.bashrc
      
  (Or whatever other text editor you prefer)
      
  <li>Run the install script. This will place bash scripts in the location /opt/nuclearrobotics, install the nrgenv program to /bin, and place a configuration directory .nrg_env in your home directory. After running the install script, you may delete the nrg_bash directory.</li>
  
      ~/nrg_bash/install.sh
      
  <li>To uninstall these features, run the uninstall script located in the nrg_bash directory.</li>
  
      ~/nrg_bash/uninstall.sh
      
</ol>

## NRG Environment Configuration With nrgenv

After installation, you will have access to the ```nrgenv``` program which enables you to create and manage environment profiles from the command line. These profiles allow you to switch between different work contexts (projects, platforms, or toolsets) without editing your bashrc script. An example workflow is given below.

<ol>
  <li>After installation, you will initially not have any stored environment configurations. Create one using the nrgenv tool. The new configuration file will be opened in your default text editor. Fill out the configuration per the comments in the file, then save and close.</li>
  
      nrgenv add first_config
      
  <li>Then set the newly created configuration as the active configuration.</li>
  
      nrgenv set first_config
      
  <li>After setting a new active configuration, you must source your bashrc script before it will take effect. Conveniently, the included NRG alias set provides a command for this.</li>
  
      source_bashrc
      
  <li>After sourcing the bashrc, you can check the active environment configuration.</li>
  
      nrgenv show
</ol>

The variables you set in the ```first_config``` configuration file should be reflected in your bash environment going forward. You may go on to create more configurations for different work contexts, and switch between them as needed using ```nrgenv```.

### nrgenv Help
You can view the full instruction set of ```nrgenv``` by running it with the help flag.

```
blake@blake-nrg-precision:~$ nrgenv -h
usage: nrgenv [-h] {add,modify,cp,rm,rename,set,clear,list,show,verbose} ...

Manages NRG environment configurations.

optional arguments:
  -h, --help            show this help message and exit

subcommands:
  {add,modify,cp,rm,rename,set,clear,list,show,verbose}
    add                 Create a new config
    modify              Modify an existing config
    cp                  Copy a config with a new name
    rm                  Remove a config
    rename              Rename a config
    set                 Set the active config
    clear               Delete all the stored configs
    list                List all the stored configs
    show                Show the active config
    verbose             Set the terminal verbosity.
```
```
blake@blake-nrg-precision:~$ nrgenv add -h
usage: nrgenv add [-h] target

positional arguments:
  target      The name of the new environment configuration.

optional arguments:
  -h, --help  show this help message and exit
```

### Terminal Verbosity

You can turn on verbose mode for your terminal environment using the nrgenv program

    nrgenv verbose on
    
Afterwards, new terminals will print out their configuration details. This may be a useful reminder of your current settings if you frequently change them.
```
Active environment configuration: lanl
Using ros1_bridge from noetic to galactic
Using ROS 1 distribution: noetic
  Workspaces: catkin_ws
  ros_master_uri: http://localhost:11311/
Using ROS 2 distribution: galactic
  Workspaces: lanl_ws
  ROS_DOMAIN_ID: 0
blake@blake-nrg-precision:~$ 
```

## Bash Alias Management
The script will source any alias files that you specify in the ```platform_aliases``` and ```project_aliases``` variables of the environment configuration. For example, setting

    platform_aliases=("spot" "walrus")  
    
will cause the script to download the files ```spot_aliases``` and ```walrus_aliases``` from GitHub, and source them. The script will always source the file ```nrg_common_aliases``` as well.

You are strongly encouraged to add and maintain alias files for your robot platforms and projects, to aid other NRG members in using your work. Do so by commiting to the [aliases repository](https://github.com/UTNuclearRobotics/nrg_bash_aliases).

You may also put personal aliases in ```~/.bash_aliases``` as usual. This should only be for aliases that are very specific to your own needs that other NRG members would not benefit from having access to.

## Implementation Details
The installation script places a set of bash script files in ```/opt/nuclearrobotics```. It also adds a line to the end of your ```~/.bashrc``` script, which is run whenever you open a new terminal.

    source /opt/nuclearrobotics/nrg.sh
    
This line leads into the scripting functions that process your environment configuration as set using the ```nrgenv``` program. Your configurations are stored in the directory ```~/.nrg_env```, along with the NRG bash alias files that have been downloaded for your configurations.
