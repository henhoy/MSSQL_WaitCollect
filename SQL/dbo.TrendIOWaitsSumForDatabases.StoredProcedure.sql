USE [WaitCollect]
GO
/****** Object:  StoredProcedure [dbo].[TrendIOWaitsSumForDatabases]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendIOWaitsSumForDatabases]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[TrendIOWaitsSumForDatabases]
GO
/****** Object:  StoredProcedure [dbo].[TrendIOWaitsSumForDatabases]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TrendIOWaitsSumForDatabases]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROC [dbo].[TrendIOWaitsSumForDatabases]
	@StartDate		datetime = null,
	@EndDate		datetime = null

AS 


;with IOBASIS as
(
select ts.SSN as SSN,
       ts.SST as SST, 
	   database_name as database_name,
	   logical_name as logical_name,
	   LEAD(io_stall_read_ms, 1, 0)  over (partition by logical_name order by ts.sst) - io_stall_read_ms as io_stall_read_ms,
	   LEAD(io_stall_write_ms, 1, 0) over (partition by logical_name order by ts.sst) - io_stall_write_ms as io_stall_write_ms,
	   LEAD(num_of_reads, 1, 0)      over (partition by logical_name order by ts.sst) - num_of_reads as num_of_reads, 
	   LEAD(num_of_writes, 1, 0)     over (partition by logical_name order by ts.sst) - num_of_writes as num_of_writes
from dbo.Trend_dm_io_virtual_file_stats tdivfs
join dbo.Trend_snaps ts
on tdivfs.SSN = ts.SSN
where ts.SST between @StartDate and @EndDate
)
select 
  database_name,
  SUM((case when io_stall_read_ms  <= 0 then 1 else io_stall_read_ms end)  / (case when num_of_reads <= 0 then 1 else num_of_reads end))  as io_stall_read_ms,
  SUM((case when io_stall_write_ms <= 0 then 1 else io_stall_write_ms end) / (case when num_of_writes<= 0 then 1 else num_of_writes end)) as io_stall_write_ms
from IOBASIS
group by database_name' 
END
GO
