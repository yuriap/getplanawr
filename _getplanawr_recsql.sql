prompt Recursive SQL for DBID=&DBID
select sql_id, cnt*10 tot_time_sec
  from (select sql_id, count(1) cnt
          from dba_hist_active_sess_history
         where top_level_sql_id = '&SQLID'
		   and dbid=&DBID.
         group by sql_id
        --having count(1) > 10
         order by cnt desc)
where sql_id<>'&SQLID';
prompt ===============================================================================