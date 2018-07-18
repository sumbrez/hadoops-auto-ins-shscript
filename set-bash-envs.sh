#!/bin/bash

echo "=== running $(basename $0) ==="

source config

# 删除原有的环境变量
sed '/JAVA_HOME/'d ~/.bashrc | sed '/HADOOP_HOME/d' | sed '/HBASE_HOME/d' | sed '/PHOENIX_HOME/d' | sed '/PIG_HOME/d' > ~/.bashrc.tmp
cat ~/.bashrc.tmp > ~/.bashrc
rm ~/.bashrc.tmp

# 设置新的环境变量
if [[ -n `echo "${prog_arr[*]}" | grep jdk` ]]; then # 是否配置安装jdk
    JAVA_HOME=$libdir/jdk/`ls $libdir/jdk`
    if [ $? -eq 0 ]; then # 是否存在jdk安装后目录
        echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
        echo 'export JRE_HOME=$JAVA_HOME/jre' >> ~/.bashrc
        echo 'export PATH=$JAVA_HOME/bin:$JRE_HOME/lib:$PATH' >> ~/.bashrc
        echo 'export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib' >> ~/.bashrc
    fi
fi

if [[ -n `echo "${prog_arr[*]}" | grep hadoop` ]]; then
    HADOOP_HOME=$libdir/hadoop/`ls $libdir/hadoop`
    if [ $? -eq 0 ]; then
        echo "export HADOOP_HOME=$HADOOP_HOME" >> ~/.bashrc
        echo 'export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH' >> ~/.bashrc
    fi
fi

if [[ -n `echo "${prog_arr[*]}" | grep hbase` ]]; then
    HBASE_HOME=$libdir/hbase/`ls $libdir/hbase`
    if [ $? -eq 0 ]; then
        echo "export HBASE_HOME=$HBASE_HOME" >> ~/.bashrc
        echo 'export PATH=$PATH:$HBASE_HOME/bin' >> ~/.bashrc
        echo 'export CLASSPATH=$CLASSPATH:$HBASE_HOME/conf' >> ~/.bashrc # 需要将hbase-site.xml加入CP以支持namespace/schema
    fi
fi

if [[ -n `echo "${prog_arr[*]}" | grep phoenix` ]]; then
    PHOENIX_HOME=$libdir/phoenix/`ls $libdir/phoenix`
    if [ $? -eq 0 ]; then
        echo "export PHOENIX_HOME=$PHOENIX_HOME" >> ~/.bashrc
        echo 'export PATH=$PATH:$PHOENIX_HOME/bin' >> ~/.bashrc
        # echo 'export CLASSPATH=$CLASSPATH:$PHOENIX_HOME' >> ~/.bashrc
        # 将client.jar加入CP以便直接运行sqlline.py
        phoenix_jar=`ls $PHOENIX_HOME | grep -v thin | grep client.jar`
        echo 'export CLASSPATH=$CLASSPATH:$PHOENIX_HOME/'$phoenix_jar >> ~/.bashrc
        ln -s $PHOENIX_HOME/$phoenix_jar $JAVA_HOME/jre/lib/ext/
        ln -s $HBASE_HOME/conf $JAVA_HOME/jre/lib/ext/
    fi
fi

if [[ -n `echo "${prog_arr[*]}" | grep pig` ]]; then
    PIG_HOME=$libdir/pig/`ls $libdir/pig`
    if [ $? -eq 0 ]; then
        echo "export PIG_HOME=$PIG_HOME" >> ~/.bashrc
        echo 'export PATH=$PATH:$PIG_HOME/bin' >> ~/.bashrc
    fi
fi

# 避免和~/.bashrc变量混淆、冲突
unset JAVA_HOME
unset HADOOP_HOME
unset HBASE_HOME
unset PHOENIX_HOME
unset PIG_HOME
