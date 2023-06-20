# EnvEase

**EnvEase is currently a work in progress and may change without notice.**

Environment Ease (EnvEase) is a set of automations for managing the Linux shell environment for ROS software development. Users can fluidly create and switch between environmental profiles for different development projects, largely eliminating the need for manual configuration of the bashrc file. It is compatible with both ROS1 and ROS2 environments, including mixed environments using `ros1_bridge`. The automation can also download and source bash alias files from GitHub for your specific robot platforms and projects.

## Package Details
### Maintainer
Blake Anderson  
blakeanderson@utexas.edu  
Nuclear and Applied Robotics Group  
The University of Texas at Austin

### GitHub
https://github.com/UTNuclearRoboticsPublic/EnvEase

### Copyright & BSD-3 License

Copyright© The University of Texas at Austin, 2023. All rights reserved.
    
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


## Installation and Uninstallation
Follow these steps to set up these automated features on your Ubuntu machine.

<ol>
  <li>Clone this repo to your home directory.</li>
  
      git clone git@github.com:UTNuclearRobotics/EnvEase.git ~/EnvEase
      
  <li>Open your bashrc script and remove any existing lines for ROS configuration.</li>
  
      gedit ~/.bashrc
      
  (Or whatever other text editor you prefer)
      
  <li>Run the install script. This will place bash scripts in the location /opt/EnvEase, install the envease program to /bin, and place a configuration directory .envease in your home directory. After running the install script, you may delete the cloned EnvEase directory.</li>
  
      ~/EnvEase/install.sh
      
  <li>To uninstall these features, run the uninstall script located in the EnvEase directory.</li>
  
      ~/EnvEase/uninstall.sh
      
</ol>

## Environment Configuration With EnvEase command-line tool

After installation, you will have access to the ```envease``` program which enables you to create and manage environment profiles from the command line. These profiles allow you to switch between different work contexts (projects, platforms, or toolsets) without editing your bashrc script. An example workflow is given below.

<ol>
  <li>After installation, you will initially not have any stored environment configurations. Create one using the envease tool. The new configuration file will be opened in your default text editor. Fill out the configuration per the comments in the file, then save and close.</li>
  
      envease add first_config
      
  <li>Then set the newly created configuration as the active configuration.</li>
  
      envease set first_config
      
  <li>After setting a new active configuration, you must source your bashrc script before it will take effect.</li>
  
      source ~/.bashrc
      
  <li>After sourcing the bashrc file, you can check the active environment configuration.</li>
  
      envease show
</ol>

The variables you set in the ```first_config``` configuration file should be reflected in your bash environment going forward. You may go on to create more configurations for different work contexts, and switch between them as needed using ```envease```.

### envease Help
You can view the full instruction set of ```envease``` by running it with the help flag.

```
$ envease -h
usage: envease [-h] {add,modify,cp,rm,rename,set,clear,list,show,verbose} ...

Manages environment configurations for ROS software development.

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
$ envease add -h
usage: envease add [-h] target

positional arguments:
  target      The name of the new environment configuration.

optional arguments:
  -h, --help  show this help message and exit
```

### Terminal Verbosity

You can turn on verbose mode for your terminal environment using the envease program

    envease verbose on
    
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
blake@blake-workstation:~$ 
```

## Bash Alias Management
The script will source any alias files that you specify in the ```platform_aliases``` and ```project_aliases``` variables of the environment configuration. For example, setting

    platform_aliases=("spot" "walrus")  
    
will cause the script to download the files ```spot_aliases``` and ```walrus_aliases``` from GitHub, and source them. The GitHub repository is specified using the ```alias_repo_owner``` and ```alias_repo_name``` variables of the environment configuration. The script will always source the file ```common_aliases``` as well.

You may also put personal aliases in ```~/.bash_aliases``` as usual. This should only be for aliases that are very specific to your own needs that your colleagues would not benefit from having access to.

## Implementation Details
The installation script places a set of bash script files in ```/opt/EnvEase```. It also adds a line to the end of your ```~/.bashrc``` script, which is run whenever you open a new terminal.

    source /opt/EnvEase/envease.sh
    
This line leads into the scripting functions that process your environment configuration as set using the ```envease``` program. Your configurations are stored in the directory ```~/.envease```, along with the bash alias files that have been downloaded for your configurations.
