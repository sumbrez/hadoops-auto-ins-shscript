#!/bin/bash

echo "=== running $(basename $0) ==="

sudo chown hadoop:hadoop .viminfo

./set-hosts.sh
./install-progs.sh
./conf-progs.sh
./set-bash-envs.sh # source .bashrc无效，已无必要放在conf-progs.sh前

#sudopw/set-sudoers-NOPW.sh
#sudopw/set-sudoers-PW.sh
