#!/bin/bash

# 安装ssh-server，ssh-server安装手动执行才能scp其他文件
# sudo apt-get -y install openssh-server

echo "=== running $(basename $0) ==="

source config

# 备份原来的更新源
if [ ! -e "/etc/apt/sources.list.backup" ]; then
    sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup
fi
# 修改更新源
sudo cat > /etc/apt/sources.list <<- EOF
# deb cdrom:[Ubuntu 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
# deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
EOF
# 让更新源生效
sudo apt-get update

# 安装完整vim
sudo apt-get -y remove vim-common
sudo apt-get -y install vim

# 安装expect
sudo apt-get -y install expect

# sudo权限和NOPASSWD权限 # sudo adduser $uname sudo
sudo cp /etc/sudoers /etc/sudoers.backup
sudo cp /etc/sudoers sudoers.tmp
# sudo sed -i "s/${uname}.*ALL=(ALL:ALL).*ALL/${uname}\tALL=(ALL:ALL) NOPASSWD:ALL/" sudoers.tmp
sudo sed -i "/${uname}/d" sudoers.tmp
sudo echo -e "${uname}\tALL=(ALL:ALL) NOPASSWD:ALL" >> sudoers.tmp
sudo sed -i "s/.*sudo.*ALL=(ALL:ALL).*ALL/sudo\tALL=(ALL:ALL) NOPASSWD:ALL/" sudoers.tmp # server版需要此操作
sudo cp sudoers.tmp /etc/sudoers
sudo rm sudoers.tmp
