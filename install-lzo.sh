#!/bin/bash

echo "=== running $(basename $0) ==="

# 安装lzo
tar -zxf lzo-2.10.tar.gz
cd lzo-2.10
./configure --enable-shared --prefix /usr/local/lib/lzo-2.10
make
sudo make install
cd ..

sudo cp /usr/local/lib/lzo-2.10/lib/liblzo* /usr/lib

# 安装hadoop-lzo
sudo apt-get install lzop
sudo apt-get install maven # lzo-2.10使用maven而不是ant

C_INCLUDE_PATH=/usr/local/lib/lzo-2.10/include
LIBRARY_PATH=/usr/local/lib/lzo-2.10/lib
mvn clean package

# 复制文件到hadoop相关目录
cp hadoop-lzo-release-0.4.20/target/hadoop-lzo-0.4.20.jar $HADOOP_HOME/share/hadoop/common/lib
# cp hadoop-lzo-release-0.4.20/target/hadoop-lzo-0.4.20.jar $HADOOP_HOME/lib/ # or?
cp hadoop-lzo-release-0.4.20/target/native/Linux-amd64-64/lib/* $HADOOP_HOME/lib/native

# 额外配置hadoop
echo 'export HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/common/lib/hadoop-lzo-0.4.20.jar' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
# hadoop-lzo和hadoop自带native libs放在了一起
echo 'export JAVA_LIBRARY_PATH=$HADOOP_HOME/lib/native' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# 复制文件到hbase相关目录
mkdir -p $HBASE_HOME/lib/native
cp hadoop-lzo-release-0.4.20/target/native/Linux-amd64-64/lib/* $HBASE_HOME/lib/native

# 额外配置hbase # /usr/local/lib ?
echo 'export HBASE_LIBRARY_PATH=$HBASE_LIBRARY_PATH:$HBASE_HOME/lib/native:/usr/local/lib/lzo-2.10/lib' >> $HBASE_HOME/conf/hbase-env.sh

# vi $HADOOP_HOME/etc/hadoop/core-site.xml
sed '/<\/configuration>/'d $HADOOP_HOME/etc/hadoop/core-site.xml > core-site.xml.tmp
cat >> core-site.xml.tmp << EOF
	<property>
		<name>mapred.compress.map.output</name>
		<value>true</value>
	</property>
	<property>
		<name>mapred.map.output.compression.codec</name>
		<value>com.hadoop.compression.lzo.LzoCodec</value>
	</property>
	<property>
		 <name>io.compression.codecs</name>
		 <value>org.apache.hadoop.io.compress.GzipCodec,
			org.apache.hadoop.io.compress.DefaultCodec,
			org.apache.hadoop.io.compress.BZip2Codec,
			com.hadoop.compression.lzo.LzoCodec,
			com.hadoop.compression.lzo.LzopCodec</value>
	</property>
	<property>
		<name>io.compression.codec.lzo.class</name>
		<value>com.hadoop.compression.lzo.LzoCodec</value>
	</property>
</configuration>
EOF
cat core-site.xml.tmp > $HADOOP_HOME/etc/hadoop/core-site.xml
rm core-site.xml.tmp

# 测试
# hbase org.apache.hadoop.hbase.util.CompressionTest hdfs://master:9000/test_path lzo
