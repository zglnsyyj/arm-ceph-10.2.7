#!/bin/bash -ex

POOL_NAME="krbd-cli"
IMAGE_NAME="image-cli"
PG_NUM=128

tear_down () {
  ceph osd pool delete $POOL_NAME $POOL_NAME --yes-i-really-really-mean-it || true
}

set_up () {
  ceph osd pool create $POOL_NAME $PG_NUM
}

trap tear_down EXIT HUP INT
set_up

# creating an image in a pool-managed snapshot pool should fail
rbd create --pool $POOL_NAME --size 1 $IMAGE_NAME

# list rbd 
rbd list -p $POOL_NAME

# rbd map
rbd map $POOL_NAME/$IMAGE_NAME

# lists the mapped rbd
rbd showmapped

# rbd lock add
rbd lock add $POOL_NAME/$IMAGE_NAME image-cli-lock

# rbd lock list
rbd lock list $POOL_NAME/$IMAGE_NAME
LOCK_CLIENT=`rbd lock list $POOL_NAME/$IMAGE_NAME | awk '{print $1}' | grep client`

# rbd lock remove
rbd lock remove $POOL_NAME/$IMAGE_NAME image-cli-lock $LOCK_CLIENT 
rbd lock list $POOL_NAME/$IMAGE_NAME

# rbd unmap
rbd unmap /dev/rbd/$POOL_NAME/$IMAGE_NAME


echo OK
