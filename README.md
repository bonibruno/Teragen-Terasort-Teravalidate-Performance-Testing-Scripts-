# Teragen-Terasort-Teravalidate-Performance-Testing-Scripts
TeraGen, TeraSort, and TeraValidate Performance Testing Scripts for Hortonworks HDP

To run TeraGen, TeraSort, and TeraValidate a determination of the volume of data and number of records is required. For example you can generate 1TB of data with 10000000000 rows.

By default a data set of 1TB is generated. If you want to use different dataset size and rows, preset the size and rows in the script accordingly. This applies to all scripts (teragen.sh, terasort.sh, validate.sh). All scripts must have same SIZE & ROWS setting.

A log directory is created based on where you run the script. Run output and stats are stored in the logs directory.

Run the jobs in the following order: teragen, terasort, teravalidate.
