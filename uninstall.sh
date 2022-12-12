#!/bin/bash

if [ "$EUID" -eq 0 ]
  then echo "Do not run as root"
  exit
fi

OPT_DIR=/opt/nuclearrobotics

# files in this directory will be placed in the home directory of any newly created users
SKEL_DIR=/etc/skel

# remove FastDDS discovery service
SERVICENAME=fastdds_discovery_server
if [[ $(systemctl list-units --full -all | grep -Fq "$SERVICENAME.service") ]]; then
  if [[ $(systemctl is-active --quiet service) -eq 0 ]]; then
    sudo systemctl stop $SERVICENAME.service
  fi
  sudo systemctl disable $SERVICENAME.service
fi
if [[ -f /etc/systemd/system/$SERVICENAME.service ]]; then
  sudo rm /etc/systemd/system/$SERVICENAME.service
fi
if [[ -f /usr/bin/$SERVICENAME.sh ]]; then
  sudo rm /usr/bin/$SERVICENAME.sh
fi
sudo systemctl daemon-reload

# remove scripts from install locations
sudo rm -rf $OPT_DIR
sudo rm -rf /etc/skel/.nrg_env
sudo rm -rf /etc/skel/install_vscode_extensions.sh
sudo rm -rf /etc/skel/README.md
sudo rm -rf /etc/skel/.bashrc

if [[ -f /bin/nrgenv ]]; then
  sudo rm /bin/nrgenv
fi

# remove NRG environment directory form user home
rm -rf $HOME/.nrg_env

# remove the line from bashrc which sources our scripting
BASHRC=$HOME/.bashrc
if grep -q "source ${OPT_DIR}/nrg.sh" ${BASHRC}; then
  sed -i '/nrg.sh/d' ${BASHRC}
fi
