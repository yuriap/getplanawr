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
  if nvl('&start_sn.','0')<>'0' and nvl('&end_sn.','0')<>'0' then
    for i in (SELECT DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(RID => report_id, TYPE => 'text') x
                FROM (with dts as (select min(begin_interval_time) btim, max(end_interval_time) etim from dba_hist_snapshot where snap_id between to_number('&start_sn.') and to_number('&end_sn.'))
                      select x.* from dba_hist_reports x, dts
                       WHERE component_name = 'sqlmonitor' 
                         and period_start_time >= dts.btim and period_end_time <= dts.etim
                         and key1='&1' order by PERIOD_START_TIME desc)
               where rownum<=30) loop
      print_text_as_table(i.x);
      p('.');
    end loop;  
  else
    for i in (SELECT DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(RID => report_id, TYPE => 'text') x
                FROM (select x.* from dba_hist_reports x
                       WHERE component_name = 'sqlmonitor'
                         and key1='&1' order by PERIOD_START_TIME desc)
               where rownum<=30) loop
      print_text_as_table(i.x);
      p('.');
    end loop;
  end if;
end;