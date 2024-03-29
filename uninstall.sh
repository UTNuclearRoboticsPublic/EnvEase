#!/bin/bash
############################################################################################
# Copyright : Copyright© The University of Texas at Austin, 2023. All rights reserved.
#                
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of python-odmltables nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
############################################################################################


if [ "$EUID" -eq 0 ]
  then echo "Do not run as root"
  exit
fi

OPT_DIR=/opt/EnvEase

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
sudo rm -rf /etc/skel/.envease
sudo rm -rf /etc/skel/install_vscode_extensions.sh
sudo rm -rf /etc/skel/README.md
sudo rm -rf /etc/skel/.bashrc

if [[ -f /bin/envease ]]; then
  sudo rm /bin/envease
fi

# remove envease config directory from user home
rm -rf $HOME/.envease

# remove the line from bashrc which sources our scripting
BASHRC=$HOME/.bashrc
if grep -q "source ${OPT_DIR}/envease.sh" ${BASHRC}; then
  sed -i '/envease.sh/d' ${BASHRC}
fi
