#!/bin/sh

printUsage() {
    echo "Usage: $0 -p <teragen|terasort|teravalidate|all> -x <replication_level> -m <map tasks> -M <map memory> -r <reduce tasks> -R <reduce memory> -d <data size> -s <shuffle type> \
-B <128|256|512|1024> -i <input dir> -o <output dir> -O <report dir> |-h 
		-p - teragen, terasort, teravalidate or all 
		-i - input directory in HDFS
		-o - output directory in HDFS
		-O - report directory in HDFS (for teravalidate)
		-x - replication factor, default is 3 
		-m - number of map tasks, our default is 100 
		-M - map task memory size
		-r - number of reduce tasks, our default is 25 
		-R - reduce task memory size
		-d - Data size in number of 100byte rows, our default is 1000000000 
		-s - shuffle type. Allowed options are regular or uda, default is regular 
		-B - DFS block size. Allowed options (128|256|512|1024), default is 128 MB
		-D - Distribution. Allowed options are CDH, HDP and CDP
		-h - print this message 
eg: $0 -p terasort -x 2 -m 50 -r 100 -d 100000000 -s regular -i terasort_in -o terasort_out
eg: $0 -p teragen -x 3 -m 100 -r 50 -d 100000000 -s regular -i terasort_in -B 512 -o terasort_out -D HDP";
}



# main

while getopts p:x:m:M:r:R:d:s:i:o:O:B:D:h switch
do
    case $switch in 
	p) phase=$OPTARG;;
	x) replication=$OPTARG;;
	m) map_tasks=$OPTARG;;
	M) map_mem=$OPTARG;;
	r) reduce_tasks=$OPTARG;;
        R) reduce_mem=$OPTARG;;
        d) data_size=$OPTARG;;
	s) shuffle=$OPTARG;;
	i) input=$OPTARG;;
	o) output=$OPTARG;;
	O) report=$OPTARG;;
	B) blocksize=$OPTARG;;
	D) distro=$OPTARG;;
	h) printUsage && exit 0;;
      	*) echo "Unknown option" && exit 1;;
    esac
done
shift $(( $OPTIND - 1 ))

if [ $OPTIND -le 1 ]; then
    printUsage && exit 1;
fi

if [ -z $phase ]; then
   phase="all";
fi

if [ -z $blocksize ]; then
   blocksize=134217728
fi

if [ -z $input ]; then
    input=ts_in
fi
if [ -z $output ]; then
    output=ts_out
fi
if [ -z $report ]; then
    report=tv_out
fi
if [ -z $replication ]; then
    replication=3
fi
if [ -z $map_tasks ]; then
    map_tasks=100
fi
if [ -z $reduce_tasks ]; then
    reduce_tasks=25
fi
if [ -z $map_mem ]; then
     map_mem=1024
fi
if [ -z $reduce_mem ]; then
    reduce_mem=1024
fi
if [ -z $shuffle ]; then
    shuffle="regular";
fi
if [ -z $data_size ]; then
    data_size=1000000000
fi

if [ -z $distro ]; then
    distro="CDH"
fi

# ascertain distribution, whether HDP or CDH or CDP

case $distro in
    'CDH') mapreduce_jar=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar;;
    'HDP') mapreduce_jar=/usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples.jar;;
    'CDP') mapreduce_jar=/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar;;
    *) echo "Unknown distro $distro - only accept CDH|HDP|CDP" && exit 1;;
esac


yarn_bin=/usr/bin/yarn
hdfs_bin=/usr/bin/hdfs

case $shuffle in
	'regular') shuffle_algo=org.apache.hadoop.mapreduce.task.reduce.Shuffle;;
	'uda') shuffle_algo=com.mellanox.hadoop.mapred.UdaShuffleConsumerPlugin;;
	*) echo "Unknown shuffle type option - only accept <regular|uda>" && exit 1;;
esac

blkdefault=134217728
case $blocksize in
	'128') dfsblock=$blkdefault;;
	'256') dfsblock=268435456;;
	'512') dfsblock=536870912;;
	'1024') dfsblock=1073741824;;
	*) echo "unknown block size, using default $blkdefault" && dfsblock=$blkdefault;;
