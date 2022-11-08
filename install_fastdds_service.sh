#!/bin/bash
sudo cp $HOME/.nrg_bash/fastdds_discovery_server.service /etc/systemd/system
sudo cp $HOME/.nrg_bash/launch_fastdds_discovery_server.sh /usr/bin
sudo systemctl enable --now fastdds_discovery_server.service
