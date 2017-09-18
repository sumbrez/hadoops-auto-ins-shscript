#!/bin/bash

echo "=== running $(basename $0) ==="

source conf

# ssh u@h 'cmd' 作为no-login shell无法执行source ~/.bashrc，出此下策
JAVA_HOME=$libdir/jdk/"`ls $libdir/jdk`"
HADOOP_HOME=$libdir/hadoop/"`ls $libdir/hadoop`"
HBASE_HOME=$libdir/hbase/"`ls $libdir/hbase`"
PHOENIX_HOME=$libdir/phoenix/"`ls $libdir/phoenix`"

# source ~/.bashrc # 除在本地外无效

# 复制phoenix server jar到hbase lib
sudo cp $PHOENIX_HOME/phoenix-*-HBase-*-server.jar $HBASE_HOME/lib/

#set_hadoop_env
sed -i "s@.*export JAVA_HOME=.*@export JAVA_HOME=$JAVA_HOME@" $HADOOP_HOME/etc/hadoop/hadoop-env.sh

#set_hadoop_slaves
rm -f $HADOOP_HOME/etc/hadoop/slaves
for slave in ${slaves[@]}; do
cat >> $HADOOP_HOME/etc/hadoop/slaves << EOF
$slave
EOF
done

#set_hadoop_core_site
cat > $HADOOP_HOME/etc/hadoop/core-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>hadoop.tmp.dir</name>
		<value>file:${tmpdir}/hadoop</value>
	</property>
	<property>
		<name>fs.defaultFS</name>
		<value>hdfs://${master}:9000</value>
	</property>
</configuration>

EOF

#set_hadoop_hdfs_site
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>dfs.namenode.secondary.http-address</name>
		<value>${master}:50090</value>
	</property>
	<property>
		<name>dfs.replication</name>
		<value>3</value>
	</property>
	<property>
		<name>dfs.namenode.name.dir</name>
		<value>file:${tmpdir}/hadoop/dfs/name</value>
	</property>
	<property>
		<name>dfs.datanode.data.dir</name>
		<value>file:${tmpdir}/hadoop/dfs/data</value>
	</property>
</configuration>

EOF

#set_hbase_env
sed -i "s@.*export JAVA_HOME=.*@export JAVA_HOME=$JAVA_HOME@" $HBASE_HOME/conf/hbase-env.sh
sed -i "s@.*export HBASE_PID_DIR=.*@export HBASE_PID_DIR=$tmpdir/hbase/pids@" $HBASE_HOME/conf/hbase-env.sh
sed -i "s@.*export HBASE_MANAGES_ZK=.*@export HBASE_MANAGES_ZK=true@" $HBASE_HOME/conf/hbase-env.sh
#export HBASE_CLASSPATH=$HBASE_HOME/conf

#set_hbase_regionservers
rm -f $HBASE_HOME/conf/regionservers
for server in ${regionservers[@]}; do
cat >> $HBASE_HOME/conf/regionservers << EOF
$server
EOF
done

#set_hbase_site
cat > $HBASE_HOME/conf/hbase-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>hbase.regionserver.wal.codec</name>
		<value>org.apache.hadoop.hbase.regionserver.wal.IndexedWALEditCodec</value>
	</property>
	<property>
		<name>hbase.rootdir</name>
		<value>hdfs://${master}:9000/hbase</value>
	</property>
	<property>
		<name>hbase.cluster.distributed</name>
		<value>true</value>
	</property>
	<property>
		<name>hbase.zookeeper.quorum</name>
		<value>${master}</value>
	</property>
	<property>
		<name>hbase.zookeeper.property.dataDir</name>
		<value>file:${tmpdir}/zk/zk_data</value>
	</property>
</configuration>

EOF

#set_phoenix_hbase_site
cat > $PHOENIX_HOME/bin/hbase-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>hbase.regionserver.wal.codec</name>
		<value>org.apache.hadoop.hbase.regionserver.wal.IndexedWALEditCodec</value>
	</property>
	<property>
		<name>hbase.rootdir</name>
		<value>hdfs://${master}:9000/hbase</value>
	</property>
	<property>
		<name>hbase.cluster.distributed</name>
		<value>true</value>
	</property>
	<property>
		<name>hbase.zookeeper.quorum</name>
		<value>${master}</value>
	</property>
	<property>
		<name>hbase.zookeeper.property.dataDir</name>
		<value>file:${tmpdir}/zk/zk_data</value>
	</property>
</configuration>

EOF

# 避免和~/.bashrc变量混淆、冲突
unset JAVA_HOME
unset HADOOP_HOME
unset HBASE_HOME
unset PHOENIX_HOME
