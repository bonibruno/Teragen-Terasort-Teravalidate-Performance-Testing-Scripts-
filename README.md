# Teragen-Terasort-Teravalidate-Performance-Testing-Scripts
TeraGen, TeraSort, and TeraValidate Performance Testing Scripts for Hortonworks HDP

Before running the scripts, determine the data size and number of records required.

By default, a data set of 1TB with 10000000000 rows is generated. If you want to change the dataset size and rows, simply preset the size and rows in the beginning of each script accordingly. Make sure you use the same size/rows on all the scripts!

A log directory is created based on where you run the script. Run output and stats are stored in the logs directory.

Run the jobs in the following order: teragen, terasort, teravalidate.

Note:  The tuning parameters specified in the scripts should be changed to accomodate your particular Hadoop cluster.  
