# teratests.sh
TeraGen, TeraSort, and TeraValidate Performance Testing Scripts for HDP, CDH, and CDP.

Usage: ./terabench.sh -p <teragen|terasort|teravalidate|all> -x <replication_level> -m <map tasks> -M <map memory> -r <reduce tasks> -R <reduce memory> -d <data size> -s <shuffle type>
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

eg: ./terabench.sh -p terasort -x 2 -m 200 -r 300 -d 100000000 -s regular -i terasort_in -o terasort_out

eg: ./terabench.sh -p teragen -x 3 -m 200 -r 300 -d 100000000 -s regular -i terasort_in -B 512 -o terasort_out -D HDP
