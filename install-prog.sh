#!/bin/bash

# 安装组件

echo "=== running $(basename $0) ==="

source conf

prog_arr=(jdk hadoop hbase phoenix)

# 解压
for file in `ls`; do
	for prog in ${prog_arr[@]}; do
		if [ $file = *$prog*.tar.gz -o $file = *$prog*.tgz ]; then
			echo "*** unpacking "$file" to "$libpath/$prog" ***"
			sudo mkdir -p $libpath/$prog
			#sudo rm -rf $libpath/$prog/* # 删除原来的，避免出现多个版本影响`ls $libpath/$prog`结果
			sudo rm -rf $tmppath/$prog/* # 删除原来的tmp内容
			sudo tar --skip-old-files -zxf $file -C $libpath/$prog

			sudo chown -R hadoop:hadoop $libpath/$prog
			sudo chmod -R 755 $libpath/$prog
		fi
	done
done
