USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[Trend_Snap]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_Snap]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Trend_Snap]
GO
/****** Object:  StoredProcedure [dbo].[Trend_Snap]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_Snap]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- Level parameter is not used as of this time
CREATE  PROC [dbo].[Trend_Snap] @Level int = 0
AS 

-- ***************************************************************************
-- author: 	Henrik Høyer 
-- version:	1.0.0.0
-- 
-- revision history
-- yyyymmdd by      	Version		description
-- ======== ======= =========================================================
-- 20140322 HMH   	v1.0.0.0 	Base version Created for SQL Server 20xx
-- ***************************************************************************

SET NOCOUNT ON;

DECLARE @SSN	 int 			
DECLARE @SST	 datetime		
DECLARE @LSST	 datetime		
DECLARE @MACHINE nvarchar(128)	
DECLARE @CPU	 float			
DECLARE @BOOT	 datetime		


SELECT  @SST=getdate()
SELECT  @LSST=max(SST) FROM [dbo].[Trend_Snaps] 
SELECT  @CPU=@@CPU_BUSY * CAST(@@TIMETICKS AS FLOAT)/1000		-- Calculate CPU time in microseconds
SELECT  @BOOT=login_time from master.sys.sysprocesses where spid = 1
SELECT  @MACHINE=@@SERVERNAME+''\''+@@SERVICENAME

-- Collect some base info data
INSERT INTO [dbo].[Trend_Snaps]([SST],[MACHINE],[LEVEL],[BOOT])
VALUES(@SST,@MACHINE,@LEVEL,@BOOT);

SELECT @SSN = @@IDENTITY -- Get the current PK number from the base table

--
--			*** COLLECT INSTANCE PERFORMANCE STATISTICS ***
--
--
-- ===========================================================================
-- TYPE:	system wait statistics			MODE: Collect
-- DMV:		sys.dm_os_wait_stats
-- DESC:	Collect system wait statistics
-- ===========================================================================
--
--

	INSERT INTO [dbo].[Trend_dm_os_wait_stats]
	SELECT	 @SSN
			,[wait_type]
			,[waiting_tasks_count]
			,([wait_time_ms] - [signal_wait_time_ms])  --Correcting wait_time_ms to not include signal_wait_time_ms.
			,[max_wait_time_ms]
			,[signal_wait_time_ms]
	FROM sys.dm_os_wait_stats

-- 
-- Adding Service time (Using CPU), (Not used in reports after all since it is a int which will overflow anyway.)
-- 


	INSERT INTO [dbo].[Trend_dm_os_wait_stats]  
			([SSN]
			,[wait_type] 
			,[waiting_tasks_count] 
			,[wait_time_ms] 
			,[max_wait_time_ms] 
			,[signal_wait_time_ms])
	VALUES (@SSN, ''USING CPU'', 0, @CPU, 0, 0)

-- 
-- Making signal_wait_time into its own event (WAITING_FOR_CPU).
-- 
/*
	INSERT INTO [dbo].[Trend_dm_os_wait_stats] 
	   	   ([SSN]
		   ,[wait_type]
           ,[waiting_tasks_count]
           ,[wait_time_ms]
           ,[max_wait_time_ms]
           ,[signal_wait_time_ms])
		SELECT @SSN, ''WAITING_FOR_CPU'', 0, sum(signal_wait_time_ms), 0, 0
		FROM [dbo].[Trend_dm_os_wait_stats]
		WHERE SSN = @SSN
*/



-- ===========================================================================
-- TYPE:	I/O wait statistics				MODE: Collect
-- DMV:		sys.dm_io_virtual_file_stats
-- DESC:	Collect I/O wait statistics for the different databases
-- ===========================================================================
-- 
--

INSERT INTO [dbo].[Trend_dm_io_virtual_file_stats]
SELECT		 @SSN
			,a.[database_id]
      		,a.[file_id]
      		,[sample_ms]
      		,[num_of_reads]
     		,[num_of_bytes_read]
     	 	,[io_stall_read_ms]
      		,[num_of_writes]
      		,[num_of_bytes_written]
      		,[io_stall_write_ms]
      		,[io_stall]
      		,[size_on_disk_bytes]
      		,[file_handle]
			,DB_NAME(a.[database_id]) as database_name
			,b.[name] as logical_name
			,b.[physical_name]
		from master.sys.dm_io_virtual_file_stats(NULL,NULL) a, master.sys.master_files  b
		where a.database_id = b.database_id
		and a.file_id = b.file_id;

-- ===========================================================================
-- TYPE:	General system statistics				MODE: Collect
-- VIEW:	sys.dm_os_performance_counters
-- DESC:	Collect the different perf counters in SQL Server, not realy used at this time. :( 
-- 20100806 HMH     v1.0.1.0    Redifinition (reduction) of performance coun-
--                              ters sampling
-- 20110413 HMH     v1.0.2.0    Extended collect with object_name types
--								"Access Methods" and "Wait Statistics"
-- ===========================================================================
-- 
--
INSERT INTO [dbo].[Trend_dm_os_performance_counters]
SELECT @SSN
	  ,[object_name]
      ,[counter_name]
      ,[instance_name]
      ,[cntr_value]
      ,[cntr_type] 
FROM sys.dm_os_performance_counters
where object_name like ''%General%'' and cntr_type = 65792 -- # collect all 65792 countersand counter_name in (''User Connections'', ''Logical Connections'', ''Transactions'')
or object_name like ''%Databases%'' and counter_name in (''Active Transactions'', ''Transactions/sec'')
or object_name like ''%Memory Manager%'' -- and counter_name in (''Total Server Memory (KB)'', ''Target Server Memory (KB)'');
or object_name like ''%Buffer Manager%''
or object_name like ''%Access Methods%'' -- Collect various info regarding access methods
or object_name like ''%Wait Statistics%'' -- Collect Waits info



' 
END
GO
