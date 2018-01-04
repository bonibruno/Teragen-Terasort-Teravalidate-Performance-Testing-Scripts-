#!/bin/bash

trap "" HUP

if [ $EUID -eq 0 ]; then
   echo "this script must not be run as root. su to hdfs user to run"
   exit 1
fi

MR_EXAMPLES_JAR=/usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples.jar

#SIZE=500G
#ROWS=5000000000

#SIZE=100G
#ROWS=1000000000

 SIZE=1T
 ROWS=10000000000

# SIZE=10G
# ROWS=100000000

# SIZE=1G
# ROWS=10000000


LOGDIR=logs

if [ ! -d "$LOGDIR" ]
then
    mkdir ./$LOGDIR
fi

DATE=`date +%Y-%m-%d:%H:%M:%S`

RESULTSFILE="./$LOGDIR/teragen_results_$DATE"


OUTPUT=/data/teragen/${SIZE}-terasort-input

# teragen.sh
# Kill any running MapReduce jobs
mapred job -list | grep job_ | awk ' { system("mapred job -kill " $1) } '
# Delete the output directory
hadoop fs -rm -r -f -skipTrash ${OUTPUT}

# Run teragen
time hadoop jar $MR_EXAMPLES_JAR teragen \
-Dmapreduce.map.log.level=INFO \
-Dmapreduce.reduce.log.level=INFO \
-Dyarn.app.mapreduce.am.log.level=INFO \
-Dio.file.buffer.size=131072 \
-Dmapreduce.map.cpu.vcores=1 \
-Dmapreduce.map.java.opts=-Xmx3276m \
-Dmapreduce.map.maxattempts=1 \
-Dmapreduce.map.memory.mb=4096 \
-Dmapreduce.map.output.compress=true \
-Dmapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.Lz4Codec \
-Dmapreduce.reduce.cpu.vcores=1 \
-Dmapreduce.reduce.java.opts=-Xmx6553m \
-Dmapreduce.reduce.maxattempts=1 \
-Dmapreduce.reduce.memory.mb=8192 \
-Dmapreduce.task.io.sort.factor=100 \
-Dmapreduce.task.io.sort.mb=2047 \
-Dyarn.app.mapreduce.am.command.opts=-Xmx3276m \
-Dyarn.app.mapreduce.am.resource.mb=4096 \
-Dmapred.map.tasks=112 \
${ROWS} ${OUTPUT} >> $RESULTSFILE 2>&1
 
#-Dmapreduce.map.log.level=TRACE \
#-Dmapreduce.reduce.log.level=TRACE \
#-Dyarn.app.mapreqduce.am.log.level=TRACE \
