#!/bin/bash

# 可以附加参数'nocmpl'指明不进行编译等工作，但要求必须已编译过

# 本脚本和set-lzo.sh和config、hosts同级，lzo和hadoop-lzo的tar包放在子文件夹lzo中，编译工作也在lzo中

# hbase lzo测试
# hbase org.apache.hadoop.hbase.util.CompressionTest hdfs://master:9000/test_path lzo

echo "=== running $(basename $0) ==="

cmpl_ornot=$1 # 值为nocmpl则不编译lzo、安装lzop等

source config

HADOOP_HOME=$libdir/hadoop/"`ls $libdir/hadoop`"
HBASE_HOME=$libdir/hbase/"`ls $libdir/hbase`"

cd lzo
if [[ $cmpl_ornot = nocmpl ]]; then
	lzo_file=`ls | grep lzo-2*.tar.gz` # lzo tar包
	lzo_dir=`ls | grep lzo-2 | grep -v tar.gz` # lzo解压后的路径
	hlzo_file=`ls | grep hadoop-lzo*.tar.gz` # hadoop lzo tar包
	hlzo_dir=`ls | grep hadoop-lzo | grep -v tar.gz` # hadoop lzo解压后的路径
	lzo_libdir=$libdir/$lzo_dir # 编译生成文件的路径，目前原样保留这些文件
else
	# 编译、安装lzo
	lzo_file=`ls | grep lzo-2*.tar.gz` # lzo tar包
	tar -zxf $lzo_file
	lzo_dir=`ls | grep lzo-2 | grep -v tar.gz` # lzo解压后的路径
	cd $lzo_dir
	lzo_libdir=$libdir/$lzo_dir # 编译生成文件的路径，目前原样保留这些文件
	./configure --enable-shared --prefix $lzo_libdir
	make
	sudo make install
	cd ..

	sudo cp $lzo_libdir/lib/liblzo* /usr/lib

	# 编译、安装hadoop-lzo
	sudo apt-get update
	sudo apt-get -y install lzop
	sudo apt-get -y install maven # lzo-2.10使用maven而不是ant

	hlzo_file=`ls | grep hadoop-lzo*.tar.gz` # hadoop lzo tar包
	tar -zxf $hlzo_file
	hlzo_dir=`ls | grep hadoop-lzo | grep -v tar.gz` # hadoop lzo解压后的路径
	cd $hlzo_dir

	C_INCLUDE_PATH=$lzo_libdir/include
	LIBRARY_PATH=$lzo_libdir/lib
	mvn clean package # 编译hadoop lzo到当前目录

	unset C_INCLUDE_PATH
	unset LIBRARY_PATH
	cd ..
fi

# 复制文件到hadoop相关目录
cp $hlzo_dir/target/hadoop-lzo*.jar $HADOOP_HOME/share/hadoop/common/lib # 没有验证是否需要此操作
cp $hlzo_dir/target/native/Linux-amd64-64/lib/* $HADOOP_HOME/lib/native
chmod -R 755 $HADOOP_HOME

# 复制文件到hbase相关目录
cp $hlzo_dir/target/hadoop-lzo*.jar $HBASE_HOME/lib # 根据复制phoenix-*-server.jar推断出需要此操作
sudo chmod -R 755 $HBASE_HOME

# 已验证hbase不需要native
<<comment
mkdir -p $HBASE_HOME/lib/native
cp $hlzo_dir/target/native/Linux-amd64-64/lib/* $HBASE_HOME/lib/native
# 额外配置hbase # /usr/lib
echo 'export HBASE_LIBRARY_PATH=$HBASE_LIBRARY_PATH:$HBASE_HOME/lib/native:$hlzo_dir/lib' >> $HBASE_HOME/conf/hbase-env.sh
comment

while read line
do
	ip=`echo $line | awk '{print $1}'`
	hostname=`echo $line | awk '{print $2}'`
	echo "-------- configuring lzos on $hostname@$ip --------"

	if [ "$hostname" = `hostname` ]; then # 本机
		cd ..
		./set-lzo.sh
		cd lzo
	else # slave
		ssh -t -t $uname@$hostname 'mkdir -p ~/lzo/lzo_lib'
		# 先将本机编译出的lzo lib文件复制到slave
		scp $lzo_libdir/lib/liblzo* $uname@$hostname:~/lzo/lzo_lib
		# 在slave上复制lib文件到系统目录
		ssh -t -t $uname@$hostname 'sudo cp ~/lzo/lzo_lib/liblzo* /usr/lib'

		# apt安装lzop
		#ssh -t -t $uname@$hostname 'sudo apt-get update; sudo apt-get -y install lzop'

		ssh -t -t $uname@$hostname 'mkdir -p ~/lzo/hlzo_target'
		# 将本机编译出的hadoop lzo的文件复制到slave
		scp $hlzo_dir/target/hadoop-lzo*.jar $uname@$hostname:~/lzo/hlzo_target
		# ssh -t -t $uname@$hostname 'sudo cp ~/lzo/hlzo_target/hadoop-lzo*.jar $HADOOP_HOME/share/hadoop/common/lib'

		scp -r $hlzo_dir/target/native/Linux-amd64-64/lib $uname@$hostname:~/lzo/hlzo_target
		# ssh -t -t $uname@$hostname 'sudo cp ~/lzo/hlzo_target/lib/* $HADOOP_HOME/lib/native'

		# 上边两条ssh 'cp'用到环境变量，但ssh 'cp'中无法使用环境变量，所以ssh到slave上执行
		# 第二条cp多个文件，多给1s
		/usr/bin/expect <<- EOF
		set timeout 2
		spawn -noecho ssh $uname@$hostname
		expect "password:" { send "$passwd\r" }
		expect ":~$"
		send "sudo cp ~/lzo/hlzo_target/hadoop-lzo*.jar $HADOOP_HOME/share/hadoop/common/lib\r"
		expect ":~$"
		send "sudo cp ~/lzo/hlzo_target/lib/* $HADOOP_HOME/lib/native\r"
		expect ":~$"
		send "logout\r"
		expect eof
		EOF
		echo ''

		scp set-lzo.sh $uname@$hostname:
		ssh -t -t $uname@$hostname 'chmod 755 ~/set-lzo.sh; ~/set-lzo.sh'
	fi
done < ../hosts

unset HADOOP_HOME
unset HBASE_HOME
