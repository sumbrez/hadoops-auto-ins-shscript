#!/bin/bash

echo "=== running $(basename $0) ==="

source config

ins_ornot=$1

# 解压
file=`ls $prog_subdir | grep hue.*gz`
prog="hue"
echo "*** unpacking $file to $libdir/$prog ***"
sudo mkdir -p $libdir/$prog
if [[ $ins_ornot != nocover ]]; then
    sudo rm -rf $libdir/$prog/* # 删除原来的，避免出现多个版本影响`ls $libdir/$prog`结果
    sudo rm -rf $tmpdir/$prog/* # 删除原来的tmp内容
fi
sudo tar --skip-old-files -zxf $prog_subdir/$file -C $libdir/$prog

sudo chown -R $uname:$uname $libdir/$prog
sudo chmod -R 755 $libdir/$prog

# 删除原有的环境变量
sed '/HUE_HOME/'d ~/.bashrc > ~/.bashrc.tmp
cat ~/.bashrc.tmp > ~/.bashrc
rm ~/.bashrc.tmp

# 设置新环境变量
HUE_HOME=$libdir/hue/`ls $libdir/hue`
echo "export HUE_HOME=$HUE_HOME" >> ~/.bashrc
echo 'export PATH=$PATH:$HUE_HOME/build/env/bin' >> ~/.bashrc

confdir=$HUE_HOME/desktop/conf
if [ ! -f "$confdir/hue.ini" ]; then
    confdir=$HUE_HOME/desktop/conf.dist
fi

sed -i 's@## hbase_clusters=@hbase_clusters=@g' $confdir/hue.ini
sed -i 's@## hbase_conf_dir=/etc/hbase/conf@hbase_conf_dir=$HBASE_HOME/conf@g' $confdir/hue.ini
sed -i 's@## thrift_transport=@thrift_transport=@g' $confdir/hue.ini
# 暂时无用
# sed -i 's@## default_hdfs_superuser=hdfs@default_hdfs_superuser=hadoop@g'$confdir/hue.ini

# 增加Phoenix snippet
sed -i "/\[\[\[hive\]\]\]/i\[\[\[phoenix\]\]\]\nname=Phoenix\ JDBC\ninterface=jdbc\noptions='{\"url\":\"jdbc:phoenix:$master:2181\",\"driver\":\"org.apache.phoenix.jdbc.PhoenixDriver\",\"user\":\"\",\"password\":\"\"}'\n" $confdir/hue.ini

unset HUE_HOME
