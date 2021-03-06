USE [WaitCollect]
GO
/****** Object:  Table [dbo].[Trend_Snaps]    Script Date: 28-09-2014 14:41:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_Snaps]') AND type in (N'U'))
DROP TABLE [dbo].[Trend_Snaps]
GO
/****** Object:  Table [dbo].[Trend_Snaps]    Script Date: 28-09-2014 14:41:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trend_Snaps]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Trend_Snaps](
	[SSN] [int] IDENTITY(1,1) NOT NULL,
	[SST] [datetime] NULL,
	[MACHINE] [nvarchar](128) NULL,
	[LEVEL] [smallint] NULL,
	[BOOT] [nvarchar](50) NULL,
 CONSTRAINT [PK_CA_ssn.ix] PRIMARY KEY CLUSTERED 
(
	[SSN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
