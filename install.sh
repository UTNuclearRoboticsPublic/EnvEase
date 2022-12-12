#!/bin/bash

if [ "$EUID" -eq 0 ]
  then echo "Do not run as root"
  exit
fi

# create install location in /opt
OPT_DIR=/opt/nuclearrobotics
sudo mkdir -p $OPT_DIR

# files in this directory will be placed in the home directory of any newly created users
SKEL_DIR=/etc/skel

cd "$(dirname "${BASH_SOURCE[0]}")"

# install FastDDS discovery service
/bin/bash fastdds/install_fastdds_service.sh

# copy bash scripts to install locations
sudo cp nrg.sh $OPT_DIR
sudo cp ros.sh $OPT_DIR
sudo cp functions.sh $OPT_DIR
sudo cp github_downloader.sh $OPT_DIR
sudo cp config_template.sh $OPT_DIR
sudo cp -a skel/. $SKEL_DIR/

# install nrgenv program
/bin/bash nrgenv/install.sh

# create NRG environment directory in the home directory
cp -r skel/.nrg_env $HOME
if [[ ! -d "$HOME/.nrg_env/configs" ]]; then
  mkdir $HOME/.nrg_env/configs
fi

# source our NRG config script in the bashrc
BASHRC=$HOME/.bashrc
if ! grep -q "source ${OPT_DIR}/nrg.sh" ${BASHRC}; then
    echo "source ${OPT_DIR}/nrg.sh" >> $BASHRC
fi
