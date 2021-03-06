USE [WaitCollect]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_os_performance_counters_Trend_Snaps]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_performance_counters]'))
ALTER TABLE [dbo].[Trend_dm_os_performance_counters] DROP CONSTRAINT [FK_Trend_dm_os_performance_counters_Trend_Snaps]
GO
/****** Object:  Index [Idx_nc_tdopc_cn_in_ct]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_performance_counters]') AND name = N'Idx_nc_tdopc_cn_in_ct')
DROP INDEX [Idx_nc_tdopc_cn_in_ct] ON [dbo].[Trend_dm_os_performance_counters]
GO
/****** Object:  Table [dbo].[Trend_dm_os_performance_counters]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_performance_counters]') AND type in (N'U'))
DROP TABLE [dbo].[Trend_dm_os_performance_counters]
GO
/****** Object:  Table [dbo].[Trend_dm_os_performance_counters]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_performance_counters]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Trend_dm_os_performance_counters](
	[SSN] [int] NULL,
	[object_name] [nchar](128) NOT NULL,
	[counter_name] [nchar](128) NOT NULL,
	[instance_name] [nchar](128) NULL,
	[cntr_value] [bigint] NOT NULL,
	[cntr_type] [int] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [Idx_nc_tdopc_cn_in_ct]    Script Date: 28-09-2014 14:41:10 ******/
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_performance_counters]') AND name = N'Idx_nc_tdopc_cn_in_ct')
CREATE NONCLUSTERED INDEX [Idx_nc_tdopc_cn_in_ct] ON [dbo].[Trend_dm_os_performance_counters]
(
	[counter_name] ASC,
	[instance_name] ASC,
	[cntr_type] ASC
)
INCLUDE ( 	[SSN],
	[cntr_value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_os_performance_counters_Trend_Snaps]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_performance_counters]'))
ALTER TABLE [dbo].[Trend_dm_os_performance_counters]  WITH NOCHECK ADD  CONSTRAINT [FK_Trend_dm_os_performance_counters_Trend_Snaps] FOREIGN KEY([SSN])
REFERENCES [dbo].[Trend_Snaps] ([SSN])
ON DELETE CASCADE
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Trend_dm_os_performance_counters_Trend_Snaps]') AND parent_object_id = OBJECT_ID(N'[dbo].[Trend_dm_os_performance_counters]'))
ALTER TABLE [dbo].[Trend_dm_os_performance_counters] NOCHECK CONSTRAINT [FK_Trend_dm_os_performance_counters_Trend_Snaps]
GO
