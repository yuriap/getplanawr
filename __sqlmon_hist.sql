declare
  procedure p(msg varchar2) is begin dbms_output.put_line(msg);end;
  procedure print_text_as_table(p_text clob) is
  l_line varchar2(32765);  l_eof number;  l_iter number := 1; 
  l_text clob := p_text||chr(10);
begin
  loop
    l_eof:=instr(l_text,chr(10));
    p(rtrim(rtrim(substr(l_text,1,l_eof),chr(13)),chr(10)));
    l_text:=substr(l_text,l_eof+1);  l_iter:=l_iter+1;
    exit when l_iter>1000000 or dbms_lob.getlength(l_text)=0;
  end loop;
end;
begin
  for i in (SELECT --report_id, key1 sql_id, key2 sql_exec_id, key3 sql_exec_start
       DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(RID => report_id, TYPE => 'text') x
  FROM (select x.* from dba_hist_reports x
        WHERE component_name = 'sqlmonitor'
          and key1='&1' order by PERIOD_START_TIME desc)
where rownum<=20) loop
    print_text_as_table(i.x);
    p('.');
  end loop;
end;