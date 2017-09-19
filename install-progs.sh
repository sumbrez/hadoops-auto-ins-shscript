#!/bin/bash

echo "=== running $(basename $0) ==="

source conf

# 解压
for file in `ls $prog_subdir`; do
	for prog in ${prog_arr[@]}; do
	 	# 使用prog子目录时必须用此形式，否则只匹配上apache-phoenix
	 	if [[ $file == *$prog*.tar.gz ]] || [[ $file == *$prog*.taz ]]; then
		#if [ $file = *$prog*.tar.gz -o $file = *$prog*.tgz ]; then
			echo "*** unpacking "$file" to "$libdir/$prog" ***"
			sudo mkdir -p $libdir/$prog
			sudo rm -rf $libdir/$prog/* # 删除原来的，避免出现多个版本影响`ls $libdir/$prog`结果
			sudo rm -rf $tmpdir/$prog/* # 删除原来的tmp内容
			sudo tar --skip-old-files -zxf $prog_subdir/$file -C $libdir/$prog

			sudo chown -R hadoop:hadoop $libdir/$prog
			sudo chmod -R 755 $libdir/$prog
		fi
	done
done
