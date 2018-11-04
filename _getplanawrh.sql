declare
  l_sql clob;
  l_plsql_output clob;
  l_sql_id varchar2(100):='~SQLID';
  l_crsr sys_refcursor;
  
@@__getplanawrh_sect

  l_css clob:=
q'{
@@awr.css
}';
--^'||q'^
  l_sqlstat clob:=
q'{
@@__sqlstat.sql
}';

--^'||q'^

  l_ash_summ clob := 
q'[
@@__ash_summ
]';

--^'||q'^

/*  l_ash_p1 clob := 
q'[
@@__ash_p1
]';
*/
--^'||q'^

  l_ash_p1_1 clob := 
q'[
@@__ash_p1_1
]';

--^'||q'^

  l_ash_p2 clob := 
q'[
@@__ash_p2
]';

--^'||q'^

  l_ash_p3 clob := 
q'[
@@__ash_p3
]';

--^'||q'^

  l_sqlmon_hist clob := 
q'[
@@__sqlmon_hist
]';

--^'||q'^

   l_time number;
   l_cpu_tim number;
   l_tot_time number:=0;
   l_tot_cpu_tim number:=0;   
   
   l_timing boolean := true;

@@__procs.sql

--^'||q'^

   procedure stim is
   begin
     if l_timing then
       l_time:=DBMS_UTILITY.GET_TIME;
       l_cpu_tim:=DBMS_UTILITY.GET_CPU_TIME;
     end if;
   end;
   procedure etim(p_final boolean default false, p_marker varchar2 default null) is
   begin
     if l_timing then
       l_time:=DBMS_UTILITY.GET_TIME-l_time;l_tot_time:=l_tot_time+l_time;
       l_cpu_tim:=DBMS_UTILITY.GET_CPU_TIME-l_cpu_tim;l_tot_cpu_tim:=l_tot_cpu_tim+l_cpu_tim;
       p(HTF.header (6,cheader=>case when p_marker is not null then p_marker ||': ' else null end || 'Elapsed (sec): '||to_char(round((l_time)/100,2))||'; CPU (sec): '||to_char(round((l_cpu_tim)/100,2)),cattributes=>'class="awr"'));
       if p_final then
         p(HTF.header (6,cheader=>'TOTAL: Elapsed (sec): '||to_char(round((l_tot_time)/100,2))||'; CPU (sec): '||to_char(round((l_tot_cpu_tim)/100,2)),cattributes=>'class="awr"'));
       end if;
     end if;
   end;

begin
   --select max(snap_id), min(snap_id) into g_max, g_min from dba_hist_snapshot where END_INTERVAL_TIME>sysdate-3;
   
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
   
   if l_sect_sql_text or l_sect_db_desc or l_sect_sql_stat or l_sect_binds then p(HTF.header (4,cheader=>'Statistics',cattributes=>'class="awr"')); end if;
   
   if l_sect_sql_text  then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#sql_text',ctext=>'SQL text',cattributes=>'class="awr"'))); end if;
   if l_sect_db_desc   then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#db_desc',ctext=>'DB description',cattributes=>'class="awr"'))); end if;
   if l_sect_sql_stat  then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#sql_stat',ctext=>'SQL statistics',cattributes=>'class="awr"'))); end if;
   if l_sect_binds     then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#binds',ctext=>'Bind values',cattributes=>'class="awr"'))); end if;
   
   if l_sect_awr_plans or l_sect_plan_comp or l_sect_explain then p(HTF.header (4,cheader=>'Explain plan',cattributes=>'class="awr"')); end if; 
   
   if l_sect_awr_plans then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplans',ctext=>'AWR SQL execution plans',cattributes=>'class="awr"'))); end if;
   if l_sect_plan_comp then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplanscomp',ctext=>'AWR SQL plans comparison',cattributes=>'class="awr"'))); end if;
   if l_sect_explain   then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Explain plan',cattributes=>'class="awr"'))); end if;
   
   if l_sect_plsql or l_sect_ash_summ or l_sect_ash_p1 or l_sect_ash_p2 or l_sect_ash_p3 then p(HTF.header (4,cheader=>'ASH',cattributes=>'class="awr"')); end if;   
   if l_sect_plsql or l_sect_ash_summ or l_sect_ash_p1 or l_sect_ash_p2 or l_sect_ash_p3 then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'ASH',cattributes=>'class="awr"'))); end if;
   
   if l_sect_plsql     then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_plsql',ctext=>'PL/SQL',cattributes=>'class="awr"'))); end if;
   if l_sect_ash_summ  then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_summ',ctext=>'ASH summary',cattributes=>'class="awr"')));  end if;  
   if l_sect_ash_p1    then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p1',ctext=>'AWR ASH (SQL Monitor) P1',cattributes=>'class="awr"'))); end if;
   if l_sect_ash_p2    then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p2',ctext=>'AWR ASH (SQL Monitor) P2',cattributes=>'class="awr"'))); end if;
   if l_sect_ash_p3    then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p3',ctext=>'AWR ASH (SQL Monitor) P3',cattributes=>'class="awr"'))); end if;
   
   if l_sect_sql_mon_hst then p(HTF.header (4,cheader=>'SQL Monitor',cattributes=>'class="awr"')); end if;    
   
   if l_sect_sql_mon_hst then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#sql_mon_hist',ctext=>'SQL Monitor report history',cattributes=>'class="awr"'))); end if;
   p(HTF.BR);
   p(HTF.BR); 
   
