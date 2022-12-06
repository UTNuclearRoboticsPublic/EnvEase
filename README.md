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
  <li>Clone this repo to some location. Your home directory is suitable.</li>
  
      git clone git@github.com:UTNuclearRobotics/nrg_bash.git
      
  <li>Run the install script. This will place bash scripts in the location /opt/nuclearrobotics, install the nrgenv program to /bin, and place a configuration directory .nrg_env in your home directory. After running the install script, you may delete the nrg_bash directory.</li>
  
      sudo ~/nrg_bash/install.sh
      
  <li>To uninstall these features, run the uninstall script located in the nrg_bash directory.</li>
  
      sudo ~/nrg_bash/uninstall.sh
      
</ol>

## NRG Environment Configuration

After installation, you will have access to the nrgenv program which enables you to create and manage environment profiles. These profiles allow you to switch between different work contexts (projects, platforms, or toolsets) without editing your bashrc script. An example workflow is given below.

<ol>
  <li>After installation, you will initially not have any environment profile .</li>
  
      git clone git@github.com:UTNuclearRobotics/nrg_bash.git
      
  <li>Run the install script. This will place bash scripts in the location /opt/nuclearrobotics, install the nrgenv program to /bin, and place a configuration directory .nrg_env in your home directory. After running the install script, you may delete the nrg_bash directory.</li>
      
</ol>

## Bash Alias Management
The script will source any alias files that you specify in the ```platform_aliases``` and ```project_aliases``` variables of ```nrg.sh```. For example, setting

    platform_aliases=("spot" "walrus")  
    
will cause the script to search in the ```~/.nrg_bash/aliases``` folder for the files ```spot_aliases``` and ```walrus_aliases```, and source them. The script will also automatically source the file ```nrg_common_aliases```. If any of these files is not found, the script will attempt to download it from the NRG GitHub repository ```nrg_bash_aliases```.

You are strongly encouraged to add and maintain the alias files for your robot platforms and projects, to aid other NRG members in using your work. Do so by commiting to the [aliases repository](https://github.com/UTNuclearRobotics/nrg_bash_aliases).

You may also put personal aliases in ```~/.bash_aliases``` as usual. This should only be for aliases that are very specific to your personal needs, or aliases for one-off purposes that other NRG members would not benefit from.
