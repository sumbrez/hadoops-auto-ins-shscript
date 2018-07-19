#!/bin/bash

echo "=== running $(basename $0) ==="

source config

# ssh u@h 'cmd' 作为no-login shell无法执行source ~/.bashrc，出此下策
JAVA_HOME=$libdir/jdk/"`ls $libdir/jdk`"
HADOOP_HOME=$libdir/hadoop/"`ls $libdir/hadoop`"
HBASE_HOME=$libdir/hbase/"`ls $libdir/hbase`"
PHOENIX_HOME=$libdir/phoenix/"`ls $libdir/phoenix`"

# source ~/.bashrc # 除在本地外无效

# 复制phoenix server jar到hbase lib，此处可用ln -s
sudo cp $PHOENIX_HOME/phoenix-*-HBase-*-server.jar $HBASE_HOME/lib/

# set_hadoop_env
sed -i "s@.*export JAVA_HOME=.*@export JAVA_HOME=$JAVA_HOME@" $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# set_hadoop_slaves
rm -f $HADOOP_HOME/etc/hadoop/slaves
for slave in ${slaves[@]}; do
cat >> $HADOOP_HOME/etc/hadoop/slaves << EOF
$slave
EOF
done

# set_hadoop_core_site
cat > $HADOOP_HOME/etc/hadoop/core-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>hadoop.tmp.dir</name>
		<value>${tmpdir}/hadoop</value>
	</property>
	<property>
		<name>fs.defaultFS</name>
		<value>hdfs://${master}:9000</value>
	</property>

	<!-- for hue, web mng -->
	<property>
		<name>hadoop.proxyuser.hadoop.hosts</name>
		<value>*</value>
	</property>
	<property>
		<name>hadoop.proxyuser.hadoop.groups</name>
		<value>*</value>
	</property>
	<property>
		<name>hadoop.proxyuser.hue.hosts</name>
		<value>*</value>
	</property>
	<property>
		<name>hadoop.proxyuser.hue.groups</name>
		<value>*</value>
	</property>
	<property>
		<name>hadoop.proxyuser.hdfs.hosts</name>
		<value>*</value>
	</property>
	<property>
		<name>hadoop.proxyuser.hdfs.groups</name>
		<value>*</value>
	</property> 
</configuration>
EOF

# set_hadoop_hdfs_site
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
		<value>${tmpdir}/hadoop/dfs/name</value>
	</property>
	<property>
		<name>dfs.datanode.data.dir</name>
		<value>${tmpdir}/hadoop/dfs/data</value>
	</property>

	<!-- for hue, web mng -->
	<property>
		<name>dfs.webhdfs.enabled</name>
		<value>true</value>
	</property>
</configuration>
EOF

# set_hbase_env
sed -i "s@.*export JAVA_HOME=.*@export JAVA_HOME=$JAVA_HOME@" $HBASE_HOME/conf/hbase-env.sh
sed -i "s@.*export HBASE_PID_DIR=.*@export HBASE_PID_DIR=$tmpdir/hbase/pids@" $HBASE_HOME/conf/hbase-env.sh
sed -i "s@.*export HBASE_MANAGES_ZK=.*@export HBASE_MANAGES_ZK=true@" $HBASE_HOME/conf/hbase-env.sh
# export HBASE_CLASSPATH=$HBASE_HOME/conf

# set_hbase_regionservers
rm -f $HBASE_HOME/conf/regionservers
for server in ${regionservers[@]}; do
cat >> $HBASE_HOME/conf/regionservers << EOF
$server
EOF
done

# set_hbase_site
quorum_val=''
for quorum in ${quorums[@]}; do
	quorum_val="$quorum_val,$quorum"
done
quorum_val=${quorum_val#?}
cat > $HBASE_HOME/conf/hbase-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
	<property>
		<name>hbase.regionserver.wal.codec</name> <!-- phoenix 4.8+版本只需此配置，不需要额外的二级索引配置 -->
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
		<value>${quorum_val}</value>
	</property>
	<property>
		<name>hbase.zookeeper.property.dataDir</name>
		<value>${tmpdir}/zk/zk_data</value>
	</property>

	<!-- schema -->
	<property>
		<name>phoenix.schema.isNamespaceMappingEnabled</name>
		<value>true</value>
	</property>
	<property>
		<name>phoenix.schema.mapSystemTablesToNamespace</name>
		<value>true</value>
	</property>

	<!-- for hue -->
	<property>
		<name>hbase.rest.support.proxyuser</name>
		<value>true</value>
	</property>
	<!-- this seems to be useless or imcomplete -->
	<property>
		<name>hbase.thrift.support.proxyuser</name>
		<value>true</value>
	</property>
	<property>
		<name>hbase.regionserver.thrift.http</name>
		<value>true</value>
	</property>
	<property> <!-- true, and hue.ini use framed -->
		<name>hbase.regionserver.thrift.framed</name>
		<value>false</value>
	</property>
	<property>
		<name>hbase.regionserver.thrift.server.type</name>
		<value>TThreadPoolServer</value>
	</property>
</configuration>
EOF

# set_phoenix_hbase_site
cp $HBASE_HOME/conf/hbase-site.xml $PHOENIX_HOME/bin/

# 避免和~/.bashrc变量混淆、冲突
unset JAVA_HOME
unset HADOOP_HOME
unset HBASE_HOME
unset PHOENIX_HOME
