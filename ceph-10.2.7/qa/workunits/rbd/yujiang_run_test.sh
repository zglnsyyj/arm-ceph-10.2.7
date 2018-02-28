#!/bin/bash

#./import_export.sh 1 > arm_kylin_import_export.sh.log 2>&1
#python cleanpool.py
#./rbd-nbd.sh 1 > arm_kylin_rbd-nbd.sh.log 2>&1
#python cleanpool.py
#./test_admin_socket.sh 1 > arm_kylin_test_admin_socket.sh.log 2>&1
#python cleanpool.py
#./test_librbd.sh 1 > arm_kylin_test_librbd.sh.log 2>&1
#python cleanpool.py
#./test_rbd_mirror.sh 1 > arm_kylin_test_rbd_mirror.sh.log 2>&1
#python cleanpool.py
#./copy.sh 1 > arm_kylin_copy.sh.log 2>&1
#python cleanpool.py
#./huge-tickets.sh 1 > arm_kylin_huge-tickets.sh.log 2>&1
#python cleanpool.py
#./journal.sh 1 > arm_kylin_journal.sh.log 2>&1
#python cleanpool.py
#./map-unmap.sh 1 > arm_kylin_map-unmap.sh.log 2>&1
#python cleanpool.py
#./qemu-iotests.sh 1 > arm_kylin_qemu-iotests.sh.log 2>&1
#python cleanpool.py
#./read-flags.sh 1 > arm_kylin_read-flags.sh.log 2>&1
#python cleanpool.py

#./test_librbd_api.sh 1 > arm_kylin_test_librbd_api.sh.log 2>&1
#python cleanpool.py

./test_lock_fence.sh 1 > arm_kylin_test_lock_fence.sh.log 2>&1
python cleanpool.py
./verify_pool.sh 1 > arm_kylin_verify_pool.sh.log 2>&1
python cleanpool.py
./diff_continuous.sh 1 > arm_kylin_diff_continuous.sh.log 2>&1
python cleanpool.py
./kernel.sh 1 > arm_kylin_kernel.sh.log 2>&1
python cleanpool.py
./run_cli_tests.sh 1 > arm_kylin_run_cli_tests.sh.log 2>&1
python cleanpool.py
./smalliobench.sh 1 > arm_kylin_smalliobench.sh.log 2>&1
python cleanpool.py
./test_librbd_python.sh 1 > arm_kylin_test_librbd_python.sh.log 2>&1
python cleanpool.py
./test_rbdmap_RBDMAPFILE.sh 1 > arm_kylin_test_rbdmap_RBDMAPFILE.sh.log 2>&1
python cleanpool.py

