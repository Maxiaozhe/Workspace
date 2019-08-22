/****** Object:  Table [dbo].[EGGA0001_VLSTATUS_HISTORY]    Script Date: 2019/08/08 16:59:24 ******/
DROP TABLE [dbo].[EGGA0001_VLSTATUS_HISTORY]
GO

/****** Object:  Table [dbo].[EGGA0001_VLSTATUS_HISTORY]    Script Date: 2019/08/08 16:59:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EGGA0001_VLSTATUS_HISTORY](
	[IDDOC] [int] NULL,
	[VLSTATUS_BF] [nvarchar](10) NULL,
	[IDUPDUSER_BF] [int] NULL,
	[DTUPDATE_BF] [nvarchar](20) NULL,
	[VLSTATUS_AF] [nvarchar](10) NULL,
	[IDUPDUSER_AF] [int] NULL,
	[DTUPDATE_AF] [nvarchar](20) NULL,
	[DTUPDATE] [datetime] NULL,
	[AppName] [nvarchar](max) NULL,
	[EventInfo] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



Create TRIGGER EGGA0001_VLSTATUS_CHNAGE 
    ON [dbo].[EGGA0001]
    FOR UPDATE
    AS
    BEGIN
    SET NOCOUNT ON

	DECLARE @EventInfo varchar(max)
	DECLARE @EventSource TABLE (EventType nvarchar(30), Parameters int, EventInfo nvarchar(max)) 

	INSERT INTO @EventSource
	EXEC ('dbcc inputbuffer (' + @@spid + ') with no_infomsgs')

	SELECT TOP 1 @EventInfo = ISNULL(EventInfo, '')	FROM @EventSource
	
	INSERT INTO EGGA0001_VLSTATUS_HISTORY
	SELECT 
	A.IDDOC,
	A.VLSTATUS AS VLSTATUS_BF,
	A.IDUPDUSER AS IDUPDUSER_BF,
	A.DTUPDATE AS DTUPDATE_BF,
	B.VLSTATUS AS VLSTATUS_AF,
	B.IDUPDUSER AS IDUPDUSER_AF,
	B.DTUPDATE AS DTUPDATE_AF,
	GETDATE() AS DTUPDATE,
	APP_NAME() as AppName,
	@EventInfo as EventInfo
	FROM 
	deleted A inner join inserted B ON(A.IDDOC=B.IDDOC)

    END

