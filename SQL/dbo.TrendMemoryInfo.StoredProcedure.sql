USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[TrendMemoryInfo]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendMemoryInfo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrendMemoryInfo]
GO
/****** Object:  StoredProcedure [dbo].[TrendMemoryInfo]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendMemoryInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		HMH,Miracle
-- Create date: 20140923
-- Description:	Return aggregated user and logical 
--				connections.
-- Version:		1.0
-- =============================================
CREATE PROC [dbo].[TrendMemoryInfo]
	@StartDate		datetime,
	@EndDate		datetime,
	@StartHour		int = 0,
	@EndHour		int = 23,
	@MonthsBack		int = null,
	@TimeInterval	int = 60
AS 

SET NOCOUNT ON;

If @Monthsback > 0
  begin
    set @StartDate = dateadd(month, -@MonthsBack, @EndDate)
  end

;with ConnBase as (
select SSN,
       sum(case when counter_name = ''Page life expectancy'' then tdopc.cntr_value else 0 end) as PageLifeExpect,
       sum(case when counter_name = ''Database Cache Memory (KB)'' then tdopc.cntr_value else 0 end)/1024 as DatabaseCacheMem
from dbo.Trend_dm_os_performance_counters tdopc
where tdopc.cntr_type = 65792
and tdopc.counter_name in (''Page life expectancy'',''Database Cache Memory (KB)'')
group by SSN
),
ConnInfo as (
select Period = DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', ts.SST) / @TimeInterval) * @TimeInterval,''19000101''),    
       max(PageLifeExpect) MaxPageLifeExpect,
       max(DatabaseCacheMem) maxDatabaseCacheMem,
       min(PageLifeExpect) minPageLifeExpect,
       min(DatabaseCacheMem) minDatabaseCacheMem,
       avg(PageLifeExpect) avgPageLifeExpect,
       avg(DatabaseCacheMem) avgDatabaseCacheMem
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
       maxPageLifeExpect,
       minPageLifeExpect,
	   avgPageLifeExpect,
	   maxDatabaseCacheMem,
       minDatabaseCacheMem,
       avgDatabaseCacheMem
from ConnInfo
order by Period
' 
END
GO
