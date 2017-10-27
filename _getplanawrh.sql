declare

  l_sql clob;
  l_plsql_output clob;
  l_sql_id varchar2(100):='~SQLID';
  
  l_css clob:=
q'{
@@awr.css
}';

  l_sqlstat clob:=
q'{
@@__sqlstat.sql
}';

  l_ash_summ clob := 
q'[
@@__ash_summ
]';

  l_ash_p1 clob := 
q'[
@@__ash_p1
]';

  l_ash_p1_1 clob := 
q'[
@@__ash_p1_1
]';

  l_ash_p2 clob := 
q'[
@@__ash_p2
]';

  l_ash_p3 clob := 
q'[
@@__ash_p3
]';

  l_sqlmon_hist clob := 
q'[
@@__sqlmon_hist
]';

@@__procs.sql

begin
   p(HTF.HTMLOPEN);
   p(HTF.HEADOPEN);
   p(HTF.TITLE(l_sql_id));   

   p('<style type="text/css">');
   p(l_css);
   p('</style>');
   p(HTF.HEADCLOSE);
   p(HTF.BODYOPEN(cattributes=>'class="awr"'));
   
   p(HTF.header (1,'AWR SQL Report for SQL_ID='||l_sql_id,cattributes=>'class="awr"'));
   p(HTF.BR);
   p(HTF.BR);
   p(HTF.header (2,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Table of contents',cname=>'tblofcont',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
p(HTF.header (4,cheader=>'Statistics',cattributes=>'class="awr"'));      
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#sql_text',ctext=>'SQL text',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#db_desc',ctext=>'DB description',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#sql_stat',ctext=>'SQL statistics',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#binds',ctext=>'Bind values',cattributes=>'class="awr"')));
p(HTF.header (4,cheader=>'Explain plan',cattributes=>'class="awr"'));   
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplans',ctext=>'AWR SQL execution plans',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Explain plan',cattributes=>'class="awr"')));
p(HTF.header (4,cheader=>'ASH',cattributes=>'class="awr"'));      
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'ASH',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_plsql',ctext=>'PL/SQL',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_summ',ctext=>'ASH summary',cattributes=>'class="awr"')));   
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p1',ctext=>'AWR ASH (SQL Monitor) P1',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p1.1',ctext=>'AWR ASH (SQL Monitor) P1.1',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p2',ctext=>'AWR ASH (SQL Monitor) P2',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p3',ctext=>'AWR ASH (SQL Monitor) P3',cattributes=>'class="awr"')));
p(HTF.header (4,cheader=>'SQL Monitor',cattributes=>'class="awr"'));      
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#sql_mon_hist',ctext=>'SQL Monitor report history',cattributes=>'class="awr"')));
   p(HTF.BR);
   p(HTF.BR); 

   --SQL TEXT
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'SQL text',cname=>'sql_text',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   l_sql:=q'[select x.sql_text text from dba_hist_sqltext x where sql_id=']'||l_sql_id||q'[' and rownum=1]'||chr(10);
   prepare_script(l_sql,l_sql_id);
   print_table_html(l_sql,1000,'Full sql text');
   p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
   p(HTF.BR);
   p(HTF.BR);  

   --DB description
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'DB description',cname=>'db_desc',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   l_sql:=q'[select unique DB_NAME,dbid,version,host_name,platform_name from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=']'||l_sql_id||q'[')]'||chr(10);
   prepare_script(l_sql,l_sql_id);
   print_table_html(l_sql,1000,'DB description');
   p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
   p(HTF.BR);
   p(HTF.BR);     
   
   --SQL statistics
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'SQL statistics',cname=>'sql_stat',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   p('POE - per one exec, time in milliseconds (1/1000 of second)');
   p(HTF.BR);
   for i in (select unique dbid,INSTANCE_NUMBER from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1,2)
   loop
     p('DBID: '||i.dbid||'; INST_ID: '||i.INSTANCE_NUMBER);
     l_sql:=l_sqlstat;
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid,p_inst_id=>i.INSTANCE_NUMBER); 
     print_table_html(l_sql,1000,'SQL statistics',p_style1 =>'awrc2',p_style2 =>'awrnc2',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'));

     p(HTF.BR);
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);
   
   
   --Bind values
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Bind values',cname=>'binds',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   l_sql:=q'[select snap_id snap, name, datatype_string,to_char(last_captured,'yyyy/mm/dd hh24:mi:ss') last_captured, value_string from dba_hist_sqlbind where sql_id=']'||l_sql_id||q'[' order by snap_id,position;]'||chr(10);
   prepare_script(l_sql,l_sql_id);
   print_table_html(l_sql,1000,'Bind values');
   p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
   p(HTF.BR);
   p(HTF.BR);   
   
   
   
   --AWR SQL execution plans
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR SQL execution plans',cname=>'awrplans',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Explain plan',cattributes=>'class="awr"')));
   p(HTF.BR);   p(HTF.BR);   
   for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
   loop
     p('DBID: '||i.dbid);
     l_sql:=q'[select * from table(dbms_xplan.display_awr(']'||l_sql_id||q'[', null, ]'||i.dbid||q'[, 'ADVANCED'))]'||chr(10);
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid);
     print_table_html(l_sql,1000,'AWR SQL execution plans','Plan hash value: ([[:digit:]]*)',HTF.ANCHOR(curl=>'#epplan_\1',ctext=>'Plan hash value: \1',cname=>'awrplan_\1',cattributes=>'class="awr"'));
     p(HTF.BR);
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);
   
   
   --Explain plan
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Explain plan',cname=>'epplan',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ep_simple',ctext=>'Explain plan (simple)',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ep_adv',ctext=>'Explain plan (advanced)',cattributes=>'class="awr"')));

   p(HTF.BR);p(HTF.BR);
   
   select x.sql_text into l_sql from dba_hist_sqltext x where sql_id=l_sql_id and rownum=1;
   delete from plan_table;
   execute immediate 'explain plan for '||chr(10)||l_sql;
   
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Explain plan (simple)',cname=>'ep_simple',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   l_sql:=q'[select * from table(dbms_xplan.display());]'||chr(10);
   prepare_script(l_sql,l_sql_id);
   print_table_html(l_sql,1000,'Explain plan','Plan hash value: ([[:digit:]]*)',HTF.ANCHOR(curl=>'#epplanadv_\1',ctext=>'Plan hash value: \1',cname=>'epplan_\1',cattributes=>'class="awr"'));
   p(HTF.BR);p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Back to Explain plan',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
   p(HTF.BR);p(HTF.BR);
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Explain plan (advanced)',cname=>'ep_adv',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   l_sql:=q'[select * from table(dbms_xplan.display(null,null,'ADVANCED',null));]'||chr(10);
   prepare_script(l_sql,l_sql_id);
   print_table_html(l_sql,1000,'Explain plan','Plan hash value: ([[:digit:]]*)',HTF.ANCHOR(curl=>'',ctext=>'Plan hash value: \1',cname=>'epplanadv_\1',cattributes=>'class="awr"'));
   p(HTF.BR);p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Back to Explain plan',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
   p(HTF.BR);   
   p(HTF.BR);
   rollback;
   
   
   
   
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'ASH',cname=>'ash',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_plsql',ctext=>'PL/SQL',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_summ',ctext=>'ASH summary',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p1',ctext=>'AWR ASH (SQL Monitor) P1',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p1.1',ctext=>'AWR ASH (SQL Monitor) P1.1',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p2',ctext=>'AWR ASH (SQL Monitor) P2',cattributes=>'class="awr"')));
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p3',ctext=>'AWR ASH (SQL Monitor) P3',cattributes=>'class="awr"')));
   p(HTF.BR);p(HTF.BR);
   --ASH PL/SQL
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'ASH PL/SQL',cname=>'ash_plsql',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
   loop
     p('DBID: '||i.dbid);
     l_sql:=q'[select * from dba_procedures where (object_id,subprogram_id) in (select unique plsql_entry_object_id,plsql_entry_subprogram_id from dba_hist_active_sess_history where snap_id between &start_sn. and &end_sn. and sql_id = ']'||l_sql_id||q'[' and dbid= ]'||i.dbid||q'[)]'||chr(10);
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
     print_table_html(l_sql,1500,'ASH PL/SQL',p_style1 =>'awrc1',p_style2 =>'awrnc1');

     p(HTF.BR);
	 p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);      
   
   --ASH summary
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'ASH summary',cname=>'ash_summ',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
   loop
     p('DBID: '||i.dbid);
     l_sql:=l_ash_summ;
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
     print_table_html(l_sql,1500,'ASH summary',p_style1 =>'awrc2',p_style2 =>'awrnc2',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'));

     p(HTF.BR);
	 p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);   
   
   
   --AWR ASH (SQL Monitor) P1
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR ASH (SQL Monitor) P1',cname=>'ash_p1',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
   loop
     p('DBID: '||i.dbid);
     l_sql:=l_ash_p1;
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
     print_table_html(l_sql,1000,'AWR ASH (SQL Monitor) P1',p_style1 =>'awrc1',p_style2 =>'awrnc1',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'));

     p(HTF.BR);
	 p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);  
   
   --AWR ASH (SQL Monitor) P1.1
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR ASH (SQL Monitor) P1.1',cname=>'ash_p1.1',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
   loop
     p('DBID: '||i.dbid);
     l_sql:=l_ash_p1_1;
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
     print_table_html(l_sql,1000,'AWR ASH (SQL Monitor) P1.1',p_style1 =>'awrc1',p_style2 =>'awrnc1',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'));

     p(HTF.BR);
	 p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);

   --AWR ASH (SQL Monitor) P2
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR ASH (SQL Monitor) P2',cname=>'ash_p2',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
   loop
     p('DBID: '||i.dbid);
     l_sql:=l_ash_p2;
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
     print_table_html(l_sql,1000,'AWR ASH (SQL Monitor) P2',p_style1 =>'awrc1',p_style2 =>'awrnc1',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'));

     p(HTF.BR);
	 p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);

   --AWR ASH (SQL Monitor) P3
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR ASH (SQL Monitor) P3',cname=>'ash_p3',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
   loop
     p('DBID: '||i.dbid);
     l_sql:=l_ash_p3;
     prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
     print_table_html(l_sql,1000,'AWR ASH (SQL Monitor) P3',p_style1 =>'awrc1',p_style2 =>'awrnc1',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'));

     p(HTF.BR);
     p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
     p(HTF.BR);
   end loop;
   p(HTF.BR);
   p(HTF.BR);   
   
   --SQL Monitor report history
   p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'SQL Monitor report history (12c+)',cname=>'sql_mon_hist',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
   p(HTF.BR);
   prepare_script(l_sqlmon_hist,'~SQLID',true);
   l_sqlmon_hist:=replace(l_sqlmon_hist,'procedure p(msg varchar2) is begin dbms_output.put_line(msg);end;','procedure p(msg varchar2) is begin :l_res:=:l_res||msg||chr(10);end;');
   --p(l_sqlmon1);
   l_plsql_output:=null;
   begin
     execute immediate l_sqlmon_hist using in out l_plsql_output;
   exception
     when others then l_plsql_output:=sqlerrm;
   end;
   print_text_as_table(p_text=>l_plsql_output||chr(10),p_t_header=>'SQL Monitor report history',p_width=>600,p_search=>'Plan Hash Value=([[:digit:]]*)',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'Plan Hash Value=\1',cattributes=>'class="awr"'));
   p(HTF.BR);   
   p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));   
   
   p(HTF.BR);
   p(HTF.BR);
   p((HTF.BODYCLOSE));
   p((HTF.HTMLCLOSE));
end;
/

