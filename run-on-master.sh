#!/bin/bash

# 先 chmod -R 755 * 取得权限

source conf

while read line
do
	ip=`echo $line | awk '{print $1}'`
	hostname=`echo $line | awk '{print $2}'`
	echo "-------- configuring $hostname@$ip --------"

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
		source ~/.bashrc # 除在本机外无效
		# 用这种方式以便回答一次yes/no
		/usr/bin/expect <<- EOF
		set time -1
		spawn -noecho ssh $uname@$hostname
		expect {
			"(yes/no)" { send "yes\r"; exp_continue  }
			eof
		}
		EOF
		echo ''
	else # slave
		# 添加公钥到slave（slave不需要keygen）
		/usr/bin/expect <<- EOF
		set time -1
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
		set time -1
		spawn -noecho scp /home/$uname/.ssh/id_rsa.pub $uname@$hostname:~/.ssh/authorized_keys
		expect {
			"password:" { send "$passwd\r"; exp_continue }
			eof
		}
		EOF
		echo ''

		# 复制本机的id_rsa.pub到slave
		/usr/bin/expect <<- EOF
		set time -1
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

		# 复制安装和配置文件到slave（不含当前文件）
		# 复制根目录下文件
		for file in `ls | grep -v $(basename $0)`; do
			/usr/bin/expect <<- EOF
			set time -1
			spawn -noecho scp $file $uname@$hostname:
			expect {
				"password:" { send "$passwd\r"; exp_continue }
				eof
			}
			EOF
		done
		echo ''

		# 复制$prog_subdir文件夹
		/usr/bin/expect <<- EOF
		set time -1
		spawn -noecho scp -r $prog_subdir $uname@$hostname:
		expect {
			"password:" { send "$passwd\r"; exp_continue }
			eof
		}
		EOF

		ssh -t -t $uname@$hostname 'chmod -R 755 *; ./run-remain.sh'
		# 更新.bashrc
		/usr/bin/expect <<- EOF
		set time -1
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
