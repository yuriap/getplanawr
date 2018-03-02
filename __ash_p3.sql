select SQL_EXEC_START,
       max(sample_time) over(partition by SQL_EXEC_START, plan_hash_value) + 0 sql_exec_end,
       plan_hash_value, id, row_src, event, cnt,
       round(100 * cnt / sum(cnt) over(partition by SQL_EXEC_START, plan_hash_value), 2) tim_pct,
       round(100 * sum(cnt) over(partition by id, SQL_EXEC_START, plan_hash_value) / sum(cnt) over(partition by SQL_EXEC_START, plan_hash_value), 2) tim_id_pct   
  from (select to_char(SQL_EXEC_START, 'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_START,
               sql_plan_hash_value plan_hash_value,
               sql_plan_line_id id,
               sql_plan_operation || ' ' || sql_plan_options row_src,
               nvl(event, 'CPU') event,
               count(1) cnt,
               max(sample_time) sample_time
          from v$active_session_history
         where sql_id = '&SQLID'
         group by SQL_EXEC_START,
                  sql_plan_hash_value,
                  sql_plan_line_id,
                  sql_plan_operation || ' ' || sql_plan_options,
                  nvl(event, 'CPU')) x
 order by SQL_EXEC_START, plan_hash_value, id, event;