--^'||q'^

   --SQL TEXT
   if l_sect_sql_text  then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'SQL text',cname=>'sql_text',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       l_sql:=q'[select x.sql_text text from dba_hist_sqltext x where sql_id=']'||l_sql_id||q'[' and rownum=1]'||chr(10);
       open l_crsr for l_sql;
       fetch l_crsr into l_plsql_output;
       if l_crsr%found then
         print_text_as_table(p_text=>l_plsql_output,p_t_header=>'SQL text',p_width=>1000);
       else
         print_text_as_table(p_text=>'No SQL data found.',p_t_header=>'SQL text',p_width=>500);
       end if;   
       close l_crsr;
       etim();
       p(HTF.BR);
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
       p(HTF.BR);
       p(HTF.BR);  
   end if;
   
   --DB description
   if l_sect_db_desc   then 
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'DB description',cname=>'db_desc',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       l_sql:=q'[select unique INSTANCE_NUMBER INST_ID, DB_NAME,dbid,version,host_name,platform_name from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=']'||l_sql_id||q'[')]'||chr(10);
       prepare_script(l_sql,l_sql_id);
       print_table_html(l_sql,1000,'DB description');
       etim();
       p(HTF.BR);
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
       p(HTF.BR);
       p(HTF.BR);     
   end if;
--^'||q'^   

   --SQL statistics
   if l_sect_sql_stat  then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'SQL statistics',cname=>'sql_stat',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       p('POE - per one exec, time in milliseconds (1/1000 of second)');
       p(HTF.BR);
       for i in (select unique dbid,INSTANCE_NUMBER from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1,2)
       loop
         p('DBID: '||i.dbid||'; INST_ID: '||i.INSTANCE_NUMBER);
         l_sql:=l_sqlstat;
         prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid,p_inst_id=>i.INSTANCE_NUMBER); 
         print_table_html(l_sql,1000,'SQL statistics',p_style1 =>'awrncbbt',p_style2 =>'awrcbbt',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'),p_header=>50);

         p(HTF.BR);
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
         p(HTF.BR);
       end loop;
       etim();
       p(HTF.BR);
       p(HTF.BR);
   end if;
   
   --Bind values
   if l_sect_binds     then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Bind values',cname=>'binds',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       l_sql:=q'[select snap_id snap, name, datatype_string,to_char(last_captured,'yyyy/mm/dd hh24:mi:ss') last_captured, value_string from dba_hist_sqlbind where sql_id=']'||l_sql_id||q'[' order by snap_id,position;]'||chr(10);
       prepare_script(l_sql,l_sql_id);
       print_table_html(l_sql,1000,'Bind values',p_header=>50);
       etim();
       p(HTF.BR);
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
       p(HTF.BR);
       p(HTF.BR);   
   end if;
--^'||q'^   
   
   --AWR SQL execution plans
   if l_sect_awr_plans or l_sect_plan_comp or l_sect_explain then
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR SQL execution plans',cname=>'awrplans',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
   end if;
   
   if l_sect_plan_comp then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplanscomp',ctext=>'AWR SQL plans comparison',cattributes=>'class="awr"'))); end if;
   if l_sect_explain   then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Explain plan',cattributes=>'class="awr"'))); end if;

   if l_sect_awr_plans then    
       stim();
       p(HTF.BR);   
       for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
       loop
         p('DBID: '||i.dbid);
         l_sql:=q'[select * from table(dbms_xplan.display_awr(']'||l_sql_id||q'[', null, ]'||i.dbid||q'[, 'ADVANCED'))]'||chr(10);
         prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid);
         print_table_html(l_sql,1000,'AWR SQL execution plans','Plan hash value: ([[:digit:]]*)',HTF.ANCHOR(curl=>'#epplan_\1',ctext=>'Plan hash value: \1',cname=>'awrplan_\1',cattributes=>'class="awr"'));
         p(HTF.BR);
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplans',ctext=>'Back to AWR SQL execution plans',cattributes=>'class="awr"')));
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
         p(HTF.BR);
       end loop;
       etim();
       p(HTF.BR);
       p(HTF.BR);
   end if;
   
   --Comparsion
   if l_sect_plan_comp then
       p(HTF.BR);
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR SQL plans comparison',cname=>'awrplanscomp',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);   
       stim();   

       for c in (select dbid, sql_id, min(snap_id) mi, max(snap_id) ma, count(unique plan_hash_value) cnt 
                   from dba_hist_sqlstat 
                  where plan_hash_value<>0 
                    and CPU_TIME_DELTA+ELAPSED_TIME_DELTA+BUFFER_GETS_DELTA+EXECUTIONS_DELTA>0 
                    and sql_id=l_sql_id             
                  group by dbid, sql_id
                 having count(unique plan_hash_value)>1)
       loop

         execute immediate    
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(
            replace(:l_awrcomp
                             ,'!dblnk.','')
                             ,'!dbid1.',to_char(c.dbid))
                             ,'!start_snap1.',to_char(c.mi-1))
                             ,'!end_snap1.',to_char(c.ma))
                             ,'!dbid2.',to_char(c.dbid))
                             ,'!start_snap2.',to_char(c.mi-1))
                             ,'!end_snap2.',to_char(c.ma))
                             ,'!filter.',q'[sql_id=']'||l_sql_id||q'[']')
                             ,'!sortcol.','ELAPSED_TIME_DELTA')
                             ,'!sortlimit.','1')
                             ,'!embeded.','TRUE');
       end loop;
       etim();   
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplans',ctext=>'Back to AWR SQL execution plans',cattributes=>'class="awr"')));
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
       p(HTF.BR);   
       p(HTF.BR);   
   end if;
   
   --Explain plan
   if l_sect_explain   then
       stim();
       p(HTF.BR);
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Explain plan',cname=>'epplan',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ep_simple',ctext=>'Explain plan (simple)',cattributes=>'class="awr"')));
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ep_adv',ctext=>'Explain plan (advanced)',cattributes=>'class="awr"')));

       p(HTF.BR);p(HTF.BR);
       
       begin
         select x.sql_text into l_sql from dba_hist_sqltext x where sql_id=l_sql_id and rownum=1;
         delete from plan_table;
         execute immediate 'explain plan for '||chr(10)||l_sql;
       exception
         when others then p(sqlerrm);
       end;
       
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Explain plan (simple)',cname=>'ep_simple',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       l_sql:=q'[select * from table(dbms_xplan.display());]'||chr(10);
       prepare_script(l_sql,l_sql_id);
       print_table_html(l_sql,1000,'Explain plan','Plan hash value: ([[:digit:]]*)',HTF.ANCHOR(curl=>'#epplanadv_\1',ctext=>'Plan hash value: \1',cname=>'epplan_\1',cattributes=>'class="awr"'));
       p(HTF.BR);p(HTF.BR);
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Back to Explain plan',cattributes=>'class="awr"')));
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplans',ctext=>'Back to AWR SQL execution plans',cattributes=>'class="awr"')));
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
       p(HTF.BR);p(HTF.BR);
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'Explain plan (advanced)',cname=>'ep_adv',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       l_sql:=q'[select * from table(dbms_xplan.display(null,null,'ADVANCED',null));]'||chr(10);
       prepare_script(l_sql,l_sql_id);
       print_table_html(l_sql,1000,'Explain plan','Plan hash value: ([[:digit:]]*)',HTF.ANCHOR(curl=>'',ctext=>'Plan hash value: \1',cname=>'epplanadv_\1',cattributes=>'class="awr"'));
       etim();
       p(HTF.BR);p(HTF.BR);
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#epplan',ctext=>'Back to Explain plan',cattributes=>'class="awr"')));
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#awrplans',ctext=>'Back to AWR SQL execution plans',cattributes=>'class="awr"')));
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
       p(HTF.BR);   
       p(HTF.BR);
       rollback;
   end if;
