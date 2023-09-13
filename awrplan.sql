spool awr_plan_&1..txt
select * from table(dbms_xplan.display_awr('&1.', null, null , 'ADVANCED'));
spool off