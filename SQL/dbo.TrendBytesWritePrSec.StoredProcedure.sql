USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[TrendBytesWritePrSec]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendBytesWritePrSec]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrendBytesWritePrSec]
GO
/****** Object:  StoredProcedure [dbo].[TrendBytesWritePrSec]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendBytesWritePrSec]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[TrendBytesWritePrSec]
	@StartDate		datetime = null,
	@EndDate		datetime = null,
	@StartHour		int = 0,
	@EndHour		int = 23,
	@MonthsBack		int = null
	
AS 

SET NOCOUNT ON;

If @MonthsBack > 0
  begin
    set @StartDate = dateadd(month, -@MonthsBack, @EndDate)
  end
  
;with IoBytesWrite as (
select ts.SSN, ts.SST, 
       sum(case when file_id = 2 then tdivfs.num_of_bytes_written else 0 end) sum_num_of_logfile_bytes_written,
       sum(case when database_id = 2 and file_id <> 2 then tdivfs.num_of_bytes_written else 0 end) sum_num_of_tempdb_bytes_written,
       sum(case when database_id <> 2 and file_id <> 2 then tdivfs.num_of_bytes_written else 0 end) sum_num_of_db_bytes_written
from dbo.Trend_dm_io_virtual_file_stats tdivfs
join dbo.Trend_Snaps ts
on  tdivfs.SSN = ts.SSN
where ts.SST between @StartDate and @EndDate
and datepart(hour, ts.SST) between @StartHour and @EndHour
group by ts.SSN, ts.SST
),
IobytesWritePrSnap as (
select cur.SSN, 
       cur.SST, 
       (cur.SST - pre.SST) diff_in_time,
       DATEDIFF(SECOND,''19000101'',(cur.SST - pre.SST)) diff_in_seonds,
       cur.sum_num_of_logfile_bytes_written,
       case when sign(cur.sum_num_of_logfile_bytes_written - pre.sum_num_of_logfile_bytes_written) = -1 
         then 0 
         else (cur.sum_num_of_logfile_bytes_written - pre.sum_num_of_logfile_bytes_written)
       end  diff_num_of_logfile_bytes_written,
       cur.sum_num_of_tempdb_bytes_written,
       case when sign(cur.sum_num_of_tempdb_bytes_written - pre.sum_num_of_tempdb_bytes_written) = -1
         then 0
         else (cur.sum_num_of_tempdb_bytes_written - pre.sum_num_of_tempdb_bytes_written)
       end diff_num_of_tempdb_bytes_written,
       cur.sum_num_of_db_bytes_written,
       case when sign(cur.sum_num_of_db_bytes_written - pre.sum_num_of_db_bytes_written) = -1 
         then 0
         else (cur.sum_num_of_db_bytes_written - pre.sum_num_of_db_bytes_written)
       end diff_num_of_db_bytes_written
from IoBytesWrite cur
join IoBytesWrite pre
on cur.SSN = pre.SSN+1
)
select SST, 
       datepart(year, SST) "year",
       datepart(month, SST) "month",
       datepart(week, SST) "week",
       datepart(weekday,SST) "weekday",
       datepart(hour, SST) "hour",
       diff_num_of_logfile_bytes_written/diff_in_seonds logfile_bytes_writes_prsec,
       diff_num_of_logfile_bytes_written/1024/diff_in_seonds logfile_KB_writes_prsec,
       diff_num_of_logfile_bytes_written/1024/1024/diff_in_seonds logfile_MB_writes_prsec,
       diff_num_of_tempdb_bytes_written/diff_in_seonds tempdb_bytes_writes_prsec,
       diff_num_of_tempdb_bytes_written/1024/diff_in_seonds tempdb_KB_writes_prsec,
       diff_num_of_tempdb_bytes_written/1024/1024/diff_in_seonds tempdb_MB_writes_prsec,              
       diff_num_of_db_bytes_written/diff_in_seonds database_bytes_writes_prsec,
       diff_num_of_db_bytes_written/1024/diff_in_seonds database_KB_writes_prsec,
       diff_num_of_db_bytes_written/1024/1024/diff_in_seonds database_MB_writes_prsec
from IobytesWritePrSnap
order by SSN

' 
END
GO
