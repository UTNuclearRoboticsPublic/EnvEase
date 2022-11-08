# nrg_bash

This is a set of bash scripts for automating the environment setup for NRG members. It handles setup of the ROS1 or ROS2 environments (or both). It also downloads and sources alias files for your specific robot platforms and projects.

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


## Setting Up
Follow these steps to set up these automated features on your Ubuntu machine.

<ol>
  <li>Clone this repo into a hidden folder in your home directory.</li>
  
      git clone git@github.com:UTNuclearRobotics/nrg_bash.git ~/.nrg_bash
      
  <li>Source the NRG script in your bashrc.</li>
  
      echo "source ~/.nrg_bash/nrg.sh" >> ~/.bashrc
      
  <li>Open the NRG script configuration file.</li>
  
      gedit ~/.nrg_bash/config.sh
      
  <li>Edit the configuration variables in the top part of the file. Save and close.</li>
</ol>

You are now ready. When you open a bash terminal in the future, these scripts should be run. You can verify this by running this command in terminal:  

    echo $ROS_DISTRO  
    
If that environment variable is not found, then the scripts did not run properly.

## Bash Aliases
The script will source any alias files that you specify in the ```platform_aliases``` and ```project_aliases``` variables of ```nrg.sh```. For example, setting

    platform_aliases=("spot" "walrus")  
    
will cause the script to search in the ```~/.nrg_bash/aliases``` folder for the files ```spot_aliases``` and ```walrus_aliases```, and source them. The script will also automatically source the file ```nrg_common_aliases```. If any of these files is not found, the script will attempt to download it from the NRG GitHub repository ```bash_aliases```.

You are free (and encouraged!) to add or append to alias files for your robot platforms and projects.
https://github.com/UTNuclearRobotics/bash_aliases

You may also put personal aliases in ```~/.bash_aliases``` as usual.
