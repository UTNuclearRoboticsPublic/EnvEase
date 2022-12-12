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

# remove FastDDS discovery service
SERVICENAME=fastdds_discovery_server
if [[ $(systemctl list-units --full -all | grep -Fq "$SERVICENAME.service") ]]; then
  if [[ $(systemctl is-active --quiet service) -eq 0 ]]; then
    systemctl stop $SERVICENAME.service
  fi
  systemctl disable $SERVICENAME.service
fi
if [[ -f /etc/systemd/system/$SERVICENAME.service ]]; then
  rm /etc/systemd/system/$SERVICENAME.service
fi
if [[ -f /usr/bin/$SERVICENAME.sh ]]; then
  rm /usr/bin/$SERVICENAME.sh
fi
systemctl daemon-reload

# remove scripts from install locations
rm -rf $OPT_DIR
rm -rf /etc/skel/.nrg_env
rm -rf /etc/skel/install_vscode_extensions.sh
rm -rf /etc/skel/README.md
rm -rf /etc/skel/.bashrc

if [[ -f /bin/nrgenv ]]; then
  rm /bin/nrgenv
fi

# remove NRG environment directory form user home
rm -rf $USER_HOME/.nrg_env

# remove the line from bashrc which sources our scripting
BASHRC=$USER_HOME/.bashrc
if grep -q "source ${OPT_DIR}/nrg.sh" ${BASHRC}; then
    sed -i '/nrg.sh/d' ${BASHRC}
fi
