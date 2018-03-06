#!/bin/bash -ex

POOL_NAME="krbd-cli"
POOL_NAME_CLONE="krbd-cli-clone"
IMAGE_NAME="image-cli"
IMAGE_NAME_OBJECT="image-cli-object"
IMAGE_SNAP_NAME="snap-image-cli"
IMAGE_SNAP_CLONE_NAME="snap-image-cli-clone-rbd"
PG_NUM=128

tear_down () {
  ceph osd pool delete $POOL_NAME $POOL_NAME --yes-i-really-really-mean-it || true
  ceph osd pool delete $POOL_NAME_CLONE $POOL_NAME_CLONE --yes-i-really-really-mean-it || true
}

set_up () {
  ceph osd pool create $POOL_NAME $PG_NUM
  ceph osd pool create $POOL_NAME_CLONE $PG_NUM
}

trap tear_down EXIT HUP INT
set_up

# creating an image in a pool-managed snapshot pool should fail
rbd create --pool $POOL_NAME --size 102400 $IMAGE_NAME

# non-default object size 8M
rbd create $POOL_NAME/$IMAGE_NAME_OBJECT --size 10240 --object-size 8M

# To create a new snapshot
rbd snap create $POOL_NAME/$IMAGE_NAME@$IMAGE_SNAP_NAME

rbd snap ls $POOL_NAME/$IMAGE_NAME

rbd --pool $POOL_NAME snap protect --image $IMAGE_NAME --snap $IMAGE_SNAP_NAME

rbd clone $POOL_NAME/$IMAGE_NAME@$IMAGE_SNAP_NAME $POOL_NAME_CLONE/$IMAGE_SNAP_CLONE_NAME

rbd ls -p $POOL_NAME_CLONE

rbd info $POOL_NAME_CLONE/$IMAGE_SNAP_CLONE_NAME

rbd children $POOL_NAME/$IMAGE_NAME@$IMAGE_SNAP_NAME

rbd flatten $POOL_NAME_CLONE/$IMAGE_SNAP_CLONE_NAME

rbd snap unprotect $POOL_NAME/$IMAGE_NAME@$IMAGE_SNAP_NAME

rbd snap rm $POOL_NAME/$IMAGE_NAME@$IMAGE_SNAP_NAME


# list rbd
rbd list -p $POOL_NAME

# show rbd info
rbd info $POOL_NAME/$IMAGE_NAME

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

rbd rm $POOL_NAME/$IMAGE_NAME

echo OK
