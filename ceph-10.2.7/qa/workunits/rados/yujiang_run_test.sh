#!/bin/bash -ex
#python cleanpool.py
#./clone.sh 1 > clone.sh.log 2>&1
#python cleanpool.py
#./load-gen-big.sh 1 > load-gen-big.sh.log 2>&1
#python cleanpool.py
#./load-gen-mix.sh 1 > load-gen-mix.sh.log 2>&1
#python cleanpool.py
#./load-gen-mix-small-long.sh 1 > load-gen-mix-small-long.sh.log 2>&1
#python cleanpool.py
#./load-gen-mix-small.sh 1 > load-gen-mix-small.sh.log 2>&1
#python cleanpool.py
#./load-gen-mostlyread.sh 1 > load-gen-mostlyread.sh.log 2>&1
#python cleanpool.py
#./stress_watch.sh 1 > stress_watch.sh.log 2>&1
#python cleanpool.py
#./test_alloc_hint.sh 1 > test_alloc_hint.sh.log 2>&1
#python cleanpool.py
#./test_cache_pool.sh 1 > test_cache_pool.sh.log 2>&1
#python cleanpool.py
#./test_hang.sh 1 > test_hang.sh.log 2>&1
#python cleanpool.py
#./test_pool_quota.sh 1 > test_pool_quota.sh.log 2>&1
#python cleanpool.py
#./test_python.sh 1 > test_python.sh.log 2>&1
#python cleanpool.py
#./test_rados_timeouts.sh 1 > test_rados_timeouts.sh.log 2>&1
#python cleanpool.py
#./test_rados_tool.sh 1 > test_rados_tool.sh.log 2>&1
python cleanpool.py
./test.sh 1 > test.sh.log 2>&1
python cleanpool.py
./test_tmap_to_omap.sh 1 > test_tmap_to_omap.sh.log 2>&1
python cleanpool.py
./test-upgrade-v11.0.0.sh 1 > test-upgrade-v11.0.0.sh.log 2>&1
python cleanpool.py
