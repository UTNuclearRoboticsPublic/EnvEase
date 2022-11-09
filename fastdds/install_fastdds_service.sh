#!/bin/bash
script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

sudo cp $script_dir/fastdds_discovery_server.service /etc/systemd/system
sudo cp $script_dir/launch_fastdds_discovery_server.sh /usr/bin
