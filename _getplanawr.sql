set verify off
set termout off
set trimspool on
set timing off


alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';
alter session set nls_timestamp_format='yyyy/mm/dd hh24:mi:ss.ff3';

define SQLID=&1
--define dbid=2
--column a new_val dbid noprint
--select dbid a from dba_hist_sqltext where sql_id='&SQLID.' and rownum=1;

column misn new_val start_sn noprint
column masn new_val end_sn noprint
select min(snap_id) misn, 
       max(snap_id) masn 
 from dba_hist_sqlstat where sql_id='&SQLID.' and dbid=(select dbid from dba_hist_sqltext where sql_id='&SQLID.');

select 
       case when trim('&start_sn.') is null 
              then 
                (select min(snap_id) from dba_hist_snapshot
                 where trunc(begin_interval_time, 'mi') >=(select trunc(max(end_interval_time) - 8, 'mi')
                                                             from dba_hist_snapshot
                                                            where instance_number = 1)
                   and instance_number = 1) 
			  else to_number('&start_sn.') end misn,
       case when trim('&end_sn.') is null 
              then (select max(snap_id) from dba_hist_snapshot where dbid=(select dbid from dba_hist_sqltext where sql_id='&SQLID.'))
			  else to_number('&end_sn.') end masn
from dual;

column sn new_val c_start_sn noprint
select case when &end_sn. < min(snap_id) then min(snap_id) else &end_sn. end sn
  from dba_hist_snapshot
 where trunc(begin_interval_time, 'mi') >=
       (select trunc(end_interval_time - 8, 'mi')
          from dba_hist_snapshot
         where snap_id = &start_sn.
           and instance_number = 1)
   and instance_number = 1;

set serveroutput on
set feedback off
spool _tmp_sqlstat.sql
begin
  for i in (select dbid from dba_hist_sqltext where sql_id='&SQLID.')
  loop
    dbms_output.put_line('define DBID='||i.dbid);
    dbms_output.put_line('@_getplanawr_sqlstat');
  end loop;
end;
/
spool off

spool _tmp_sqlpln.sql
begin
  for i in (select dbid from dba_hist_sqltext where sql_id='&SQLID.')
  loop
    dbms_output.put_line('select * from table(dbms_xplan.display_awr(''&SQLID'', null, '''||i.dbid||''', ''ADVANCED''));');
  end loop;
end;
/
spool off

spool _tmp_awrash.sql
begin
  for i in (select dbid from dba_hist_sqltext where sql_id='&SQLID.')
  loop
    dbms_output.put_line('define DBID='||i.dbid);
    dbms_output.put_line('@_getplanawr_ash');
  end loop;
end;
/
spool off

spool _tmp_rec1.sql
begin
  for i in (select dbid from dba_hist_sqltext where sql_id='&SQLID.')
  loop
    dbms_output.put_line('define DBID='||i.dbid);
    dbms_output.put_line('@_getplanawr_recsql');
  end loop;
end;
/
spool off

set serveroutput off

set feedback off
set heading off
set long 5000000
column text format a1000 word_wrap

spool _tmp_awr_sql.txt
select x.sql_text text from dba_hist_sqltext x where sql_id='&SQLID' and rownum=1;
spool off

set heading on
rem set timing on

define o_start_sn=&start_sn.

spool awr_&SQLID..txt
prompt SQL_ID=&SQLID
select x.sql_text text from dba_hist_sqltext x where sql_id='&SQLID' and rownum=1;
prompt ===============================================================================
select unique DB_NAME, dbid,version,host_name,platform_name from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id='&SQLID');
prompt ===============================================================================
prompt Snapshot range: start - &start_sn. (corrected &c_start_sn.); end - &end_sn.
prompt ===============================================================================
Prompt POE - per one exec, time in milliseconds (1/1000 of second)
prompt ===============================================================================
@_tmp_sqlstat.sql
host del _tmp_sqlstat.sql

spool awr_&SQLID..txt append

prompt Bind values
column value_string format a200
column NAME format a30
set feedback on
select snap_id snap, name, datatype_string,to_char(last_captured,'yyyy/mm/dd hh24:mi:ss') last_captured, value_string from dba_hist_sqlbind where sql_id='&SQLID' order by snap_id,position;
set feedback off
set pages 9999

--select * from table(dbms_xplan.display_awr('&SQLID', null, '&dbid', 'ADVANCED'));
@_tmp_sqlpln.sql
host del _tmp_sqlpln.sql

rem prompt ====== Comparison ==========================================================
rem set termout on
rem prompt SQLID=&SQLID.
rem prompt dbid1=&dbid1.
rem prompt snaps1=&snaps1.
rem prompt dbid2=&dbid2.
rem prompt snaps2=&snaps2.
rem 
rem @getplanawr_plancomp
rem set termout off
prompt ====== Explain Plan For ====================================================

SET SQLBL ON
delete from plan_table;
set echo on
set define off
SET SQLBL ON
explain plan for
@_tmp_awr_sql.txt
/
set pages 9999
set echo off
select * from table(dbms_xplan.display());

rollback;

host del _tmp_awr_sql.txt

set define on

spool awr_&SQLID..txt append
define start_sn=&c_start_sn.

SET SQLBL OFF

@_tmp_awrash.sql
host del _tmp_awrash.sql

spool awr_&SQLID..txt append

@_tmp_rec1.sql
host del _tmp_rec1.sql

spool awr_&SQLID..txt append

prompt ===================================== SQL MONITOR Hist(12c+) ====================================
define start_sn=&o_start_sn.
set serveroutput on
@__sqlmon_hist &SQLID.
/
set serveroutput off

prompt ===============================================================================
spool off

set heading off
set echo off
set verify off
set timing off
set feedback off

spool _tmp_awr_rec_sql_&SQLID..sql
select 'host mkdir awr_&SQLID._recursive_sqls'||chr(10)||'@getplanawr ' ||sql_id||chr(10)||'host move awr_'||sql_id||'.txt .\awr_&SQLID._recursive_sqls'
  from (select sql_id, count(1) cnt
          from dba_hist_active_sess_history
         where top_level_sql_id = '&SQLID'
         group by sql_id
        having count(1) >= 6
         order by cnt desc)
where sql_id<>'&SQLID';

prompt define SQLID=&SQLID

spool off

@_tmp_awr_rec_sql_&SQLID..sql

host del _tmp_awr_rec_sql_&SQLID..sql


undefine SQLID
undefine DBID
undefine start_sn
undefine c_start_sn
undefine end_sn

SET SQLBL OFF
set termout on
set verify on
set feedback on
