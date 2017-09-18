#!/bin/bash

echo "=== running $(basename $0) ==="

sudo chown hadoop:hadoop .viminfo

./set-hosts.sh
./install-prog.sh
./conf-prog.sh
./set-bash-envs.sh # source .bashrc无效，已无必要放在conf-prog.sh前

#sudopw/set-sudoers-NOPW.sh
#sudopw/set-sudoers-PW.sh
