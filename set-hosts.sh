#!/bin/bash

echo "=== running $(basename $0) ==="

# 备份原来的hosts
if [ ! -e "/etc/hosts.backup" ]; then
    sudo cp /etc/hosts /etc/hosts.backup
fi

hname=`hostname`
sudo cat hosts hosts-ext > hosts-all
sudo echo "127.0.0.1 $hname" >> hosts-all
sudo cp hosts-all /etc/hosts
rm hosts-all

#sudo cp hosts /etc/hosts
#sudo cat hosts-ext >> /etc/hosts
