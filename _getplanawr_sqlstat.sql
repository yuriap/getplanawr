set pages 40
set lines 500
column end_interval_time format a20
column snap format 9999999
column plan_hash format 99999999999
column ela_poe 		format 999g999g999
column LIO_poe 		format 999g999g999g999
column CPU_poe	format 999g999g999
column IOWAIT_poe	format 999g999g999
column CCWAIT_poe	format 999g999g999
column CLWAIT_poe	format 999g999g999
column APWAIT_poe	format 999g999g999
column PIO_poe	format 999g999g999
column Rows_poe	format 999g999g999
column EXEC_DELTA format 999g999g999
column ELA_DELTA_SEC format 999g999g999g999
column CPU_DELTA_SEC format 999g999g999g999
column IOWAIT_DELTA_SEC format 999g999g999g999
column DISK_READS_DELTA format 999g999g999g999
column BUFFER_GETS_DELTA format 999g999g999g999
column ROWS_PROCESSED_DELTA format 999g999g999g999
column LIO_PER_ROW format 999g999g999
column ROW_PER_IO format 999g999g999D99
column awg_IO_tim format 999g999D999


BREAK ON REPORT
COMPUTE SUM OF EXEC_DELTA ELA_DELTA_SEC CPU_DELTA_SEC IOWAIT_DELTA_SEC DISK_READS_DELTA BUFFER_GETS_DELTA ROWS_PROCESSED_DELTA ON REPORT

prompt DBID=&DBID.
Prompt NODE 1
define INST_ID=1
@@__sqlstat

Prompt NODE 2
define INST_ID=2
@@__sqlstat

prompt ===============================================================================
