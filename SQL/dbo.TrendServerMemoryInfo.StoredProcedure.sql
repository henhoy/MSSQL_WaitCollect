USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[TrendServerMemoryInfo]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendServerMemoryInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrendServerMemoryInfo]
GO
/****** Object:  StoredProcedure [dbo].[TrendServerMemoryInfo]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendServerMemoryInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		HMH,Miracle
-- Create date: 20140923
-- Description:	Return aggregated user and logical 
--				connections.
-- Version:		1.0
-- =============================================
CREATE PROC [dbo].[TrendServerMemoryInfo]
	@StartDate		datetime,
	@EndDate		datetime,
	@StartHour		int = 0,
	@EndHour		int = 23,
	@TimeInterval	int = 60
AS 

SET NOCOUNT ON;


;with ConnBase as (
select SSN,
       sum(case when counter_name = ''Total Server Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as TotalServerMemory,
	   sum(case when counter_name = ''Target Server Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as TargetServerMemory,
	   sum(case when counter_name = ''SQL Cache Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as SqlCacheMemory,
	   sum(case when counter_name = ''Free Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as FreeMemory,
	   sum(case when counter_name = ''Stolen Cache Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as StolenCacheMemory,
       sum(case when counter_name = ''Database Cache Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as DatabaseCacheMemory,
	   sum(case when counter_name = ''Granted Workspace Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as GrantesWorkspaceMemory
from dbo.Trend_dm_os_performance_counters tdopc
where tdopc.cntr_type = 65792
and tdopc.counter_name in (''Total Server Memory (KB)'',''Target Server Memory (KB)'',''SQL Cache Memory (KB)'',
                           ''Free Memory (KB)'',''Stolen Cache Memory (KB)'',''Database Cache Memory (KB)'',
						   ''Granted Workspace Memory (KB)'')
group by SSN
),
ConnInfo as (
select Period = DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', ts.SST) / @TimeInterval) * @TimeInterval,''19000101''),    
       avg(TotalServerMemory) avgTotalServerMemory,
       avg(TargetServerMemory) avgTargetServerMemory,
       avg(SqlCacheMemory) avgSqlCacheMemory,
       avg(FreeMemory) avgFreeMemory,
       avg(StolenCacheMemory) avgStolenCacheMemory,
       avg(DatabaseCacheMemory) avgDatabaseCacheMemory,
	   avg(GrantesWorkspaceMemory) avgGrantesWorkspaceMemory
from ConnBase cb
join dbo.Trend_Snaps ts
on cb.SSN = ts.SSN
where ts.SST between @StartDate and @EndDate
and datepart(hour, ts.SST) between @StartHour and @EndHour
group by DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', ts.SST) / @TimeInterval) * @TimeInterval,''19000101'')
)
select Period,
       datepart(Year,Period) year, 
       datepart(month,Period) month, 
       datepart(week, Period) week, 
       datepart(weekday,Period) weekday, 
       datepart(hour, Period) hour,
       avgTotalServerMemory,
       avgTargetServerMemory,
	   avgSqlCacheMemory,
	   avgFreeMemory,
       avgStolenCacheMemory,
       avgDatabaseCacheMemory,
	   avgGrantesWorkspaceMemory
from ConnInfo
order by Period
' 
END
GO
