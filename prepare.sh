#!/bin/bash

echo "=== running $(basename $0) ==="

# 备份原来的更新源
if [ ! -e "/etc/apt/sources.list.backup" ]; then
    sudo mv /etc/apt/sources.list /etc/apt/sources.list.backup
fi
# 修改更新源
sudo cat > /etc/apt/sources.list <<- EOF
# deb cdrom:[Ubuntu 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security multiverse
EOF
# 让更新源生效
sudo apt-get update

# 安装完整vim
sudo apt-get -y remove vim-common
sudo apt-get -y install vim

# 安装ssh-server
sudo apt-get -y install openssh-server

# 安装expect
sudo apt-get -y install expect

# sudo权限和NOPASSWD权限 # sudo adduser hadoop sudo
sed -i "s/hadoop.*ALL=(ALL:ALL).*ALL/hadoop\tALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers
sed -i "s/.*sudo.*ALL=(ALL:ALL).*ALL/sudo\tALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers # server版需要此操作