--^'||q'^   
   
   if l_sect_plsql or l_sect_ash_summ or l_sect_ash_p1 or l_sect_ash_p2 or l_sect_ash_p3 then 
     p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'ASH',cname=>'ash',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
     p(HTF.BR);
   end if;
   if l_sect_plsql     then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_plsql',ctext=>'PL/SQL',cattributes=>'class="awr"')));end if;
   if l_sect_ash_summ  then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_summ',ctext=>'ASH summary',cattributes=>'class="awr"')));end if;
   if l_sect_ash_p1    then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p1',ctext=>'AWR ASH (SQL Monitor) P1',cattributes=>'class="awr"')));end if;
   if l_sect_ash_p2    then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p2',ctext=>'AWR ASH (SQL Monitor) P2',cattributes=>'class="awr"')));end if;
   if l_sect_ash_p3    then p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash_p3',ctext=>'AWR ASH (SQL Monitor) P3',cattributes=>'class="awr"')));end if;
   p(HTF.BR);p(HTF.BR);
   
--   stim();
   --ASH for a week worth only
--   declare
--     l_mt date;
--   begin
--     select max(snap_id), max(sample_time)-8 into g_max, l_mt from dba_hist_active_sess_history where sql_id=l_sql_id;
--     select min(snap_id) into g_min from dba_hist_active_sess_history where sample_time>=l_mt and sql_id=l_sql_id;
--   end;
--   etim(p_marker=>'ASH range calc');
   
   --ASH PL/SQL
   if l_sect_plsql     then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'ASH PL/SQL',cname=>'ash_plsql',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
       loop
         p('DBID: '||i.dbid);
         if sys_context('USERENV','CON_ID')=0 then --in multitenant it runs forever
           l_sql:=q'[select * from dba_procedures where (object_id,subprogram_id) in (select unique plsql_entry_object_id,plsql_entry_subprogram_id from dba_hist_active_sess_history where instance_number between 1 and 255 and snap_id between &start_sn. and &end_sn. and sql_id = ']'||l_sql_id||q'[' and dbid= ]'||i.dbid||q'[)]'||chr(10);
           prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
           print_table_html(l_sql,1500,'ASH PL/SQL',p_style1 =>'awrc1',p_style2 =>'awrnc1');
         else
           p('No PL/SQL source data for multitenant DB.');
         end if;

         p(HTF.BR);
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
         p(HTF.BR);
       end loop;
       etim();
       p(HTF.BR);
       p(HTF.BR);     
   end if;
--^'||q'^   

   --ASH summary
   if l_sect_ash_summ  then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'ASH summary',cname=>'ash_summ',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
       loop
         p('DBID: '||i.dbid);
         l_sql:=l_ash_summ;
         prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
         print_table_html(l_sql,1500,'ASH summary',p_style1 =>'awrncbbt',p_style2 =>'awrcbbt',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'),p_header=>50);

         p(HTF.BR);
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
         p(HTF.BR);
       end loop;
       etim();
       p(HTF.BR);
       p(HTF.BR);   
   end if;
--^'||q'^   

   --AWR ASH (SQL Monitor) P1
   if l_sect_ash_p1    then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR ASH (SQL Monitor) P1',cname=>'ash_p1',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       p('AWR ASH totals by PLAN_HASH and PLAN STEP ID');
       p(HTF.BR);
       for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
       loop
         p('DBID: '||i.dbid);
         l_sql:=l_ash_p1_1;
         prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
         print_table_html(l_sql,1500,'AWR ASH (SQL Monitor) P1',p_style1 =>'awrncbbt',p_style2 =>'awrcbbt',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'),p_header=>50,p_break_col=>'ID');

         p(HTF.BR);
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
         p(HTF.BR);
       end loop;
       etim();
       p(HTF.BR);
       p(HTF.BR);
   end if;
   
   --AWR ASH (SQL Monitor) P2
   if l_sect_ash_p2    then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR ASH (SQL Monitor) P2',cname=>'ash_p2',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       p('AWR ASH totals by EXEC START DATE and PLAN STEP ID');
       p(HTF.BR);
       for i in (select unique dbid from dba_hist_database_instance where dbid in (select dbid from dba_hist_sqltext where sql_id=l_sql_id) order by 1)
       loop
         p('DBID: '||i.dbid);
         l_sql:=l_ash_p2;
         prepare_script(l_sql,l_sql_id,p_dbid=>i.dbid); 
         print_table_html(l_sql,1500,'AWR ASH (SQL Monitor) P2',p_style1 =>'awrncbbt',p_style2 =>'awrcbbt',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'),p_header=>50,p_break_col=>'SQL_EXEC_START');

         p(HTF.BR);
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
         p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
         p(HTF.BR);
       end loop;
       etim();
       p(HTF.BR);
       p(HTF.BR);
   end if;
--^'||q'^

   --AWR ASH (SQL Monitor) P3
   if l_sect_ash_p1    then
       stim();
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'AWR ASH (SQL Monitor) P3',cname=>'ash_p3',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       p('V$ASH totals by EXEC START DATE and PLAN STEP ID');
       p(HTF.BR);
       l_sql:=l_ash_p3;
       prepare_script(l_sql,l_sql_id); 
       print_table_html(l_sql,1500,'AWR ASH (SQL Monitor) P3',p_style1 =>'awrncbbt',p_style2 =>'awrcbbt',p_search=>'PLAN_HASH',p_replacement=>HTF.ANCHOR (curl=>'#awrplan_\1',ctext=>'\1',cattributes=>'class="awr"'),p_header=>50,p_break_col=>'SQL_EXEC_START');

       p(HTF.BR);
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#ash',ctext=>'Back to ASH',cattributes=>'class="awr"')));
       p(HTF.LISTITEM(cattributes=>'class="awr"',ctext=>HTF.ANCHOR (curl=>'#tblofcont',ctext=>'Back to top',cattributes=>'class="awr"')));
       p(HTF.BR);
       etim();
       p(HTF.BR);
       p(HTF.BR);   
   end if;
   
   --SQL Monitor report history
   stim();
   if l_sect_sql_mon_hst then 
       p(HTF.header (3,cheader=>HTF.ANCHOR (curl=>'',ctext=>'SQL Monitor report history (12c+)',cname=>'sql_mon_hist',cattributes=>'class="awr"'),cattributes=>'class="awr"'));
       p(HTF.BR);
       prepare_script(l_sqlmon_hist,'~SQLID',true);
       l_sqlmon_hist:=replace(l_sqlmon_hist,'procedure p(msg varchar2) is begin dbms_output.put_line(msg);end;','procedure p(msg varchar2) is begin :l_res:=:l_res||msg||chr(10);end;');
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
   end if;
   etim(true);
   p(HTF.BR);
   p((HTF.BODYCLOSE));
   p((HTF.HTMLCLOSE));
end;