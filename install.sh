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

cd "$(dirname "${BASH_SOURCE[0]}")"

# install FastDDS discovery service
/bin/bash fastdds/install_fastdds_service.sh

# copy bash scripts to install locations
cp nrg.sh $OPT_DIR
cp ros.sh $OPT_DIR
cp functions.sh $OPT_DIR
cp github_downloader.sh $OPT_DIR
cp config_template.sh $OPT_DIR
cp -a skel/. $SKEL_DIR/

# install nrgenv program
/bin/bash nrgenv/install.sh

# create NRG environment directory in the home directory
cp -r skel/.nrg_env $USER_HOME
chown -R $SUDO_USER $USER_HOME/.nrg_env

# source our NRG config script in the bashrc
BASHRC=$USER_HOME/.bashrc
if ! grep -q "source ${OPT_DIR}/nrg.sh" ${BASHRC}; then
    echo "source ${OPT_DIR}/nrg.sh" >> $BASHRC
fi
