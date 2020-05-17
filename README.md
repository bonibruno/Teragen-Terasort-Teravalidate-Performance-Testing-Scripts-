# teratests.sh
TeraGen, TeraSort, and TeraValidate Performance Testing Scripts for HDP, CDH, and CDP.

Usage: ./teratests.sh -p <teragen|terasort|teravalidate|all> -x <replication_level> -m <map tasks> -M <map memory> -r <reduce tasks> -R <reduce memory> -d <data size> -s <shuffle type>
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

                -d - Data size in number of 100byte rows, the default is 1000000000

                -s - shuffle type. Allowed options are regular or uda, default is regular

                -B - DFS block size. Allowed options (128|256|512|1024), default is 128 MB

                -D - Distribution. Allowed options are CDH, HDP and CDP

                -h - print this message

Below are some examples on executing teragen, terasort, and teravalidate with teratests.sh.  Note that the Hadoop distribution will be the same for all three tests when running on a cluster, I'm just showing here that the three distributions are supported, i.e. -D HDP, -D CDH, and -D CDP.

eg: ./teratests.sh -p teragen -x 1 -m 200 -M 4096 -d 100000000 -s regular -B 256 -i ts_in -o ts_out -D HDP

eg: ./teratests.sh -p terasort -x 1 -m 200 -M 4096 -r 100 -R 4096 -B 256 -i ts_in -o ts_out -D CDP

eg: ./teratests.sh -p teravalidate -M 4096 -B 256 -i ts_in -o ts_out -O ts_rep -D CDH


Note:  When setting memory options with the -M or -R flags, make sure you choose values that are greater than the defined mapreduce.map.java.opts and mapreduce.reduce.java.opts on your Hadoop cluster or else you will get memory exceeded errors!!!
