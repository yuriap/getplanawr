select
  plan_hash_value,id,row_src "Row source",event,tim "Time",
  round(100 * tim / sum(tim) over(partition by id) , 2) "Time, %",
  round(100 * sum(tim) over(partition by id) / sum(tim) over(), 2) "Time by ID, %"
from (
select sql_plan_hash_value plan_hash_value,
       sql_plan_line_id id,
       sql_plan_operation|| ' '|| sql_plan_options row_src,
       nvl(event, 'CPU') event,
       count(1) * 10 tim
  from dba_hist_active_sess_history
 where sql_id = '&SQLID' and dbid=&DBID. and snap_id between &start_sn. and &end_sn.
 group by sql_plan_hash_value,
          sql_plan_line_id,
          sql_plan_operation,
          sql_plan_options,
          nvl(event, 'CPU')) x
 order by plan_hash_value, id;