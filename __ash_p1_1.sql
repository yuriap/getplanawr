select
  x.*,
  round(100 * tim / sum(tim) over(), 2) tim_pct,
  round(100 * sum(tim) over(partition by id) / sum(tim) over(), 2) tim_id_pct
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