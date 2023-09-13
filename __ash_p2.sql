with summ as
 (select /*+materialize*/
   sql_id,
   sql_plan_hash_value,
   SQL_EXEC_START,
   sql_plan_line_id,
   event,
   count(1) smpl_cnt,
   min(sample_time) start_tim,
   max(sample_time) end_tim,
   GROUPING_ID(sql_id, sql_plan_hash_value, SQL_EXEC_START) g1,
   GROUPING_ID(sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id, event) g2
    from dba_hist_active_sess_history
   where sql_id = '&SQLID'
     and dbid = &DBID.
     and snap_id between &start_sn. and &end_sn.
   group by GROUPING SETS((sql_id, sql_plan_hash_value, SQL_EXEC_START),(sql_id, sql_plan_hash_value, SQL_EXEC_START, sql_plan_line_id, event)))
SELECT s_tot.sql_plan_hash_value plan_hash_value,
       to_char(s_tot.SQL_EXEC_START, 'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_START,
       to_char(s_tot.end_tim, 'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_END,
       plan.id,
       LPAD(' ', depth) || plan.operation || ' ' || plan.options ||
       NVL2(plan.object_name, ' (' || plan.object_name || ')', null) pl_operation,
       case when summ1.event is null and summ1.smpl_cnt is not null then 'CPU' else summ1.event
       end event,
       summ1.smpl_cnt * 10 tim,
       round(100 * summ1.smpl_cnt / s_tot.smpl_cnt, 2) tim_pct,
       to_char(summ1.start_tim, 'yyyy/mm/dd hh24:mi:ss') step_start, 
       to_char(summ1.end_tim, 'yyyy/mm/dd hh24:mi:ss') step_end
  FROM dba_hist_sql_plan plan,
       (select sql_id, sql_plan_hash_value, SQL_EXEC_START, smpl_cnt, end_tim from summ where g2 <> 0) s_tot,
       (select sql_id, sql_plan_hash_value, SQL_EXEC_START, smpl_cnt, start_tim, end_tim, event, sql_plan_line_id from summ where g2 = 0) summ1
 WHERE plan.sql_id = '&SQLID'
   and plan.dbid = &DBID.
   and s_tot.sql_id = plan.sql_id
   and s_tot.sql_plan_hash_value = plan.plan_hash_value
   and s_tot.SQL_EXEC_START = summ1.SQL_EXEC_START
   and nvl(summ1.sql_plan_line_id,0) = plan.id
   and summ1.sql_id = plan.sql_id
   and summ1.sql_plan_hash_value = plan.plan_hash_value
 ORDER BY summ1.SQL_EXEC_START, s_tot.sql_plan_hash_value, plan.id, nvl(summ1.event, 'CPU');