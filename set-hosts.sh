#!/bin/bash

echo "=== running $(basename $0) ==="

cat hosts hosts-ext > hosts-all
sudo cp hosts-all /etc/hosts
rm hosts-all

#sudo cp hosts /etc/hosts
#sudo cat hosts-ext >> /etc/hosts
