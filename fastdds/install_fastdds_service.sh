#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

sudo cp fastdds_discovery_server.service /etc/systemd/system
sudo cp fastdds_discovery_server.sh /usr/bin
