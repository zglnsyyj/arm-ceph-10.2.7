#!/bin/bash

CEPH_CAPACITY=`ceph -s | grep used | awk '{print $4}'`

POOL_NAME="datapool"
PG_NUM=1024

RBD_SIZE=61440
RBD_NUMBER_PER_MACHINE=10
MACHINE_NUMBER=3

DD_FILE_SIZE=55
DD_FILE_NUMBER_PER_RBD=1
# ************* must modify
MACHINE_ID=3
MACHINE_NAME="node"
# ************* must modify
# ************* prefix directory
PERFIX_DIRECTORY="/home/"
# ************* prefix directory

# create mount point
create_mount_point(){
for ((j=1;j<=$RBD_NUMBER_PER_MACHINE;j++));
do
 mkdir -p "$PERFIX_DIRECTORY""$MACHINE_NAME-$MACHINE_ID/$MACHINE_NAME-$MACHINE_ID-rbd-$j"
done
}

# create directory level, call after mount
DIRECTORY_LEVEL="/1/2/3/"
create_directory_level(){
for ((j=1;j<=$RBD_NUMBER_PER_MACHINE;j++));
do
 mkdir -p "$PERFIX_DIRECTORY""$MACHINE_NAME-$MACHINE_ID/$MACHINE_NAME-$MACHINE_ID-rbd-$j""$DIRECTORY_LEVEL"
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
  rbd create --pool $POOL_NAME --size $RBD_SIZE "$MACHINE_NAME-$j-rbd-$k"
 done
done
}

# krbd
krbdmap(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 rbd map $POOL_NAME/"$MACHINE_NAME-$MACHINE_ID-rbd-$k"
done
}

krbdunmap(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 rbd unmap /dev/rbd/$POOL_NAME/"$MACHINE_NAME-$MACHINE_ID-rbd-$k"
done
}

krbdformatfilesystem(){
for ((k=1;k<=$(($RBD_NUMBER_PER_MACHINE/2));k++));
do
 mkfs.ext4 /dev/rbd/$POOL_NAME/"$MACHINE_NAME-$MACHINE_ID-rbd-$k"
done
for ((k=6;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 mkfs.xfs /dev/rbd/$POOL_NAME/"$MACHINE_NAME-$MACHINE_ID-rbd-$k"
done
}

krbdmount(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 mount /dev/rbd/$POOL_NAME/"$MACHINE_NAME-$MACHINE_ID-rbd-$k" "$PERFIX_DIRECTORY""$MACHINE_NAME-$MACHINE_ID/$MACHINE_NAME-$MACHINE_ID-rbd-$k"
done
}

krbdumount(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 umount /dev/rbd/$POOL_NAME/"$MACHINE_NAME-$MACHINE_ID-rbd-$k"
done
}

ddfile(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 for ((l=1;l<=$DD_FILE_NUMBER_PER_RBD;l++));
 do
  dd if=/dev/zero of="$PERFIX_DIRECTORY""$MACHINE_NAME-$MACHINE_ID/$MACHINE_NAME-$MACHINE_ID-rbd-$k/$MACHINE_NAME-$MACHINE_ID-rbd-$k-file-$l"  bs=1G count=$DD_FILE_SIZE
 done
done
}

# iozone test
DATE_TIME=`date "+%Y_%m_%d_%H_%M_%S"`
RW_UNITS=("4k" "8k" "64k" "1024k")
PROCESS_LOWER=32
PROCESS_UPPER=32
IOZONE_TEST_FILE=""
DIRECTORY_DEPTH=4
NUMBER_OF_FILES_EACH_DIRECTORY=2
iozone_splicing_directory(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 for ((m=1;m<=$NUMBER_OF_FILES_EACH_DIRECTORY;m++));
 do
   IOZONE_TEST_FILE="${IOZONE_TEST_FILE} ${PERFIX_DIRECTORY}${MACHINE_NAME}-${MACHINE_ID}/${MACHINE_NAME}-${MACHINE_ID}-rbd-${k}/${k}-${m}"
   for ((l=1;l<=$DIRECTORY_DEPTH;l++));
   do
    IOZONE_TEST_FILE="${IOZONE_TEST_FILE} ${PERFIX_DIRECTORY}${MACHINE_NAME}-${MACHINE_ID}/${MACHINE_NAME}-${MACHINE_ID}-rbd-${k}/${l}/${k}-${l}-${m}"
   done
  #$IOZONE_TEST_FILE = "${PERFIX_DIRECTORY}${MACHINE_NAME}-${MACHINE_ID}/${MACHINE_NAME}-${MACHINE_ID}-rbd-${k}\n"
 done
done
echo $IOZONE_TEST_FILE
}

iozone_test(){
for unit in ${RW_UNITS[@]}
do
# iozone -z -l $PROCESS_LOWER -u $PROCESS_UPPER -r ${unit} -s 30g -F /root/iozone/iozone.tmp
 echo ${unit}
done
}
#create_mount_point
#create_pool
#create_rbd
#krbdmap
#krbdformatfilesystem
#krbdmount
#create_directory_level
iozone_splicing_directory
#iozone_test
#ddfile
#krbdumount
#krbdunmap
