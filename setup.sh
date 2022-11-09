#!/bin/bash

script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

cp $script_dir/config.sh.template $script_dir/config.sh
echo "source ~/.nrg_bash/nrg.sh" >> $HOME/.bashrc
