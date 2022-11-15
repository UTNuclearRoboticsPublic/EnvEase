#!/bin/bash

# create install location in /opt
DEST_DIR=/opt/nuclearrobotics
sudo mkdir -p $DEST_DIR

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

# install FastDDS discovery service
/bin/bash $SCRIPT_DIR/fastdds/install_fastdds_service.sh

# copy scripts to install location
sudo cp $SCRIPT_DIR/nrg.sh $DEST_DIR
sudo cp $SCRIPT_DIR/ros.sh $DEST_DIR
sudo cp $SCRIPT_DIR/functions.sh $DEST_DIR

# create config file in the home directory
cp $SCRIPT_DIR/config.sh.template $HOME/nrg_config.sh

# source our NRG config script in the bashrc
BASHRC=$HOME/.bashrc
if ! grep -q "source ${DEST_DIR}/nrg.sh" ${BASHRC}; then
    echo "source ${DEST_DIR}/nrg.sh" >> $BASHRC
fi

