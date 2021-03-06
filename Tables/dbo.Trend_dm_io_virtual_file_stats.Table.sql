USE [WaitCollect]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_io_Trend_Snaps_idx]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_io_virtual_file_stats]'))
ALTER TABLE [dbo].[Trend_dm_io_virtual_file_stats] DROP CONSTRAINT [FK_Trend_dm_io_Trend_Snaps_idx]
GO
/****** Object:  Table [dbo].[Trend_dm_io_virtual_file_stats]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_io_virtual_file_stats]') AND type in (N'U'))
DROP TABLE [dbo].[Trend_dm_io_virtual_file_stats]
GO
/****** Object:  Table [dbo].[Trend_dm_io_virtual_file_stats]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_io_virtual_file_stats]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Trend_dm_io_virtual_file_stats](
	[SSN] [int] NOT NULL,
	[database_id] [smallint] NOT NULL,
	[file_id] [smallint] NOT NULL,
	[sample_ms] [int] NOT NULL,
	[num_of_reads] [bigint] NOT NULL,
	[num_of_bytes_read] [bigint] NOT NULL,
	[io_stall_read_ms] [bigint] NOT NULL,
	[num_of_writes] [bigint] NOT NULL,
	[num_of_bytes_written] [bigint] NOT NULL,
	[io_stall_write_ms] [bigint] NOT NULL,
	[io_stall] [bigint] NOT NULL,
	[size_on_disk_bytes] [bigint] NOT NULL,
	[file_handle] [varbinary](8) NOT NULL,
	[database_name] [nvarchar](128) NULL,
	[logical_name] [sysname] NOT NULL,
	[physical_name] [nvarchar](260) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_io_Trend_Snaps_idx]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_io_virtual_file_stats]'))
ALTER TABLE [dbo].[Trend_dm_io_virtual_file_stats]  WITH CHECK ADD  CONSTRAINT [FK_Trend_dm_io_Trend_Snaps_idx] FOREIGN KEY([SSN])
REFERENCES [dbo].[Trend_Snaps] ([SSN])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_io_Trend_Snaps_idx]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_io_virtual_file_stats]'))
ALTER TABLE [dbo].[Trend_dm_io_virtual_file_stats] CHECK CONSTRAINT [FK_Trend_dm_io_Trend_Snaps_idx]
GO
