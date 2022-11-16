#!/bin/bash

# create install location in /opt
OPT_DIR=/opt/nuclearrobotics
mkdir -p $OPT_DIR

# files in this directory will be placed in the home directory of any newly created users
SKEL_DIR=/etc/skel

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# install FastDDS discovery service
/bin/bash $SCRIPT_DIR/fastdds/install_fastdds_service.sh

# copy scripts to install location
cp $SCRIPT_DIR/nrg.sh $OPT_DIR
cp $SCRIPT_DIR/ros.sh $OPT_DIR
cp $SCRIPT_DIR/functions.sh $OPT_DIR
cp $SCRIPT_DIR/github_downloader.sh $OPT_DIR
cp -a $SCRIPT_DIR/skel/. $SKEL_DIR/

# create config file in the home directory
cp $SCRIPT_DIR/skel/nrg_config.sh $HOME

# source our NRG config script in the bashrc
BASHRC=$HOME/.bashrc
if ! grep -q "source ${DEST_DIR}/nrg.sh" ${BASHRC}; then
    echo "source ${DEST_DIR}/nrg.sh" >> $BASHRC
fi

