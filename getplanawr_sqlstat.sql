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

select 
       s.snap_id snap,to_char(sn.end_interval_time,'dd/mm/yyyy hh24:mi:ss') end_interval_time,
       --s.sql_id,
       s.plan_hash_value plan_hash   
	  , EXECUTIONS_DELTA EXEC_DELTA
      , (round(s.ELAPSED_TIME_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as ela_poe
      , (round(s.BUFFER_GETS_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA))) as LIO_poe
      , (round(s.CPU_TIME_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as CPU_poe
      , (round(s.IOWAIT_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as IOWAIT_poe
      , (round(s.ccwait_delta/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as CCWAIT_poe
	  , (round(s.APWAIT_delta/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as APWAIT_poe
	  , (round(s.CLWAIT_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as CLWAIT_poe
      , (round(s.DISK_READS_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA))) as PIO_poe
      , (round(s.ROWS_PROCESSED_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA))) as Rows_poe
      , ROUND(ELAPSED_TIME_DELTA/1000000) ELA_DELTA_SEC
      , ROUND(CPU_TIME_DELTA/1000000) CPU_DELTA_SEC
      , ROUND(IOWAIT_DELTA/1000000) IOWAIT_DELTA_SEC
      ,DISK_READS_DELTA
      ,BUFFER_GETS_DELTA
      ,ROWS_PROCESSED_DELTA
      ,round(BUFFER_GETS_DELTA/decode(ROWS_PROCESSED_DELTA,0,null,ROWS_PROCESSED_DELTA)) LIO_PER_ROW
	  ,round(DISK_READS_DELTA/decode(ROWS_PROCESSED_DELTA,0,null,ROWS_PROCESSED_DELTA),2) IO_PER_ROW
	  ,s.IOWAIT_DELTA/decode(s.DISK_READS_DELTA, null, 1,0,1, s.DISK_READS_DELTA)/1000 as awg_IO_tim
from dba_hist_sqlstat s, 
     dba_hist_snapshot sn
where
    s.sql_id in ('&SQLID')
and s.snap_id = sn.snap_id
and sn.instance_number = 1
and s.instance_number = 1
and s.dbid=&DBID.
and s.dbid=sn.dbid
order by sql_id,s.snap_id;

Prompt NODE 2
select 
       s.snap_id snap,to_char(sn.end_interval_time,'dd/mm/yyyy hh24:mi:ss') end_interval_time,
       --s.sql_id,
       s.plan_hash_value plan_hash   
	  , EXECUTIONS_DELTA EXEC_DELTA
      , (round(s.ELAPSED_TIME_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as ela_poe
      , (round(s.BUFFER_GETS_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA))) as LIO_poe
      , (round(s.CPU_TIME_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as CPU_poe
      , (round(s.IOWAIT_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as IOWAIT_poe
      , (round(s.ccwait_delta/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as CCWAIT_poe
	  , (round(s.APWAIT_delta/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as APWAIT_poe
	  , (round(s.CLWAIT_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA)/1000)) as CLWAIT_poe
      , (round(s.DISK_READS_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA))) as PIO_poe
      , (round(s.ROWS_PROCESSED_DELTA/decode(s.EXECUTIONS_DELTA, null, 1,0,1, s.EXECUTIONS_DELTA))) as Rows_poe
      , ROUND(ELAPSED_TIME_DELTA/1000000) ELA_DELTA_SEC
      , ROUND(CPU_TIME_DELTA/1000000) CPU_DELTA_SEC
      , ROUND(IOWAIT_DELTA/1000000) IOWAIT_DELTA_SEC
      ,DISK_READS_DELTA
      ,BUFFER_GETS_DELTA
      ,ROWS_PROCESSED_DELTA
      ,round(BUFFER_GETS_DELTA/decode(ROWS_PROCESSED_DELTA,0,null,ROWS_PROCESSED_DELTA)) LIO_PER_ROW
	  ,s.IOWAIT_DELTA/decode(s.DISK_READS_DELTA, null, 1,0,1, s.DISK_READS_DELTA)/1000 as awg_IO_tim
from dba_hist_sqlstat s, 
     dba_hist_snapshot sn
where
    s.sql_id in ('&SQLID')
and s.snap_id = sn.snap_id
and sn.instance_number = 2
and s.instance_number = 2
and s.dbid=&DBID.
and s.dbid=sn.dbid
order by sql_id,s.snap_id;
prompt ===============================================================================
