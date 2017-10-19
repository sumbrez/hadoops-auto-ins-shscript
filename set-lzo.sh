#!/bin/bash

echo "=== running $(basename $0) ==="

source config

HADOOP_HOME=$libdir/hadoop/"`ls $libdir/hadoop`"

# 额外配置hadoop
echo 'export HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/common/lib' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh # 可以不带/hadoop-lzo-0.4.20.jar
# hadoop-lzo和hadoop自带native libs放在了一起
echo 'export JAVA_LIBRARY_PATH=$HADOOP_HOME/lib/native' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

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
