#!/bin/bash

PGS=`ceph health detail | grep '^pg' | awk '{print $2}'`
for pg in ${PGS[@]}
do
 ceph pg repair ${pg}
done

echo $PG
# xargs `ceph pg repair `
