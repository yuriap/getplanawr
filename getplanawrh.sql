set pages 9999
set lines 2000
set trimspool on
set termout off
set echo off
set feedback off
set verify off

define SQLID=&1.

set timing off

set define off
variable l_awrcomp clob
declare
  l_script clob := 
q'^
@@_getcomph.sql
^';
begin
  :l_awrcomp := replace(l_script||l_script1,'~','!');
end;
/

set define ~

set serveroutput on

spool awr_~SQLID..html

@@_getplanawrh
/

spool off
set serveroutput off

set heading off
set echo off
set verify off
set timing off
set feedback off

set define &   

spool _tmp_awr_rec_sql_&SQLID..sql
select 'host mkdir awr_&SQLID._recursive_sqls'||chr(10)||'@getplanawrh ' ||sql_id||chr(10)||'host move awr_'||sql_id||'.html .\awr_&SQLID._recursive_sqls'
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

SET SQLBL OFF
set termout on
set verify on
set feedback on
