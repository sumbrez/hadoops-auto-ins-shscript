#!/bin/bash

echo "=== running $(basename $0) ==="

hdfs namenode -format; start-dfs.sh; start-hbase.sh
