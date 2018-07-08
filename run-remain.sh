#!/bin/bash

# 从run-on-master.sh获得参数'nocover'（如果有）指明不安装progs，但要求必须已安装过
# 此参数控制是否调用install-progs.sh

echo "=== running $(basename $0) ==="

source config

ins_ornot=$1 # 值为nocover则不安装配置jdk等，涵盖不复制tar包到slave

./set-hosts.sh
# if [[ $ins_ornot != nocover ]]; then
# 	./install-progs.sh
# fi
./install-progs.sh $ins_ornot
./set-progs.sh
./set-bash-envs.sh # source ~/.bashrc无效，已无必要放在conf-progs.sh前

# sudopw/set-sudoers-NOPW.sh
# sudopw/set-sudoers-PW.sh

# 避免和~/.bashrc变量混淆、冲突
unset JAVA_HOME
unset HADOOP_HOME
unset HBASE_HOME
unset PHOENIX_HOME
