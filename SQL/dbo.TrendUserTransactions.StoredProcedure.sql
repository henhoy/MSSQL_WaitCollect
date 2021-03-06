USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[TrendUserTransactions]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendUserTransactions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrendUserTransactions]
GO
/****** Object:  StoredProcedure [dbo].[TrendUserTransactions]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendUserTransactions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'-- =============================================
-- Author:		HMH,Miracle
-- Create date: 20110308
-- Description:	Return aggregated user transactions 
-- Version:		1.1.0
-- =============================================

CREATE PROC [dbo].[TrendUserTransactions]
	@StartDate		datetime = null,
	@EndDate		datetime = null,
	@StartHour		int = 0,
	@EndHour		int = 23,
	@MonthsBack		int = null,
	@TimeInterval	int = 60
AS 

declare @startSSN int, @endSSN int

SET NOCOUNT ON;

If @MonthsBack > 0
  begin
    set @StartDate = dateadd(month, -@MonthsBack, @EndDate)
  end
  
;With TransBase as (
select ts.SST, ts.SSN, tdopc.cntr_value
from dbo.Trend_dm_os_performance_counters tdopc
join dbo.Trend_Snaps ts
on ts.SSN = tdopc.SSN
where ts.SST between @StartDate and @EndDate
and datepart(hour, ts.SST) between @StartHour and @EndHour
and counter_name = ''Transactions/sec''
and instance_name = ''_Total''
and cntr_type = 272696576
),
TransPrSnap as (
select cur.SST SST, cur.SSN SSN, cur.cntr_value cur, pre.cntr_value pre, cur.cntr_value - pre.cntr_value diff
from TransBase cur
join TransBase pre
on cur.SSN = pre.SSN+1
),
TransPrTen as (
select Period = DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', tps.SST) /@TimeInterval) * @TimeInterval,''19000101''), 
       --case when sign(avg(diff)) = 1 then avg(diff) else avg(cur) end TransPrSnap
       case 
		when sign(avg(diff)) = -1 then 0 --avg(cur) 
		else avg(diff) 
	   end TransPrSnap
from TransPrSnap tps
group by DATEADD(MINUTE,(DATEDIFF(MINUTE,''19000101'', tps.SST) / @TimeInterval) * @TimeInterval,''19000101'')
)
select Period, 
       datepart(Year,Period) year, 
       datepart(month,Period) month, 
       datepart(week,Period) week, 
       datepart(weekday,Period) weekday, 
       datepart(hour, Period) hour,
       TransPrSnap
from TransPrTen
order by Period

' 
END
GO
