set lines 250
alter session set nls_date_language='AMERICAN';
column plsql_entry_object_id new_val plsql_id
column plsql_entry_subprogram_id new_val plsql_sub_id

prompt DBID=&DBID.

prompt ====== ASH section =========================================================
prompt ASH summary
select sql_id,
       top_level_sql_id,
       sql_plan_hash_value,
       force_matching_signature,
       sql_exec_id,
       sql_exec_start,
       min(sample_time) start_tim,
       max(sample_time) end_tim,
       plsql_entry_object_id,
       plsql_entry_subprogram_id,
       program,
       machine,
       ecid,module,action,client_id, user_id
  from dba_hist_active_sess_history
 where sql_id = '&SQLID' and dbid=&DBID.
 group by sql_id,
          top_level_sql_id,
          sql_plan_hash_value,
          force_matching_signature,
          sql_exec_id,
          sql_exec_start,
          plsql_entry_object_id,
          plsql_entry_subprogram_id,
          program,
          machine,
          ecid,module,action,client_id, user_id
order by sql_exec_start;

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
select sql_plan_hash_value plan_hash_value,
       --sql_exec_id exec_id,
	   to_char((SQL_EXEC_START),'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_START,
       sql_plan_line_id id,
       sql_plan_operation|| ' '|| sql_plan_options row_src,
       event,
       count(1) * 10 tim,
       min(sample_time) start_tim,
       max(sample_time) end_tim
  from dba_hist_active_sess_history
 where sql_id = '&SQLID' and dbid=&DBID.
 group by sql_plan_hash_value,
          SQL_EXEC_START,
          sql_plan_line_id,
          sql_plan_operation,
          sql_plan_options,
          event
 order by SQL_EXEC_START, sql_plan_hash_value, sql_plan_line_id;
 
prompt AWR ASH (SQL Monitor) P1.1
select sql_plan_hash_value plan_hash_value,
       sql_plan_line_id id,
       sql_plan_operation|| ' '|| sql_plan_options row_src,
       nvl(event, 'CPU') event,
       count(1) * 10 tim,
       min(sample_time) start_tim,
       max(sample_time) end_tim
  from dba_hist_active_sess_history
 where sql_id = '&SQLID' and dbid=&DBID.
 group by sql_plan_hash_value,
          sql_plan_line_id,
          sql_plan_operation,
          sql_plan_options,
          nvl(event, 'CPU')
 order by sql_plan_hash_value, sql_plan_line_id;
prompt ===============================================================================
prompt AWR ASH (SQL Monitor) P2
with summ as
 (
 select /*+materialize*/ sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id, event, count(1) smpl_cnt, 
         GROUPING_ID(sql_id, sql_plan_hash_value, SQL_EXEC_START) g1,
         GROUPING_ID(sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id,event) g2
    from dba_hist_active_sess_history
   where sql_id = '&SQLID' and dbid=&DBID.
   group by GROUPING SETS ((sql_id, sql_plan_hash_value, SQL_EXEC_START),(sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id,event))
   )
SELECT s_tot.sql_plan_hash_value plan_hash_value,
       to_char(s_tot.SQL_EXEC_START,'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_START,
       plan.id,
       LPAD(' ', depth) || plan.operation || ' ' || plan.options ||
       NVL2(plan.object_name, ' [' || plan.object_name || ']', null) pl_operation,
     case when summ.event is null and summ.smpl_cnt is not null then 'CPU' else summ.event end event,
       summ.smpl_cnt*10 tim, round(100*summ.smpl_cnt/s_tot.smpl_cnt,2) tim_pct
  FROM dba_hist_sql_plan plan, 
       (select  sql_id, sql_plan_hash_value, SQL_EXEC_START, smpl_cnt from summ where g2<>0) s_tot,
       summ
 WHERE plan.sql_id = '&SQLID' and plan.dbid=&DBID.
   and s_tot.sql_id = plan.sql_id
   and s_tot.sql_plan_hash_value = plan.plan_hash_value
   and s_tot.SQL_EXEC_START=summ.SQL_EXEC_START
   and summ.sql_plan_line_id=plan.id
   and summ.sql_id = plan.sql_id
   and summ.sql_plan_hash_value = plan.plan_hash_value
 ORDER BY summ.SQL_EXEC_START, s_tot.sql_plan_hash_value, plan.id,nvl(summ.event,'CPU');
 

prompt ===============================================================================
prompt Active ASH (SQL Monitor) P3

select x.*,round(ratio_to_report(cnt)over(partition by plan_hash_value)*100,2) TIM_PCT from (         
select to_char(SQL_EXEC_START,'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_START,sql_plan_hash_value plan_hash_value,
       sql_plan_line_id id,
       sql_plan_operation|| ' '|| sql_plan_options row_src,
       nvl(event, 'CPU') event,
       count(1) cnt
  from v$active_session_history
 where sql_id = '&SQLID'  
group by SQL_EXEC_START,
         sql_plan_hash_value,
         sql_plan_line_id,
         sql_plan_operation|| ' '|| sql_plan_options,
         nvl(event, 'CPU')     )x   
order by SQL_EXEC_START,plan_hash_value,id,event;
prompt ===============================================================================