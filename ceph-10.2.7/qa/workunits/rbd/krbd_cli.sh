#!/bin/bash -ex

POOL_NAME="krbd-cli"
IMAGE_NAME="image-cli"

tear_down () {
  ceph osd pool delete $POOL_NAME $POOL_NAME --yes-i-really-really-mean-it || true
}

set_up () {
  tear_down
  ceph osd pool create $POOL_NAME $PG_NUM
}

trap tear_down EXIT HUP INT
set_up

# creating an image in a pool-managed snapshot pool should fail
rbd create --pool $POOL_NAME --size 1 $IMAGE_NAME && exit 1 || true

# list rbd 
rbd list -p $POOL_NAME

# rbd map
rbd map $POOL_NAME/$IMAGE_NAME

# rbd lock add
rbd lock add $POOL_NAME/$IMAGE_NAME image-cli-lock

# rbd lock list
rbd lock ls -p $POOL_NAME

# rbd lock remove
#rbd lock remove $POOL_NAME/$IMAGE_NAME image-cli-lock 

# rbd unmap
rbd unmap


echo OK
