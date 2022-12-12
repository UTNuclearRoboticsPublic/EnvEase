#!/bin/bash

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

cp $script_dir/fastdds_discovery_server.service /etc/systemd/system
cp $script_dir/fastdds_discovery_server.sh /usr/bin
