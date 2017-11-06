SQL execution plan AWR analyzing pack

Version 1.0 - baseline
Version 2.0 - HTML reports for getplan and getllplan with "h" suffix
Version 2.1 - Bug fixing

1. getplanawr.sql getplanawrh.sql
Gathers sql execution statistics for given SQL_ID from AWR repository
File with "h" suffix creates HTML report

@getplanawr <SQL_ID>