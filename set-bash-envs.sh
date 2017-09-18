#!/bin/bash

echo "=== running $(basename $0) ==="

source conf

JAVA_HOME=$libpath/jdk/`ls $libpath/jdk`
echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
echo 'export JRE_HOME=${JAVA_HOME}/jre' >> ~/.bashrc
echo 'export PATH=${JAVA_HOME}/bin:${JRE_HOME}/lib:$PATH' >> ~/.bashrc
echo 'export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib' >> ~/.bashrc
echo '' >> ~/.bashrc

HADOOP_HOME=$libpath/hadoop/`ls $libpath/hadoop`
echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc
echo 'export PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH' >> ~/.bashrc
echo '' >> ~/.bashrc

HBASE_HOME=$libpath/hbase/`ls $libpath/hbase`
echo "export HBASE_HOME=$HBASE_HOME" >> ~/.bashrc
echo 'export PATH=$PATH:$HBASE_HOME/bin' >> ~/.bashrc
echo '' >> ~/.bashrc

PHOENIX_HOME=$libpath/phoenix/`ls $libpath/phoenix`
echo "export PHOENIX_HOME=$PHOENIX_HOME" >> ~/.bashrc
echo 'export PATH=$PATH:$PHOENIX_HOME/bin' >> ~/.bashrc
echo 'export CLASSPATH=${CLASSPATH}:${PHOENIX_HOME}' >> ~/.bashrc
echo '' >> ~/.bashrc

source ~/.bashrc
