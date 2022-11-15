#!/bin/bash

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

sudo cp $SCRIPT_DIR/fastdds_discovery_server.service /etc/systemd/system
sudo cp $SCRIPT_DIR/launch_fastdds_discovery_server.sh /usr/bin
