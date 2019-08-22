declare @traceId int 
set @traceId=2 --<起動時記録されるTraceId>
--Pause Trace
exec sp_trace_setstatus @traceId,0

--Stop Trace
exec sp_trace_setstatus @traceId,2

