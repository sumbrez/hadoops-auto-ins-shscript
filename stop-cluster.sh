#!/bin/bash

echo "=== running $(basename $0) ==="

source config

stop-hbase.sh; stop-dfs.sh

./clear-cluster-tmp.sh
