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

# should succeed if images already exist in the pool
rados --pool $POOL_NAME create rbd_directory
rbd create --pool $POOL_NAME --size 1 foo

echo OK
