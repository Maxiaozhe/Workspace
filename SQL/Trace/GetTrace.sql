--get trace info 
declare @traceId as int=2
select * from ::fn_trace_getinfo(@traceid)

-- get all trace info
select * from ::fn_trace_getinfo(0)

-- get result from trace file(*.trc)
declare @trcfile as nvarchar(255)='C:\tracelog\deadlockdetect.trc'
select cast(TextData as xml),* from fn_trace_gettable(@trcfile,1)
