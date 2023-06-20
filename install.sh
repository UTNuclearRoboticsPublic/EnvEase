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

# create install location in /opt
OPT_DIR=/opt/envease
sudo mkdir -p $OPT_DIR

cd "$(dirname "${BASH_SOURCE[0]}")"

# install FastDDS discovery service
/bin/bash fastdds/install_fastdds_service.sh

# copy bash scripts to install locations
sudo cp envease.sh $OPT_DIR
sudo cp ros.sh $OPT_DIR
sudo cp functions.sh $OPT_DIR
sudo cp config_template.sh $OPT_DIR

# install envease command line protoolgram
/bin/bash tool/install.sh

# create envease config directory in the home directory
cp -r skel/.envease $HOME
if [[ ! -d "$HOME/.envease/configs" ]]; then
  mkdir $HOME/.envease/configs
fi

# source our config script in the bashrc
BASHRC=$HOME/.bashrc
if ! grep -q "source ${OPT_DIR}/envease.sh" ${BASHRC}; then
    echo "source ${OPT_DIR}/envease.sh" >> $BASHRC
fi

# Enables tab completion in bash for envease tool
eval "$(register-python-argcomplete3 envease)"