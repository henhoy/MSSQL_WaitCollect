USE [WaitCollect]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_os_wait_stats_Trend_Snaps_idx]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_wait_stats]'))
ALTER TABLE [dbo].[Trend_dm_os_wait_stats] DROP CONSTRAINT [FK_Trend_dm_os_wait_stats_Trend_Snaps_idx]
GO
/****** Object:  Table [dbo].[Trend_dm_os_wait_stats]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_wait_stats]') AND type in (N'U'))
DROP TABLE [dbo].[Trend_dm_os_wait_stats]
GO
/****** Object:  Table [dbo].[Trend_dm_os_wait_stats]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_wait_stats]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Trend_dm_os_wait_stats](
	[SSN] [int] NULL,
	[wait_type] [nvarchar](60) NOT NULL,
	[waiting_tasks_count] [bigint] NOT NULL,
	[wait_time_ms] [bigint] NOT NULL,
	[max_wait_time_ms] [bigint] NOT NULL,
	[signal_wait_time_ms] [bigint] NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_os_wait_stats_Trend_Snaps_idx]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_wait_stats]'))
ALTER TABLE [dbo].[Trend_dm_os_wait_stats]  WITH CHECK ADD  CONSTRAINT [FK_Trend_dm_os_wait_stats_Trend_Snaps_idx] FOREIGN KEY([SSN])
REFERENCES [dbo].[Trend_Snaps] ([SSN])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_os_wait_stats_Trend_Snaps_idx]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_wait_stats]'))
ALTER TABLE [dbo].[Trend_dm_os_wait_stats] CHECK CONSTRAINT [FK_Trend_dm_os_wait_stats_Trend_Snaps_idx]
GO
