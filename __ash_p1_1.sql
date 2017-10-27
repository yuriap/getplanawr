select sql_plan_hash_value plan_hash_value,
       sql_plan_line_id id,
       sql_plan_operation|| ' '|| sql_plan_options row_src,
       nvl(event, 'CPU') event,
       count(1) * 10 tim,
       min(sample_time) start_tim,
       max(sample_time) end_tim
  from dba_hist_active_sess_history
 where sql_id = '&SQLID' and dbid=&DBID. and snap_id between &start_sn. and &end_sn.
 group by sql_plan_hash_value,
          sql_plan_line_id,
          sql_plan_operation,
          sql_plan_options,
          nvl(event, 'CPU')
 order by sql_plan_hash_value, sql_plan_line_id;