esac

printMesg() {
     case $1 in 
	 '1') mesg="$hdfs_bin dfs -rm -r -skipTrash $input";;
	 '2') mesg="$yarn_bin jar $mapreduce_jar teragen -Ddfs.replication=$replication \
-Ddfs.client.block.write.locateFollowingBlock.retries=15 \
-Ddfs.blocksize=$dfsblock \
-Dyarn.app.mapreduce.am.job.map.pushdown=false -Dmapreduce.job.maps=$map_tasks -Dmapreduce.map.memory.mb=$map_mem $data_size $input";;
	 '3') mesg="$hdfs_bin dfs -rm -r -skipTrash $output";;
	'4') mesg="$yarn_bin jar  $mapreduce_jar terasort  \
-Dmapreduce.job.reduce.shuffle.consumer.plugin.class=$shuffle_algo \
-Ddfs.client.block_write.locateFollowingBlock.retries=30 \
-Dmapred.reduce.child.log.level=WARN -Ddfs.replication=$replication \
-Ddfs.blocksize=$dfsblock \
-Dmapreduce.job.maps=$map_tasks -Dmapreduce.job.reduces=$reduce_tasks -Dmapreduce.reduce.memory.mb=$reduce_mem $input $output";;
	 '5') mesg="$hdfs_bin dfs -rm -r -skipTrash $report";;
	 '6') mesg="$yarn_bin jar $mapreduce_jar teravalidate -Ddfs.replication=$replication \
-Ddfs.client.block.write.locateFollowingBlock.retries=15 \
-Ddfs.blocksize=$dfsblock \
-Dyarn.app.mapreduce.am.job.map.pushdown=false -Dmapreduce.job.maps=$map_tasks -Dmapreduce.map.memory.mb=$map_mem $output $report";;
	*) echo "Unknown option" && exit 1;;
    esac
    echo "$mesg";
}

teraGenIt() {
# Run the teragen
    printMesg 1;
    $hdfs_bin dfs -rm -r -skipTrash $input;
    sleep 15;
    printMesg 2;
    $yarn_bin jar $mapreduce_jar teragen -Ddfs.replication=$replication \
-Ddfs.client.block.write.locateFollowingBlock.retries=15 \
-Ddfs.blocksize=$dfsblock \
-Dyarn.app.mapreduce.am.job.map.pushdown=false -Dmapreduce.job.maps=$map_tasks -Dmapreduce.map.memory.mb=$map_mem $data_size $input
}

teraSortIt() {
# run the terasort
   printMesg 3;
   $hdfs_bin dfs -rm -r -skipTrash $output;
    sleep 15;
   printMesg 4;
   $yarn_bin jar  $mapreduce_jar terasort  \
-Dmapreduce.job.reduce.shuffle.consumer.plugin.class=$shuffle_algo \
-Ddfs.client.block_write.locateFollowingBlock.retries=30 \
-Dmapred.reduce.child.log.level=WARN -Ddfs.replication=$replication \
-Ddfs.blocksize=$dfsblock \
-Dmapreduce.job.maps=$map_tasks -Dmapreduce.map.memory.mb=$map_mem -Dmapreduce.job.reduces=$reduce_tasks -Dmapreduce.reduce.memory.mb=$reduce_mem $input $output
}


teraValidateIt() {
# Run the teravalidate
        printMesg 5;
        $hdfs_bin dfs -rm -r -skipTrash $report;
        sleep 15;
        printMesg 6;
        $yarn_bin jar $mapreduce_jar teravalidate -Ddfs.replication=$replication \
    -Ddfs.client.block.write.locateFollowingBlock.retries=15 \
    -Ddfs.blocksize=$dfsblock \
    -Dyarn.app.mapreduce.am.job.map.pushdown=false -Dmapreduce.job.maps=$map_tasks -Dmapreduce.map.memory.mb=$map_mem $output $report
}


# Main

case $phase in
	'teragen') teraGenIt;;
	'terasort') teraSortIt;;
	'teravalidate') teraValidateIt;;
	'all') teraGenIt && teraSortIt && teraValidateIt;;
	*) echo "Unknown phase - $phase"; printUsage && exit 1;;
esac
