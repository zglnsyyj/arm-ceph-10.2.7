#!/bin/bash -ex

CEPH_CAPACITY=`ceph -s | grep used | awk '{print $4}'`

POOL_NAME="datapool"
PG_NUM=1024

RBD_SIZE=61440
RBD_NUMBER_PER_MACHINE=10
MACHINE_NUMBER=3

DD_FILE_SIZE=55
DD_FILE_NUMBER_PER_RBD=1
# *************must modify
MACHINE_ID=3
# *************must modify

# create mount point
create_mount_point(){
for ((j=1;j<=$RBD_NUMBER_PER_MACHINE;j++));
do
 mkdir -p "/root/node-$MACHINE_NUMBER/node-$MACHINE_ID-rbd-$j"
done
}

# create pool
create_pool(){
ceph osd pool create $POOL_NAME $PG_NUM 
}

# create rbd
create_rbd(){
for ((j=1;j<=$MACHINE_NUMBER;j++));
do
 for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
 do
  rbd create --pool $POOL_NAME --size $RBD_SIZE "node-$j-rbd-$k"
 done
done
}

# krbd
krbdmap(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 rbd map $POOL_NAME/"node-$MACHINE_ID-rbd-$k"
done
}

krbdunmap(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 rbd unmap /dev/rbd/$POOL_NAME/"node-$MACHINE_ID-rbd-$k"
done
}

krbdformatfilesystem(){
for ((k=1;k<=$(($RBD_NUMBER_PER_MACHINE/2));k++));
do
 mkfs.ext4 /dev/rbd/$POOL_NAME/"node-$MACHINE_ID-rbd-$k"
done
for ((k=6;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 mkfs.xfs /dev/rbd/$POOL_NAME/"node-$MACHINE_ID-rbd-$k"
done
}

krbdmount(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 mount /dev/rbd/$POOL_NAME/"node-$MACHINE_ID-rbd-$k" /root/node-$MACHINE_NUMBER/node-$MACHINE_ID-rbd-$k
done
}

krbdumount(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 umount /dev/rbd/$POOL_NAME/"node-$MACHINE_ID-rbd-$k"
done
}

ddfile(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 for ((l=1;l<=$DD_FILE_NUMBER_PER_RBD;l++));
 do
  dd if=/dev/zero of="/root/node-$MACHINE_NUMBER/node-$MACHINE_ID-rbd-$k/node-$MACHINE_ID-rbd-$k-file-$l"  bs=$DD_FILE_SIZE"G" count=1
 done
done
}

#create_mount_point
#create_pool
#create_rbd
#krbdmap
#krbdformatfilesystem
#krbdmount
ddfile
#krbdumount
#krbdunmap
