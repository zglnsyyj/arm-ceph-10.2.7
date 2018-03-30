#!/bin/bash

#CEPH_CAPACITY=`ceph -s | grep used | awk '{print $4}'`
# Unit GB
CEPH_CAPACITY_GB=33517
CLUSTER_CAPACITY_PERCENTAGE=50
CEPH_CAPACITY=$((${CEPH_CAPACITY_GB}*1024))
echo $CEPH_CAPACITY
POOL_NAME="datapool"
PG_NUM=1024
POOL_COPY_NUM=3

RBD_NUMBER_PER_MACHINE=10
MACHINE_NUMBER=3
RBD_SIZE=$((${CEPH_CAPACITY}/${RBD_NUMBER_PER_MACHINE}/${MACHINE_NUMBER}/${POOL_COPY_NUM}*${CLUSTER_CAPACITY_PERCENTAGE}/100))
echo $RBD_SIZE

DD_FILE_SIZE=55
DD_FILE_NUMBER_PER_RBD=1
# ************* must modify
MACHINE_ID=1
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
 rbd map $POOL_NAME/"$MACHINE_NAME-3-rbd-$k"
done
}

krbdunmap(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 rbd unmap /dev/rbd/$POOL_NAME/"$MACHINE_NAME-3-rbd-$k"
done
}

krbdformatfilesystem(){
for ((k=1;k<=$(($RBD_NUMBER_PER_MACHINE/2));k++));
do
 mkfs.ext4 /dev/rbd/$POOL_NAME/"$MACHINE_NAME-3-rbd-$k"
done
for ((k=6;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 mkfs.xfs /dev/rbd/$POOL_NAME/"$MACHINE_NAME-3-rbd-$k"
done
}

krbdmount(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 mount /dev/rbd/$POOL_NAME/"$MACHINE_NAME-3-rbd-$k" "$PERFIX_DIRECTORY""$MACHINE_NAME-$MACHINE_ID/$MACHINE_NAME-$MACHINE_ID-rbd-$k"
done
}

krbdumount(){
for ((k=1;k<=$RBD_NUMBER_PER_MACHINE;k++));
do
 umount /dev/rbd/$POOL_NAME/"$MACHINE_NAME-3-rbd-$k"
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
IOZONE_TEST_FILE=""
DIRECTORY_LEVEL_SPLICING=""
DIRECTORY_DEPTH=4
NUMBER_OF_FILES_EACH_DIRECTORY=1
PROCESS_LOWER=$((${NUMBER_OF_FILES_EACH_DIRECTORY}*${DIRECTORY_DEPTH}*${RBD_NUMBER_PER_MACHINE}))
PROCESS_UPPER=$((${NUMBER_OF_FILES_EACH_DIRECTORY}*${DIRECTORY_DEPTH}*${RBD_NUMBER_PER_MACHINE}))

iozone_splicing_directory(){
for dir in `find ${PERFIX_DIRECTORY}${MACHINE_NAME}-${MACHINE_ID}/ -regex "${PERFIX_DIRECTORY}${MACHINE_NAME}-${MACHINE_ID}/node.*" -print | grep -v lost`
do
 for ((k=1;k<=$NUMBER_OF_FILES_EACH_DIRECTORY;k++));
 do
  IOZONE_TEST_FILE=" ${IOZONE_TEST_FILE}  ${dir}/${k}-FILE"
 done
 echo ${dir}
done
}

#echo $((${RBD_SIZE}/${DIRECTORY_DEPTH}/${NUMBER_OF_FILES_EACH_DIRECTORY}-500))
iozone_test(){
for unit in ${RW_UNITS[@]}
do
# iozone -z -u -l $PROCESS_LOWER -u $PROCESS_UPPER -r ${unit} -s "$((${RBD_SIZE}/${DIRECTORY_DEPTH}/${NUMBER_OF_FILES_EACH_DIRECTORY}-500))m" -F ${IOZONE_TEST_FILE}
 DATE_TIME_TMP=`date "+%Y_%m_%d_%H_%M_%S"`
# iozone -+u -+d -+p -+t -z -l ${PROCESS_LOWER} -u ${PROCESS_UPPER} -r ${unit} -s $((${RBD_SIZE}/(${DIRECTORY_DEPTH}+1)/${NUMBER_OF_FILES_EACH_DIRECTORY}))"m" -F ${IOZONE_TEST_FILE} -Rb "${DATE_TIME_TMP}_${PROCESS_LOWER}_${PROCESS_UPPER}_${unit}_${RBD_SIZE}_iozone_result.xls"
 iozone -+p -+t -z -l ${PROCESS_LOWER} -u ${PROCESS_UPPER} -r ${unit} -s $((${RBD_SIZE}/(${DIRECTORY_DEPTH}+1)/${NUMBER_OF_FILES_EACH_DIRECTORY}))"m" -F ${IOZONE_TEST_FILE} -Rb "${DATE_TIME_TMP}_${PROCESS_LOWER}_${PROCESS_UPPER}_${unit}_${RBD_SIZE}_iozone_result.xls" > run.log
done
}

#create_mount_point
#create_pool
#create_rbd
krbdmap
krbdformatfilesystem
krbdmount
#create_directory_level

#while true
#do
#iozone_splicing_directory
#iozone_test
#done

#ddfile
#krbdumount
#krbdunmap
