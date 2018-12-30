select plan_hash_value, id, row_src "Row source", event, cnt "Time",
       round(100 * cnt / sum(cnt) over(partition by id), 2) "Time, %",
	   round(100 * sum(cnt) over(partition by id) / sum(cnt) over()) "Time by ID, %",
       obj "Object", tbs "Tablespace"
  from (select sql_plan_hash_value plan_hash_value,
               sql_plan_line_id id,
               sql_plan_operation || ' ' || sql_plan_options row_src,
               obj,tbs,
               nvl(event, 'CPU') event,
               count(1) cnt
          from (select x.*,
                       case when CURRENT_OBJ#>0 then (select object_type||'.'||object_name from dba_objects where object_id=CURRENT_OBJ#) else to_char(CURRENT_OBJ#) end obj,     
                       case when CURRENT_FILE#>0 then (select TABLESPACE_NAME from dba_data_files where FILE_ID=CURRENT_FILE#) else null end tbs          
            from gv$active_session_history x)
         where sql_id = '&SQLID'
         group by sql_plan_hash_value,
                  sql_plan_line_id,
                  sql_plan_operation || ' ' || sql_plan_options,
                  nvl(event, 'CPU'),
                  obj,tbs) x
 order by plan_hash_value, id, event; 