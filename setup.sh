#!/bin/bash

# create install location in /opt
OPT_DIR=/opt/nuclearrobotics
mkdir -p $OPT_DIR

# User home directory. This works even if the user runs the script as root
USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

# files in this directory will be placed in the home directory of any newly created users
SKEL_DIR=/etc/skel

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# install FastDDS discovery service
/bin/bash $SCRIPT_DIR/fastdds/install_fastdds_service.sh

# copy scripts to install locations
cp $SCRIPT_DIR/nrg.sh $OPT_DIR
cp $SCRIPT_DIR/ros.sh $OPT_DIR
cp $SCRIPT_DIR/functions.sh $OPT_DIR
cp $SCRIPT_DIR/github_downloader.sh $OPT_DIR
cp $SCRIPT_DIR/config_template.sh $OPT_DIR
cp -a $SCRIPT_DIR/skel/. $SKEL_DIR/
cp $SCRIPT_DIR/nrgenv /bin

# create config file in the home directory
mkdir -p $USER_HOME/nrg_env/configs
mkdir -p $USER_HOME/nrg_env/nrg_aliases

cp -a $SCRIPT_DIR/skel/.nrg_env $USER_HOME
chown -R $SUDO_USER $USER_HOME/.nrg_env

# source our NRG config script in the bashrc
BASHRC=$USER_HOME/.bashrc
if ! grep -q "source ${OPT_DIR}/nrg.sh" ${BASHRC}; then
    echo "source ${OPT_DIR}/nrg.sh" >> $BASHRC
fi
