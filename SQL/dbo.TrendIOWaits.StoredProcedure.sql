USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[TrendIOWaits]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendIOWaits]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrendIOWaits]
GO
/****** Object:  StoredProcedure [dbo].[TrendIOWaits]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendIOWaits]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[TrendIOWaits]
	@StartDate		datetime = null,
	@EndDate		datetime = null,
	@StartHour		int = 0,
	@EndHour		int = 23

AS 

;WITH IoStallBasic as (
select ts.SSN,
       ts.SST, 
       sum(io_stall_read_ms) io_stall_read_ms,
       sum(num_of_reads) num_of_reads,
       sum(io_stall_write_ms) io_stall_write_ms,
       sum(num_of_writes) num_of_writes
from dbo.Trend_dm_io_virtual_file_stats tdivfs
join dbo.Trend_snaps ts
on tdivfs.SSN = ts.SSN
where ts.SST between @StartDate and @EndDate
and datepart(hour, ts.SST) between @StartHour and @EndHour
group by ts.SSN, ts.SST
),
IoStallPrSnap as (
select cur.SSN,
       cur.SST, 
       cur.io_stall_read_ms io_stall_read_cur, 
       case when sign(cur.io_stall_read_ms - pre.io_stall_read_ms) = -1
              then cur.io_stall_read_ms
            else (cur.io_stall_read_ms - pre.io_stall_read_ms)
       end io_stall_read_diff,
       cur.num_of_reads,
       case when sign(cur.num_of_reads - pre.num_of_reads) = -1
              then cur.num_of_reads
            when sign(cur.num_of_reads - pre.num_of_reads) = 0
              then 1   -- when no reads risk of divide by zero
            else (cur.num_of_reads - pre.num_of_reads)
       end num_of_reads_diff,
       cur.io_stall_write_ms io_stall_write_cur, 
       case when sign(cur.io_stall_write_ms - pre.io_stall_write_ms) = -1
              then cur.io_stall_write_ms
            else (cur.io_stall_write_ms - pre.io_stall_write_ms)
       end io_stall_write_diff,
       cur.num_of_writes,
       case when sign(cur.num_of_writes - pre.num_of_writes) = -1
              then cur.num_of_writes
            when sign(cur.num_of_writes - pre.num_of_writes) = 0
              then 1   -- when no reads risk of divide by zero
            else (cur.num_of_writes - pre.num_of_writes)
       end num_of_writes_diff
from IoStallBasic cur
join IoStallBasic pre
on cur.SSN = pre.SSN+1
)
select SSN, SST,
       datepart(Year,SST) year, 
       datepart(month,SST) month, 
       datepart(week, SST) week, 
       datepart(weekday,SST) weekday, 
       datepart(hour,SST) hour,
--       io_stall_read_diff, num_of_reads_diff,
       io_stall_read_diff/num_of_reads_diff io_waits_ms_pr_read,
--       io_stall_write_diff, num_of_writes_diff,
       io_stall_write_diff/num_of_writes_diff io_waits_ms_pr_writes
from  IoStallPrSnap
order by SSN

' 
END
GO
