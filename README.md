# Hadoops-auto-ins-shscript
JDK、Hadoop、HBase、Phoenix集群自动部署脚本

## 目录结构和文件说明
```
├── sudopw              # 用于修改、重置NOPASSWD的配置和脚本（未使用）
│   └── ...
├── prog                # 用于存放JDK等，使用tar解压，文件名称为示例（未使用，组件放在根目录）
│   ├── (jdk.tar.gz)
│   ├── (hadoop.tar.gz)
│   ├── (hbase.tar.gz)
│   └── (phoenix.tar.gz)
├── conf                # 配置文件
├── conf-prog.sh        # 用于配置组件
├── hosts               # 按照hosts格式列出的集群信息
├── hosts-ext           # 自带的额外hosts信息（IPv6）
├── install-prog.sh     # 安装组件
├── README.md           # 本说明文件
├── run-on-master.sh    # 入口，运行在master节点
├── run-remain.sh       # 运行初始之外的其他脚本
├── set-bash-envs.sh    # 设置环境变量
└── set-hosts.sh        # 设置hosts信息到/etc/hosts
```

## 配置文件`conf`说明
- `libpath=/usr/lib` - 组件安装目录，各组件会自动创建子目录
- `tmppath=/var/tmp` - 各组件临时文件目录，同样创建子目录
- `master=master` - master节点hostname
- `slaves=(master slave01)` - slave节点hostname，必须有括号，各slave以空格隔开
- `regionservers=(master slave01)` - HBase的regionservers，格式和`slaves`格式相同


## 其他说明
- 解压时将保持外层目录，会出现`$libpath/jdk/jdk1.8.0_144`之类的目录结构，而本脚本要求`jdk`下只有一个jdk版本（其他组件类似）；`install-prog.sh`中将执行`rm -rf`操作，但为方便“调试”，提供了`tar --skip-old-files`操作
- HBase使用自带zookeeper
- 使用`~/.bashrc`文件

## 使用步骤
1. 建立若干ubuntu server节点
2. 为每个节点建立hadoop用户
3. 更新源，安装vim、ssh server、python
3. 为hadoop用户赋予sudo权限和NOPASSWD权限
4. 为每个节点配置hostname和ip并保持和配置文件的hosts一致
5. 发送文件到master节点并`chmod 755`（slave节点会自动执行`chmod`）
6. 在master上执行`run-on-master.sh`
7. 安装完成后为每个机器执行`source ~/.bashrc`
