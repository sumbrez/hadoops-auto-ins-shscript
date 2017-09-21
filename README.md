# Hadoops-auto-ins-shscript
JDK、Hadoop、HBase、Phoenix集群自动部署脚本

## 目录结构和文件说明
```
├── progs                # 用于存放JDK等，使用tar解压，文件名称为示例
│   ├── (*jdk*.tar.gz)
│   ├── (*hadoop*.tar.gz)
│   ├── (*hbase*.tar.gz)
│   └── (*phoenix*.tar.gz)
├── sudopw              # 用于修改、重置NOPASSWD的配置和脚本（未使用）
│   └── ...
├── conf                # 配置文件
├── conf-progs.sh       # 用于配置组件
├── hosts               # 按照hosts格式列出的集群信息
├── hosts-ext           # 自带的额外hosts信息（IPv6）
├── install-progs.sh    # 安装组件
├── README.md           # 本说明文件
├── run-on-master.sh    # 入口，运行在master节点
├── run-remain.sh       # 运行初始之外的其他脚本
├── set-bash-envs.sh    # 设置环境变量
└── set-hosts.sh        # 设置hosts信息到/etc/hosts
```

## 配置文件`conf`说明
- `uname=hadoop` - 各节点用户名（需要统一）
- `passwd=hadoop` - 各节点密码（需要统一）
- `prog_arr=(jdk hadoop hbase phoenix)` - 脚本和组件有较强耦合，放在`conf`文件里意义不大
- `prog_subdir=progs` - 组件子目录
- `libdir=/usr/lib` - 组件安装目录，各组件会自动创建子目录
- `tmpdir=/var/tmp` - 各组件临时文件目录，同样创建子目录
- `master=master` - master节点hostname
- `slaves=(master slave01)` - slave节点hostname，必须有括号，各slave以空格隔开
- `regionservers=(master slave01)` - HBase的regionservers，格式和`slaves`格式相同
- `quorums=(master slave01)` - Zookeeper集群的地址列表，格式和`slaves`格式相同，脚本会自动按照`hbase.zookeeper.quorum`格式要求转换

## 使用步骤
1. 建立若干ubuntu server节点
2. 为每个节点建立统一名称的用户
3. 更新源，安装vim、ssh server、python，为master安装expect
4. 为用户赋予sudo权限和NOPASSWD权限
5. 为每个节点配置hostname和ip并保持和配置文件hosts一致
6. 发送文件到master节点并`chmod -R 755`（slave节点会自动执行`chmod`）
7. 在master上执行`run-on-master.sh`，正确执行则不需要回答ssh的yes/no或者输入用户密码
8. ~~安装完成后为每个机器执行`source ~/.bashrc`~~ 现在使用expect+ssh登录的方式执行此句，但好像仍然没用
9. 脚本中使用`ssh $uname@$hostname`方式，之后无论使用`ssh $uname@$hostname`还是`@$ip`都不需要回答yes

## 其他说明
- 文件默认放在用户文件夹根目录
- 解压时将保持外层目录，会出现`$libdir/jdk/jdk1.8.0_144`之类的目录结构，而本脚本要求`jdk`下只有一个jdk版本（其他组件类似）；`install-prog.sh`中将执行`rm -rf`操作，但为方便“调试”，提供了`tar --skip-old-files`操作，同时提供了`scp`到slave节点的相应的“调试”操作
- HBase使用自带zookeeper
- 使用`~/.bashrc`文件

## 关于脚本的补充
- 在`run-on-master.sh`中master更新自己的hosts后，配置slave便可以使用`$hostname`，但要求hosts中第一个是master
- 在`run-on-master.sh`中`spawn scp .bashrc`文件时，~~源文件目录部分使用~/.ssh会报错找不到文件，使用.ssh和/home/$uname/.ssh均不会报错……~~ 现在使用`spawn sh -c`支持shell命令，~/.ssh写法已可用
- 在`run-on-master.sh`的expect中使用
    ```
    expect "(yes/no)"
    send "yes\r"
    expect "password:"
    send "$passwd\r"
    expect eof
    ```
    会报错expect: spawn id exp4 not open while executing "expect eof"，相关命令可能被完整执行，也可能没被执行（乱得忘记了）
- 脚本中的`unset JAVA_HOME`系列操作可能没有用，即使没有`source ~/.bashrc`，`JAVA_HOME`系列可能依然有脚本中作为变量设置的值（值和`.bashrc`中的相同）
- 不使用expect时，为避免回答ssh的yes/no可以使用`ssh -o StrictHostKeyChecking=no 'cmd'`，但只是“一时有效”
