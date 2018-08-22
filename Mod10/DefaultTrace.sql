SELECT * 
FROM ::fn_trace_gettable('C:\Program Files\Microsoft SQL 
Server\MSSQL.13\MSSQL\LOG\log.trc',0) 
INNER JOIN sys.trace_events e 
ON eventclass = trace_event_id 