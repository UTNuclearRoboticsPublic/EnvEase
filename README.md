# nrg_bash

This is a set of bash scripts for automating the environment setup for NRG members. It handles setup of the ROS1 or ROS2 environments (or both). It also downloads and sources alias files for your specific robot platforms and projects.

## Package Details
### Maintainer
Blake Anderson  
Nuclear and Applied Robotics Group  
The University of Texas at Austin

### GitHub
https://github.com/UTNuclearRobotics/nrg_bash


## Setting Up
Follow these steps to set up these automated features on your Ubuntu machine.

<ol>
  <li>Clone this repo into a hidden folder in your home directory.</li>
  
      git clone git@github.com:UTNuclearRobotics/nrg_bash.git ~/.nrg_bash
      
  <li>Source the NRG script in your bashrc.</li>
  
      echo "source ~/.nrg_bash/nrg.sh" >> ~/.bashrc
      
  <li>Open the NRG script file.</li>
  
      gedit ~/.nrg_bash/nrg.sh
      
  <li>Edit the configuration variables in the top part of the file. Save and close.</li>
</ol>

You are now ready. When you open a bash terminal in the future, these scripts should be run. You can verify this by running this command in terminal:  

    echo $ROS_DISTRO  
    
If that environment variable is not found, then the scripts did not run properly.

## Bash Aliases
The script will source any alias files that you specify in the platform_aliases and project_aliases variables of nrg.sh. For example, setting

    platform_aliases=("spot" "walrus")  
    
will cause the script to search in the ```~/.nrg_bash/aliases``` folder for the files ```spot_aliases``` and ```walrus_aliases```, and source them. The script will also automatically source the file ```nrg_common_aliases```. If any of these files is not found, the script will attempt to download it from the NRG GitHub repository ```bash_aliases```.

You are free (and encouraged!) to add or append to alias files for your robot platforms and projects.
https://github.com/UTNuclearRobotics/bash_aliases

You may also put personal aliases in ```~/.bash_aliases``` as usual.
