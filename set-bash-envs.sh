#!/bin/bash

echo "=== running $(basename $0) ==="

source conf

# 删除原有的环境变量
sed '/JAVA_HOME/'d  ~/.bashrc | sed '/HADOOP_HOME/d' | sed '/HBASE_HOME/d' | sed '/PHOENIX_HOME/d' > ~/.bashrc.tmp
cat ~/.bashrc.tmp > ~/.bashrc
rm ~/.bashrc.tmp

# 设置新的环境变量
JAVA_HOME=$libdir/jdk/`ls $libdir/jdk`
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo 'export JRE_HOME=${JAVA_HOME}/jre' >> ~/.bashrc
echo 'export PATH=${JAVA_HOME}/bin:${JRE_HOME}/lib:$PATH' >> ~/.bashrc
echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> ~/.bashrc

HADOOP_HOME=$libdir/hadoop/`ls $libdir/hadoop`
echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc
echo 'export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH' >> ~/.bashrc

HBASE_HOME=$libdir/hbase/`ls $libdir/hbase`
echo "export HBASE_HOME=$HBASE_HOME" >> ~/.bashrc
echo 'export PATH=$PATH:$HBASE_HOME/bin' >> ~/.bashrc

PHOENIX_HOME=$libdir/phoenix/`ls $libdir/phoenix`
echo "export PHOENIX_HOME=$PHOENIX_HOME" >> ~/.bashrc
echo 'export PATH=$PATH:$PHOENIX_HOME/bin' >> ~/.bashrc
# echo 'export CLASSPATH=${CLASSPATH}:${PHOENIX_HOME}' >> ~/.bashrc
echo 'export CLASSPATH=${CLASSPATH}:${PHOENIX_HOME}/'`ls $PHOENIX_HOME | grep -v thin | grep client.jar` >> ~/.bashrc

# 避免和~/.bashrc变量混淆、冲突
unset JAVA_HOME
unset HADOOP_HOME
unset HBASE_HOME
unset PHOENIX_HOME
