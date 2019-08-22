declare @traceId int
declare @maxfilesize bigint=5
declare @rc int
declare @dir nvarchar(255)='C:\tracelog\deadlockdetect_';
declare @trcFile nvarchar(255)
--check traceInfo
if exists(select traceid from ::fn_trace_getinfo(0) where value like @dir + '%')
begin
	goto finish
end

--init trace
set @trcFile=@dir  + FORMAT(getdate(),'yyyyMMdd_HHmmss')
select @trcFile
exec @rc=sp_trace_create @traceId output,0,@trcFile ,@maxfilesize,null
if @rc!=0 goto error

--Set trace event
--148 Lock:deadlock graph event
--12 = SPID
declare @on bit=1
--set trace columns
exec sp_trace_setevent @traceId,148,12,@on
exec sp_trace_setevent @traceId,148,11,@on
exec sp_trace_setevent @traceId,148,4,@on
exec sp_trace_setevent @traceId,148,9,@on
exec sp_trace_setevent @traceId,148,26,@on
exec sp_trace_setevent @traceId,148,10,@on
exec sp_trace_setevent @traceId,148,35,@on
exec sp_trace_setevent @traceId,148,22,@on
exec sp_trace_setevent @traceId,148,34,@on
exec sp_trace_setevent @traceId,148,32,@on
exec sp_trace_setevent @traceId,148,14,@on
exec sp_trace_setevent @traceId,148,15,@on
exec sp_trace_setevent @traceId,148,63,@on
exec sp_trace_setevent @traceId,148,1,@on

--start trace
exec sp_trace_setstatus @traceId,1

select @traceId as TraceId 
goto finish

error:
select @rc as errorCode

finish:
go

