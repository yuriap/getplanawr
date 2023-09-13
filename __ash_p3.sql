select SQL_EXEC_START,
       to_char(max(sample_time) over(partition by SQL_EXEC_START, plan_hash_value) + 0, 'yyyy/mm/dd hh24:mi:ss') sql_exec_end,
       plan_hash_value, id, row_src, event, cnt,
       round(100 * cnt / sum(cnt) over(partition by SQL_EXEC_START, plan_hash_value), 2) tim_pct,
       round(100 * sum(cnt) over(partition by id, SQL_EXEC_START, plan_hash_value) / sum(cnt) over(partition by SQL_EXEC_START, plan_hash_value), 2) tim_id_pct,
       obj, tbs
  from (select to_char(SQL_EXEC_START, 'yyyy/mm/dd hh24:mi:ss') SQL_EXEC_START,
               sql_plan_hash_value plan_hash_value,
               sql_plan_line_id id,
               sql_plan_operation || ' ' || sql_plan_options row_src,
               obj,tbs,
               nvl(event, 'CPU') event,
               count(1) cnt,
               max(sample_time) sample_time
          from (select x.*,
                       case when CURRENT_OBJ#>0 then (select object_type||'.'||object_name from dba_objects where object_id=CURRENT_OBJ#) else to_char(CURRENT_OBJ#) end obj,     
                       case when CURRENT_FILE#>0 then (select TABLESPACE_NAME from dba_data_files where FILE_ID=CURRENT_FILE#) else null end tbs          
            from gv$active_session_history x)
         where sql_id = '&SQLID'
         group by SQL_EXEC_START,
                  sql_plan_hash_value,
                  sql_plan_line_id,
                  sql_plan_operation || ' ' || sql_plan_options,
                  nvl(event, 'CPU'),
                  obj,tbs) x
 order by SQL_EXEC_START, plan_hash_value, id, event; 