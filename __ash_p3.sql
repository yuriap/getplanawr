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