set lines 250
alter session set nls_date_language='AMERICAN';
column plsql_entry_object_id new_val plsql_id
column plsql_entry_subprogram_id new_val plsql_sub_id

prompt DBID=&DBID.

prompt ====== ASH section =========================================================
prompt ASH summary
@@__ash_summ

prompt ASH PL/SQL Entry (if you see error ORA-00936 it means that it was not called from PL/SQL)
@prntbl "select * from dba_procedures where object_id=&plsql_id. and subprogram_id=&plsql_sub_id."

BREAK ON plan_hash_value on SQL_EXEC_START skip 1 nodup on PL_OPERATION
COMPUTE sum LABEL Total OF TIM ON SQL_EXEC_START

column plan_hash_value format 999999999999
column exec_id format 999999999
column PL_OPERATION format a100
column EVENT format a35
column TIM format 999g999
column TIM_PCT format 999d999
column row_src format a35
column START_TIM format a24
column end_tim format a24
prompt ===============================================================================		  
set lines 500
prompt AWR ASH (SQL Monitor) P1
@@__ash_p1
 
prompt AWR ASH (SQL Monitor) P1.1
@@__ash_p1_1

prompt ===============================================================================
prompt AWR ASH (SQL Monitor) P2
@@__ash_p2
 

prompt ===============================================================================
prompt Active ASH (SQL Monitor) P3

@@__ash_p3

prompt ===============================================================================