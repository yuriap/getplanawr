set long 1000000
SET LONGC 1024
--select dbms_sqltune.report_sql_monitor(sql_id=>'&1',report_level=>'ALL') from dual;


SELECT --report_id, key1 sql_id, key2 sql_exec_id, key3 sql_exec_start
       DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(RID => report_id, TYPE => 'text')
  FROM (select x.* from dba_hist_reports x
        WHERE component_name = 'sqlmonitor'
          and key1='&1' order by PERIOD_START_TIME desc)
where rownum<=10;