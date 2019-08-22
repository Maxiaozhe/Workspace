# Tips
## **Trigger**
1. 创建一个Trigger以记录Table的更新履历，并记录更新时的SQL命令  
- **@@spid**  
  @@spid是当前执行中的进程id
- **dbcc inputbuffer ( @@spid ) with no_infomsgs**
  可以取得进程的event情报  
  eventinfo 返回正在执行的SQL语句  
- **APP_NAME**
  当前程序名称