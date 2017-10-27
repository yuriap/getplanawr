select INSTANCE_NUMBER INST, sql_id,
       top_level_sql_id,
       sql_plan_hash_value plan_hash,
       force_matching_signature force_matching_sign,
       sql_exec_id,
       to_char(sql_exec_start,'YYYY/MON/DD Hh24:mi:ss') sql_exec_start,
       to_char(min(sample_time),'YYYY/MON/DD Hh24:mi:ss')  start_tim,
       to_char(max(sample_time),'YYYY/MON/DD Hh24:mi:ss')  end_tim,
       plsql_entry_object_id plsql_entry,
       plsql_entry_subprogram_id plsql_subprog,
       program,
       machine,
       ecid,module,action,client_id, user_id
  from dba_hist_active_sess_history
 where sql_id = '&SQLID' and dbid=&DBID. and snap_id between &start_sn. and &end_sn.
 group by INSTANCE_NUMBER,sql_id,
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
order by sql_exec_start,INSTANCE_NUMBER;
