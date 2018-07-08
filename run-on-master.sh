#!/bin/bash

# 可以附加参数'nocover'指明不安装progs，但要求必须已安装过
# 此参数直接传给run-remain.sh来控制是否调用install-progs.sh

# 先 chmod -R 755 * 取得权限

ins_ornot=$1 # 值为nocover则不安装配置jdk等，涵盖不复制tar包到slave

source config

while read line
do
	ip=`echo $line | awk '{print $1}'`
	hostname=`echo $line | awk '{print $2}'`
	echo "-------- configuring $hostname@$ip --------"

	if [ "$hostname" = `hostname` ]; then # 本机
		# 生成本机ssh key
		rm ~/.ssh/*
		ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
		cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys # 默认没有au_keys，cp和cat均可

		# 重启slave sshd服务
		echo "*** restarting $hostname sshd ***"
		sleep 1s

		sudo service ssh restart
		sudo service sshd restart

		./run-remain.sh $ins_ornot
		source ~/.bashrc # 除在本机外无效
		# 用这种方式以便回答一次yes/no
		/usr/bin/expect <<- EOF
		set timeout 1
		spawn -noecho ssh $uname@$hostname
		expect {
			"(yes/no)" { send "yes\r"; exp_continue }
			":~$" { send "logout\r"; exp_continue }
			eof
		}
		EOF
		echo ''
	else # slave
		# 添加公钥到slave（slave不需要keygen）
		/usr/bin/expect <<- EOF
		set timeout -1
		spawn -noecho ssh $uname@$hostname {if [ ! -d .ssh ]; then mkdir .ssh; fi}
		expect {
			"(yes/no)" { send "yes\r"; exp_continue  }
			"password:" { send "$passwd\r"; exp_continue }
			eof
		}
		EOF
		echo ''

		# 此处清空原au_keys
		# cat ~/.ssh/id_rsa.pub | ssh -t -t $uname@$hostname 'cat > ~/.ssh/authorized_keys'
		/usr/bin/expect <<- EOF
		set timeout -1
		spawn -noecho sh -c {scp ~/.ssh/id_rsa.pub $uname@$hostname:~/.ssh/authorized_keys}
		expect {
			"password:" { send "$passwd\r"; exp_continue }
			eof
		}
		EOF
		echo ''

		# 复制本机的id_rsa.pub到slave
		/usr/bin/expect <<- EOF
		set timeout -1
		spawn -noecho ssh -t -t $uname@$hostname {sudo service ssh restart; sudo service sshd restart}
		expect {
			"password:" { send "$passwd\r"; exp_continue }
			eof
		}
		EOF
		echo ''
		# 重启slave sshd服务
		echo "*** restarting $hostname sshd ***"
		sleep 1s

		### 到此为止如果正确，接下来scp、ssh等时应当不再需要输入密码 ###

		# 复制安装和配置文件到slave（不含当前文件）
		# spawn -c依然不支持$(basename $0)
		/usr/bin/expect <<- EOF
		set timeout -1
		spawn -noecho sh -c {scp * $uname@$hostname:} # 不复制目录
		#spawn -noecho sh -c {scp -r * $uname@$hostname:} # 复制目录
		expect {
			"password:" { send "$passwd\r"; exp_continue }
			eof
		}
		EOF
		echo ''

		ssh -t -t $uname@$hostname 'chmod -R 755 *; ./run-remain.sh $ins_ornot'
		# ssh到slave上更新.bashrc
		/usr/bin/expect <<- EOF
		set timeout 1
		spawn -noecho ssh $uname@$hostname
		expect "password:" { send "$passwd\r" }
		expect ":~$"
		send "source ~/.bashrc\r"
		expect ":~$"
		send "logout\r"
		expect eof
		EOF
		echo ''
	fi
done < hosts
