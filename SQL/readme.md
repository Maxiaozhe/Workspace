# Tips
## **Trigger**
### [TRIGGER_GET_CURRENT_SQL](./Trigger/TRIGGER_GET_CURRENT_SQL.sql)
1. 创建一个Trigger以记录Table的更新履历，并记录更新时的SQL命令  
- **@@spid**  
  @@spid是当前执行中的进程id
- **dbcc inputbuffer ( @@spid ) with no_infomsgs**
  可以取得进程的event情报  
  eventinfo 返回正在执行的SQL语句  
- **APP_NAME**
  当前程序名称
  
## **Trace**    
### 记录SqlServer的DeadLock状况
- **[GetTrace](.\Trace\GetTrace.sql)**  
  - ::fn_trace_getinfo(traceId)
    取得当前的Trace情报 traceId=0时，返回所有的Trace情报    
- **[StartTrace](.\Trace\StartTrace.sql)**
  - sp_trace_create    
    创建一个跟踪定义    
    创建后返回一个traceId，记住这个ID，启动停止时需要用到　　　　
    刚创建的Trace进程创建后是停止状态    
  - sp_trace_setevent    
    设定跟踪对象和对象的列    
    - sys.trace_categories    
      跟踪对象分类定义  4: lock  
    - sys.trace_events 
      跟踪对象定义      148: Deadlock graph 
    - sys.trace_columns
      跟踪对象列        12: spid 

  - sp_trace_setstatus @traceId,@status
    - @status 
      - 0 : Pause
      - 1 : start
      - 2 : stop         
  
- **[StopTrace](.\Trace\StopTrace.sql)**
    停止一个追踪进程    
