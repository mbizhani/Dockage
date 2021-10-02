#!/bin/bash

JOB="${FIO_JOB_NAME:-fio}_$(date +'%Y-%m-%d_%H.%M')"
NUM_JOBS="${FIO_NUM_JOBS:-4}"
SIZE="${FIO_SIZE:-1G}"
TEST_DIR="${FIO_TEST_DIR:-/var/FIO}"
OUT_DIR="${FIO_OUT_DIR:-/opt/fio}"
SLEEP="${FIO_SLEEP:-10}"

echo "FIO_JOB_NAME: ${JOB}"
echo "FIO_NUM_JOBS: ${NUM_JOBS}"
echo "FIO_SIZE:     ${SIZE}"
echo "FIO_TEST_DIR: ${TEST_DIR}"
echo "FIO_OUT_DIR:  ${OUT_DIR}"
echo "FIO_SLEEP:    ${SLEEP}"

mkdir -p ${TEST_DIR} ${OUT_DIR}
rm -rf ${TEST_DIR}/*


# Test write throughput by performing sequential writes with multiple parallel streams (8+),
# using an I/O block size of 1 MB and an I/O depth of at least 64
echo "${JOB}: Write.Throughput Starting ..."
fio \
  --name=${JOB}_write_throughput \
  --directory=${TEST_DIR} \
  --numjobs=${NUM_JOBS} \
  --size=${SIZE} \
  --time_based \
  --runtime=60s \
  --ramp_time=2s \
  --ioengine=libaio \
  --direct=1 \
  --verify=0 \
  --bs=1M \
  --iodepth=64 \
  --rw=write \
  --group_reporting=1 \
  --output-format=normal \
  --output="${OUT_DIR}/${JOB}_write_throughput.txt"

rm -rf ${TEST_DIR}/*
echo "${JOB}: Write.Throughput Finished"
sleep ${SLEEP}


# Test write IOPS by performing random writes, using an I/O block size of 4 KB and an I/O depth of at least 64
echo "${JOB}: Write.IOPS Starting ..."
fio \
  --name=${JOB}_write_iops \
  --directory=${TEST_DIR} \
  --numjobs=${NUM_JOBS} \
  --size=${SIZE} \
  --time_based \
  --runtime=60s \
  --ramp_time=2s \
  --ioengine=libaio \
  --direct=1 \
  --verify=0 \
  --bs=4K \
  --iodepth=64 \
  --rw=randwrite \
  --group_reporting=1 \
  --output-format=normal \
  --output="${OUT_DIR}/${JOB}_write_iops.txt"

rm -rf ${TEST_DIR}/*
echo "${JOB}: Write.IOPS Finished"
sleep ${SLEEP}


# Test read throughput by performing sequential reads with multiple parallel streams (8+),
# using an I/O block size of 1 MB and an I/O depth of at least 64
echo "${JOB}: Read.Throughput Starting ..."
fio \
  --name=${JOB}_read_throughput \
  --directory=${TEST_DIR} \
  --numjobs=${NUM_JOBS} \
  --size=${SIZE} \
  --time_based \
  --runtime=60s \
  --ramp_time=2s \
  --ioengine=libaio \
  --direct=1 \
  --verify=0 \
  --bs=1M \
  --iodepth=64 \
  --rw=read \
  --group_reporting=1 \
  --output-format=normal \
  --output="${OUT_DIR}/${JOB}_read_throughput.txt"

rm -rf ${TEST_DIR}/*
echo "${JOB}: Read.Throughput Finished"
sleep ${SLEEP}


# Test read IOPS by performing random reads, using an I/O block size of 4 KB and an I/O depth of at least 64
echo "${JOB}: Read.IOPS Starting ..."
fio \
  --name=${JOB}_read_iops \
  --directory=${TEST_DIR} \
  --numjobs=${NUM_JOBS} \
  --size=${SIZE} \
  --time_based \
  --runtime=60s \
  --ramp_time=2s \
  --ioengine=libaio \
  --direct=1 \
  --verify=0 \
  --bs=4K \
  --iodepth=64 \
  --rw=randread \
  --group_reporting=1 \
  --output-format=normal \
  --output="${OUT_DIR}/${JOB}_read_iops.txt"

rm -rf $TEST_DIR/*
echo "${JOB}: Read.IOPS Finished"
