#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# create install location in /opt
OPT_DIR=/opt/nuclearrobotics
mkdir -p $OPT_DIR

# User home directory. This works even if the user runs the script as root
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

# files in this directory will be placed in the home directory of any newly created users
SKEL_DIR=/etc/skel

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# install FastDDS discovery service
/bin/bash $script_dir/fastdds/install_fastdds_service.sh

# copy scripts to install locations
cp $script_dir/nrg.sh $OPT_DIR
cp $script_dir/ros.sh $OPT_DIR
cp $script_dir/functions.sh $OPT_DIR
cp $script_dir/github_downloader.sh $OPT_DIR
cp $script_dir/config_template.sh $OPT_DIR
cp -a $script_dir/skel/. $SKEL_DIR/
cp $script_dir/nrgenv /bin

# create NRG environment directory in the home directory
cp -r $script_dir/skel/.nrg_env $USER_HOME
chown -R $SUDO_USER $USER_HOME/.nrg_env

# source our NRG config script in the bashrc
BASHRC=$USER_HOME/.bashrc
if ! grep -q "source ${OPT_DIR}/nrg.sh" ${BASHRC}; then
    echo "source ${OPT_DIR}/nrg.sh" >> $BASHRC
fi
