with summ as
 (
 select /*+materialize*/ sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id, event, count(1) smpl_cnt, 
         GROUPING_ID(sql_id, sql_plan_hash_value, SQL_EXEC_START) g1,
         GROUPING_ID(sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id,event) g2
    from dba_hist_active_sess_history
   where sql_id = '&SQLID' and dbid=&DBID. and snap_id between &start_sn. and &end_sn.
   group by GROUPING SETS ((sql_id, sql_plan_hash_value, SQL_EXEC_START),(sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id,event))
   )
SELECT s_tot.sql_plan_hash_value plan_hash_value,
       to_char(s_tot.SQL_EXEC_START,'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_START,
       plan.id,
       LPAD(' ', depth) || plan.operation || ' ' || plan.options ||
       NVL2(plan.object_name, ' (' || plan.object_name || ')', null) pl_operation,
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