USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[TrendUserConnections]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendUserConnections]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrendUserConnections]
GO
/****** Object:  StoredProcedure [dbo].[TrendUserConnections]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendUserConnections]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		HMH,Miracle
-- Create date: 20140923
-- Description:	Return aggregated user and logical 
--				connections.
-- Version:		1.0
-- =============================================
CREATE PROC [dbo].[TrendUserConnections]
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
       sum(case when counter_name = ''User Connections'' then tdopc.cntr_value else 0 end) as UserConnections,
       sum(case when counter_name = ''Logical Connections'' then tdopc.cntr_value else 0 end) as LogicalConnections
from dbo.Trend_dm_os_performance_counters tdopc
where tdopc.cntr_type = 65792
and tdopc.counter_name in (''Logical Connections'',''User Connections'')
group by SSN
),
ConnInfo as (
select Period = DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', ts.SST) / @TimeInterval) * @TimeInterval,''19000101''),    
       max(UserConnections) maxuser,
       max(LogicalConnections) maxlogic,
       min(UserConnections) minuser,
       min(LogicalConnections) minlogic,
       avg(UserConnections) avguser,
       avg(LogicalConnections) avglogic
from ConnBase cb
join TrendMon.Trend_Snaps ts
on cb.SSN = ts.SSN
where ts.SST between @StartDate and @EndDate
and datepart(hour, ts.SST) between @StartHour and @EndHour
group by DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', ts.SST) / @TimeInterval) * @TimeInterval,''19000101'')
)
select Period,
       datepart(Year,Period) year, 
       datepart(month,Period) month, 
       [TrendMon].[TrendISOweek](Period) week, 
       datepart(weekday,Period) weekday, 
       datepart(hour, Period) hour,
       maxuser,
       maxlogic,
       minuser,
       minlogic,
       avguser,
       avglogic
from ConnInfo
order by Period
--order by DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', ts.sst) / @TimeInterval) * @TimeInterval,''19000101'')
' 
END
GO
