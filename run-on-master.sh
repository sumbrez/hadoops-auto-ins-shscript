#!/bin/bash

# 先 chmod -R 755 * 取得权限

while read line
do
	ip=`echo $line | awk '{print $1}'`
	hostname=`echo $line | awk '{print $2}'`
	echo "----- configuring $ip $hostname -----"

	if [ $hostname = `hostname` ]; then # 本机
		# 生成本机ssh key
		rm ~/.ssh/*
		ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
		cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys # 默认没有au_keys，cp和cat均可

		# 重启slave sshd服务
		echo "*** restarting $hostname sshd ***"
		sleep 1s
		sudo service ssh restart
		sudo service sshd restart

		./run-remain.sh
	else # slave
		# 添加公钥到slave（slave不需要keygen）
		ssh -o StrictHostKeyChecking=no hadoop@$ip 'if [ ! -x .ssh ]; then mkdir .ssh; fi'
		# 此处清空原au_keys
		#cat ~/.ssh/id_rsa.pub | ssh -t -t hadoop@$ip 'cat > ~/.ssh/authorized_keys'
		scp ~/.ssh/id_rsa.pub hadoop@$ip:~/.ssh/authorized_keys

		# 重启slave sshd服务
		echo "*** restarting $hostname sshd ***"
		sleep 1s
		ssh -t -t hadoop@$ip 'sudo service ssh restart; sudo service sshd restart'

		# 复制安装和配置文件到slave（不含当前文件）
		scp -r `ls | grep -v $(basename $0)` hadoop@$ip:
		#scp `ls | grep -v $(basename $0)` hadoop@$ip: # 用于“调试”，且存在prog子目录
		#scp -r `ls | grep -v $(basename $0) | grep -v tar.gz` hadoop@$ip: # 不存在prog子目录
		ssh -t -t hadoop@$ip 'chmod -R 755 *'
		ssh -t -t hadoop@$ip './run-remain.sh'
	fi
done < hosts
