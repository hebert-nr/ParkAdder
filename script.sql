USE [master]
GO
/****** Object:  Database [thePPF]    Script Date: 9/25/2015 4:17:22 PM ******/
CREATE DATABASE [thePPF] ON  PRIMARY 
( NAME = N'PPF', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\PPF.mdf' , SIZE = 2048KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'PPF_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\PPF_log.ldf' , SIZE = 4224KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [thePPF] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [thePPF].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [thePPF] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [thePPF] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [thePPF] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [thePPF] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [thePPF] SET ARITHABORT OFF 
GO
ALTER DATABASE [thePPF] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [thePPF] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [thePPF] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [thePPF] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [thePPF] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [thePPF] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [thePPF] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [thePPF] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [thePPF] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [thePPF] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [thePPF] SET  DISABLE_BROKER 
GO
ALTER DATABASE [thePPF] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [thePPF] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [thePPF] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [thePPF] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [thePPF] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [thePPF] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [thePPF] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [thePPF] SET RECOVERY FULL 
GO
ALTER DATABASE [thePPF] SET  MULTI_USER 
GO
ALTER DATABASE [thePPF] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [thePPF] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'thePPF', N'ON'
GO
USE [thePPF]
GO
/****** Object:  StoredProcedure [dbo].[FeatureListBox]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[FeatureListBox] 

AS
SELECT *
FROM feature 


GO
/****** Object:  StoredProcedure [dbo].[ParkDetails]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ParkDetails]
@parkId INT = null
AS
SELECT DISTINCT ParkId
,ParkName
,StreetAddress
,City
,County
,ZipCode
,STUFF((
			SELECT ', ' + T.A
			FROM (
				SELECT DISTINCT FeatureName
				FROM Feature f
				INNER JOIN FeaturesAtPark fp ON fp.FId = f.FeatureId
				WHERE Park.ParkId = fp.PID
				AND f.FeatureID IS NOT NULL
				) T(A)
			ORDER BY T.A
			FOR XML PATH(''), TYPE).value('.','VARCHAR(1000)'), 1, 1, '') AS [ParkFeatures]
FROM Park 
WHERE ParkID = @ParkId and @ParkID IS NOT NULL

/*

[ParkDetails] '13'

*/ 
GO
/****** Object:  StoredProcedure [dbo].[ParkList]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ParkList] @ParkId INT = NULL
AS
SELECT DISTINCT ParkId
	,ParkName
	,StreetAddress
	,City
	,ZipCode
	,County
	,Latitude
	,Longitude
FROM Park




/*
[ParkList] ''
*/







GO
/****** Object:  StoredProcedure [dbo].[SearchParks]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SearchParks]

@ParkName NVARCHAR(1000)= NULL,
@City NVARCHAR(500) = NULL,
@FeatureName NVARCHAR(1000) = NULL

AS

SET @ParkName = '%' + ISNULL(@ParkName, '%') + '%'
SET @City = '%' + ISNULL(@City, '%') + '%'
SET @FeatureName = '%' + ISNULL(@FeatureName, '%') + '%'

SELECT DISTINCT 
	 ParkId
	,ParkName
	,StreetAddress
	,City
	,ZipCode
	,County
	,STUFF((
			SELECT ', ' + T.A
			FROM (
				SELECT FeatureName
				FROM Feature f JOIN FeaturesAtPark fp ON fp.FId = f.FeatureId
				WHERE Park.ParkId = fp.PID
				) T(A)
			ORDER BY T.A
			FOR XML PATH('')
			), 1, 1, '') AS [ParkFeatures]
	,Latitude
	,Longitude
	
FROM Park JOIN FeaturesAtPark on Park.ParkId = FeaturesAtPark.PID JOIN Feature on FeaturesAtPark.FID = Feature.FeatureId
WHERE ParkName LIKE @ParkName AND City LIKE @City AND FeatureName LIKE @FeatureName

/*
[searchparks] '', '', ''
*/ 
GO
/****** Object:  StoredProcedure [dbo].[SQLtoJSON]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SQLtoJSON] @ParkId INT = NULL
AS
SELECT DISTINCT ParkId
	,ParkName
	,StreetAddress
	,City
	,ZipCode
	,County
	,Latitude
	,Longitude
	/*lists FeatureName from table into single string*/
	,STUFF((
			SELECT ', ' + T.A
			FROM (
				SELECT DISTINCT FeatureName
				FROM Feature f
				INNER JOIN FeaturesAtPark fp ON fp.FId = f.FeatureId
				WHERE P.ParkId = fp.PID
				AND f.FeatureID IS NOT NULL
				) T(A)
			ORDER BY T.A
			FOR XML PATH(''), TYPE).value('.','VARCHAR(1000)'), 1, 1, '') AS [feature]
FROM Park p join FeaturesAtPark f on p.parkId = f.pid join feature fa on fa.featureId = f.fid  
FOR XML path, root;



/*
[ParkList] ''
*/

/* This is our transfer into JSON. */

DECLARE @ParkJSON xml;
set @ParkJSON = '<?xml version="1.0" encoding="UTF-8"?>
<root>
  <row>
    <ParkId>2</ParkId>
    <ParkName>Wildwood Park</ParkName>
    <StreetAddress>1101 23rd Ave SE</StreetAddress>
    <City>Puyallup</City>
    <ZipCode>98374</ZipCode>
    <County>Pierce</County>
    <Latitude>4.730787590000000e+001</Latitude>
    <Longitude>-1.225309605000000e+002</Longitude>
    <feature> BBQ/Grill, Disabled Access, Hiking, Multi-Purpose Room Rental, Picnic Area, Playground, Restrooms, Stream or Creek, Toddler Playground, Walking Trail, Waterfall</feature>
  </row>
</root>';



SELECT STUFF((
			SELECT * FROM
			 (SELECT ',
			  {' + 
			   STUFF((SELECT ',"' + coalesce(b.c.value('local-name(.)', 'NVARCHAR(MAX)'), '') + '":"' +
			    b.c.value('text()[1]', 'NVARCHAR(MAX)') + '"'
		FROM x.a.nodes('*') b(c)
		FOR XML path(''),TYPE).value('(./text())[1]', 'NVARCHAR(MAX)')
		, 1, 1, '') + '}'
	FROM @ParkJSON.nodes('/root/*') x(a)
	) JSON(theline)
   FOR XML path(''),TYPE).value('.', 'NVARCHAR(MAX)')
, 1, 1, '')
GO
/****** Object:  Table [dbo].[Feature]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Feature](
	[FeatureId] [int] IDENTITY(1,1) NOT NULL,
	[FeatureName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Feature] PRIMARY KEY CLUSTERED 
(
	[FeatureId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FeaturesAtPark]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FeaturesAtPark](
	[PFID] [int] IDENTITY(1,1) NOT NULL,
	[PID] [int] NOT NULL,
	[FID] [int] NOT NULL,
 CONSTRAINT [PK_FeaturesAtPark] PRIMARY KEY CLUSTERED 
(
	[PFID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Park]    Script Date: 9/25/2015 4:17:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Park](
	[ParkId] [int] IDENTITY(1,1) NOT NULL,
	[ParkName] [nvarchar](100) NOT NULL,
	[StreetAddress] [nvarchar](100) NOT NULL,
	[City] [nvarchar](100) NOT NULL,
	[County] [nvarchar](100) NULL,
	[ZipCode] [nvarchar](100) NOT NULL,
	[Latitude] [float] NOT NULL CONSTRAINT [DF_Park_Longitude]  DEFAULT ((47.3078759)),
	[Longitude] [float] NOT NULL CONSTRAINT [DF_Park_Latitude]  DEFAULT ((-122.5309605)),
 CONSTRAINT [PK_Park] PRIMARY KEY CLUSTERED 
(
	[ParkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Feature] ON 

INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (1, N'Playground')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (2, N'Hiking')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (3, N'Restrooms')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (4, N'Toddler Playground')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (5, N'Spray Park')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (6, N'Baseball Field')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (7, N'Soccer Field')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (8, N'Disabled Access')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (9, N'Access Fee')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (10, N'Boat Launch')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (11, N'Concessions')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (12, N'Lake')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (13, N'Fishing')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (14, N'Walking Trail')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (15, N'Beach')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (16, N'Tennis Court')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (17, N'Disc golf')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (18, N'River')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (19, N'Pond')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (20, N'Basketball Court')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (21, N'Boat Rentals')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (22, N'Picnic Area')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (23, N'Dock Access')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (24, N'Multi-Purpose Room Rental')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (25, N'Excersize Path')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (26, N'Waterfall')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (27, N'Skate Park')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (28, N'Off Leash Dog Park')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (29, N'Lighted Tennis Courts')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (30, N'Stream or Creek')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (31, N'Bocce Courts')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (32, N'Horse Shoe Pits')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (33, N'Volleyball')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (34, N'Ampitheater')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (35, N'Stage')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (36, N'Zoo')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (37, N'Pool')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (38, N'BBQ/Grill')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (39, N'Wading Pool')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (40, N'Community Garden')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (41, N'Covered Picnic Rental')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (42, N'Monument/Memorial')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (43, N'Museum')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (44, N'Community Center')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (45, N'Senior Center')
INSERT [dbo].[Feature] ([FeatureId], [FeatureName]) VALUES (46, N'Football Field')
SET IDENTITY_INSERT [dbo].[Feature] OFF
SET IDENTITY_INSERT [dbo].[FeaturesAtPark] ON 

INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (1, 2, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (2, 2, 2)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (3, 2, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (4, 2, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (5, 2, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (6, 2, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (7, 2, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (8, 2, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (9, 2, 26)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (10, 2, 30)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (11, 2, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (12, 3, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (13, 3, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (14, 3, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (15, 3, 7)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (16, 3, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (17, 3, 10)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (18, 3, 11)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (19, 3, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (20, 3, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (21, 3, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (22, 3, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (23, 3, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (24, 3, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (25, 3, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (26, 3, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (27, 3, 27)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (28, 3, 29)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (29, 3, 30)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (30, 3, 33)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (31, 3, 35)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (32, 3, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (33, 4, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (34, 4, 2)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (35, 4, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (36, 4, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (37, 4, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (38, 4, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (39, 4, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (40, 4, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (41, 4, 19)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (42, 4, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (43, 4, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (44, 4, 25)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (45, 4, 28)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (46, 4, 30)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (47, 4, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (48, 21, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (49, 21, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (50, 21, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (51, 21, 18)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (52, 21, 27)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (53, 6, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (54, 6, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (55, 6, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (56, 6, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (57, 6, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (58, 6, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (59, 6, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (60, 6, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (61, 6, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (62, 6, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (63, 7, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (64, 7, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (65, 7, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (66, 7, 9)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (67, 7, 10)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (68, 7, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (69, 7, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (70, 7, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (71, 7, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (72, 7, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (73, 7, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (74, 7, 21)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (75, 7, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (76, 7, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (77, 7, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (78, 9, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (79, 9, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (80, 9, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (81, 9, 7)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (82, 9, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (83, 9, 11)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (84, 9, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (85, 9, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (86, 9, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (87, 9, 18)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (88, 9, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (89, 9, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (90, 9, 29)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (91, 9, 33)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (92, 9, 34)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (93, 9, 35)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (94, 9, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (95, 11, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (96, 11, 10)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (97, 11, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (98, 11, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (99, 11, 14)
GO
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (100, 11, 17)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (101, 11, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (102, 13, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (103, 13, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (104, 13, 9)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (105, 13, 10)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (106, 13, 11)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (107, 13, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (108, 13, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (109, 13, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (110, 13, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (111, 14, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (112, 14, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (113, 14, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (114, 14, 5)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (115, 14, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (116, 14, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (117, 14, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (118, 14, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (119, 14, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (120, 14, 19)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (121, 14, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (122, 14, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (123, 14, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (124, 14, 25)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (125, 14, 29)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (126, 14, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (127, 15, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (128, 15, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (129, 15, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (130, 15, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (131, 15, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (132, 15, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (133, 16, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (134, 16, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (135, 16, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (136, 17, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (137, 17, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (138, 17, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (139, 17, 5)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (140, 17, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (141, 17, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (142, 17, 35)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (143, 18, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (144, 18, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (145, 18, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (146, 18, 7)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (147, 18, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (148, 18, 11)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (149, 18, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (150, 18, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (151, 18, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (152, 18, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (153, 20, 2)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (154, 20, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (155, 20, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (156, 20, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (157, 20, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (158, 20, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (159, 20, 25)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (160, 20, 28)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (161, 20, 30)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (162, 48, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (163, 48, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (164, 48, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (165, 48, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (166, 48, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (167, 49, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (168, 49, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (169, 49, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (170, 49, 5)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (171, 49, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (172, 49, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (173, 49, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (174, 49, 19)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (175, 49, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (176, 49, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (177, 49, 31)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (178, 49, 32)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (184, 50, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (185, 50, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (186, 50, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (187, 50, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (188, 50, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (189, 51, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (190, 51, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (191, 54, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (192, 54, 19)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (193, 55, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (194, 55, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (195, 55, 11)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (197, 56, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (198, 56, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (199, 56, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (200, 57, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (219, 58, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (220, 58, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (221, 58, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (222, 58, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (223, 58, 20)
GO
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (224, 58, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (225, 59, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (226, 59, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (227, 59, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (228, 59, 5)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (229, 59, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (230, 59, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (231, 59, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (232, 59, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (233, 59, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (234, 51, 40)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (235, 50, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (236, 50, 42)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (237, 60, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (238, 60, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (239, 60, 7)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (240, 60, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (241, 60, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (242, 60, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (243, 60, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (244, 60, 39)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (245, 60, 44)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (246, 60, 46)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (247, 61, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (248, 61, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (249, 61, 5)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (250, 61, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (251, 61, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (252, 61, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (253, 61, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (254, 62, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (255, 62, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (256, 62, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (257, 62, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (258, 62, 10)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (259, 62, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (260, 62, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (261, 62, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (262, 62, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (263, 62, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (264, 62, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (265, 62, 28)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (266, 62, 38)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (267, 62, 41)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (268, 62, 42)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (269, 63, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (270, 63, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (271, 63, 44)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (272, 64, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (273, 64, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (274, 64, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (275, 64, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (276, 64, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (277, 64, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (278, 64, 41)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (279, 65, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (280, 65, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (281, 65, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (282, 65, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (283, 65, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (284, 65, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (285, 65, 27)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (286, 66, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (287, 66, 30)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (288, 66, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (289, 66, 41)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (290, 67, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (291, 67, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (292, 67, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (293, 67, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (294, 67, 41)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (295, 182, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (296, 182, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (297, 182, 42)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (298, 69, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (299, 69, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (300, 69, 8)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (301, 69, 9)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (302, 69, 10)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (303, 69, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (304, 69, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (305, 69, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (306, 69, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (307, 69, 41)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (308, 70, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (309, 70, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (310, 70, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (311, 70, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (312, 70, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (313, 70, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (314, 70, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (315, 70, 16)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (316, 70, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (317, 70, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (318, 70, 27)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (319, 70, 41)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (320, 71, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (321, 71, 6)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (322, 71, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (323, 71, 20)
GO
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (324, 71, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (325, 72, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (326, 72, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (327, 72, 4)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (328, 72, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (329, 72, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (330, 72, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (331, 73, 1)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (332, 73, 3)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (333, 73, 10)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (334, 73, 12)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (335, 73, 13)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (336, 73, 15)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (337, 73, 20)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (338, 73, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (339, 73, 23)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (340, 73, 24)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (341, 73, 41)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (342, 74, 14)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (343, 74, 22)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (344, 74, 35)
INSERT [dbo].[FeaturesAtPark] ([PFID], [PID], [FID]) VALUES (345, 74, 42)
SET IDENTITY_INSERT [dbo].[FeaturesAtPark] OFF
SET IDENTITY_INSERT [dbo].[Park] ON 

INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (2, N'Wildwood Park', N'1101 23rd Ave SE', N'Puyallup', N'Pierce', N'98374', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (3, N'Allan Yorke Park', N'7203 West Tapps Hwy E', N'Bonney Lake', N'Pierce', N'98391', 47.1897496, -122.1654507)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (4, N'DeCoursey Park', N'1998 7th Ave SW', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (5, N'McFarland Park', N'1391 Chinook Ave', N'Enumclaw', N'King', N'98022', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (6, N'Bradley Lake Park', N'2791 7th St SE', N'Puyallup', N'Pierce', N'98374', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (7, N'Spanaway Park', N'14905 Bresemann Blvd S', N'Spanaway', N'Pierce', N'98387', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (8, N'Veterans Memorial Park', N'411 E Street NE', N'Auburn', N'King', N'98002', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (9, N'Auburn Game Farm Park', N'3030 R St SE', N'Auburn', N'King', N'98002', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (10, N'Mill Creek Earthworks Park', N'1000 Reiten Road', N'Kent', N'King', N'98030', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (11, N'Lake Fenwick Park', N'25828 Lake Fenwick Rd S', N'Kent', N'King', N'98032', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (12, N'Celebration Park', N'1095 S. 324th St', N'Federal Way', N'King', N'98003', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (13, N'Lake Tapps Park', N'198th Ave E', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (14, N'Titlow Park', N'8425 6th Avenue', N'Tacoma', N'Pierce', N'98456', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (15, N'Sam Peach Park', N'1621 10th Ave NW', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (16, N'Grayland Park', N'601 N. Meridian', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (17, N'Pioneer Park', N'Elm Pl & S. Meridian', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (18, N'Puyallup Valley Sports Center', N'820 Valley Ave NW', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (19, N'Rainier Woods Park', N'2310 Cherokee Blvd.', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (20, N'Clark''s Creek', N'~1901 7th Ave SW', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (21, N'Puyallup Skatepark', N'1299 4th St NW', N'Puyallup', N'Pierce', N'98371', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (22, N'Dacca Park Athletic Fields', N'2785 5th Ave E', N'Fife', N'Pierce', N'98424', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (23, N'Wedge Park', N'5920 Valley Ave E', N'Fife', N'Pierce', N'98424', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (24, N'Colburn Park', N'5506 20th St E', N'Fife', N'Pierce', N'98424', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (25, N'Five Acre Park', N'6335 Radiance Blvd E', N'Fife', N'Pierce', N'98424', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (26, N'Hylebos Nature Area', N'6125 8th St E', N'Fife', N'Pierce', N'98424', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (27, N'Glacier View Park', N'Fir Ave N', N'Eatonville', N'Pierce', N'98328', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (28, N'Ashford County Park', N'29801 State Route 706', N'Ashford', N'Pierce', N'98304', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (29, N'Fort Steilacoom Park', N'8714 87th Ave S', N'Lakewood', N'Pierce', N'98498', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (30, N'Sunset Terrace Park', N'Seaview Ave W', N'University Place', N'Pierce', N'98466', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (31, N'China Lake Park', N'1811 S Shirley St', N'Tacoma', N'Pierce', N'98465', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (32, N'Delong Park', N'4702 S 12th Place', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (33, N'Snake Lake Park/Tacoma Nature Center', N'1919 S Tyler St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (34, N'Heidelberg-Davis Park', N'South 19th St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (35, N'Franklin Park', N'S Puget Sound Ave', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (36, N'Jefferson Park', N'North Monroe St', N'Tacoma', N'Pierce', N'98406', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (37, N'War Memorial Park', N'7100 6th Ave', N'Tacoma', N'Pierce', N'98406', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (38, N'Vassault Playfield', N'6298 N 37th St', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (39, N'Baltimore Park', N'4716 N Baltimore St', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (40, N'Rust Park', N'5405 N Commercial St', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (41, N'Point Defiance Park', N'5400 N Pearl St', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (42, N'Marine Park', N'Ruston Way', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (43, N'Puget Creek Natural Area', N'3100 N Proctor St', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (44, N'Dickman Mill Park', N'2423 Ruston Way', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (45, N'Old Town Park', N'2350 N 30th St', N'Tacoma', N'Pierce', N'98403', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (46, N'Gateway Park', N'2101', N'Tacoma', N'Pierce', N'98403', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (47, N'Tacoma Chinese Garden and Reconciliation Park', N'1741 N Schuster Parkway', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (48, N'Garfield Park', N'N Burough Rd', N'Tacoma', N'Pierce', N'98403', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (49, N'Wright Park', N'501 S I St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (50, N'Thea''s Park', N'405 Dock St', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (51, N'Neighbors'' Park', N'722 S I St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (52, N'People''s Park', N'900 Martin Luther King Jr Way', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (53, N'Fireman''s Park', N'A St', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (54, N'Frost Park', N'S 9th St', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (55, N'Peck Field', N'4702 s 19th St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (56, N'Ferry Park', N'1410 14th St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (57, N'Don Pugnetti Park', N'2085 Pacific Ave', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (58, N'Lincoln Park', N'747 Market St', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (59, N'Verlo Playfield', N'907 Upper Park St', N'Tacoma', N'Pierce', N'98404', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (60, N'Portland Avenue Park', N'3513 Portland Ave', N'Tacoma', N'Pierce', N'98404', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (61, N'South Park', N'S Puget Sound Ave', N'Tacoma', N'Pierce', N'98409', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (62, N'Wapato Park', N'6500 S Sheridan Ave', N'Tacoma', N'Pierce', N'98408', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (63, N'Seeley Lake Park', N'9112 Lakewood Dr SW', N'Tacoma', N'Pierce', N'98499', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (64, N'Wards Lake Park', N'84th St Ct S', N'Tacoma', N'Pierce', N'98499', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (65, N'Skate Park', N'Fairlawn Rd SW', N'Tacoma', N'Pierce', N'98499', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (66, N'Kobayashi Park', N'Kobayashi Park Dr', N'University Place', N'Pierce', N'98467', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (67, N'Lakewood Active Park', N'10506 Russell Rd SW', N'Lakewood', N'Pierce', N'98499', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (69, N'American Lake North Park', N'Vernon St and Veteran''s Dr SW', N'Lakewood', N'Pierce', N'98498', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (70, N'Harry Todd Park', N'N Throne Lane SW', N'Lakewood', N'Pierce', N'98498', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (71, N'Forest Park', N'11603 Farwest Dr SW', N'Lakewood', N'Pierce', N'98498', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (72, N'Summer Cove', N'San Antonio Place', N'Fort Lewis', N'Pierce', N'98433', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (73, N'Shoreline Park', N'Shoreline Beach Rd', N'Fort Lewis', N'Pierce', N'98433', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (74, N'Pioneer Orchard Park', N'1700 Commercial St', N'Steilacoom', N'Pierce', N'98388', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (75, N'Sunnyside Beach Park', N'Chambers Creek Rd W', N'Steilacoom', N'Pierce', N'98388', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (76, N'Chamber''s Creek Properties Dog Park', N'Chamber''s Creek Properties', N'University Place', N'Pierce', N'98467', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (77, N'Bresemann Forest', N'8th Ave Ct S', N'Parkland', N'Pierce', N'98444', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (78, N'Sprinker Recreation Center', N'14824 C St S', N'Tacoma', N'Pierce', N'98444', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (79, N'Mayfair County Park', N'13th Ave Ct E', N'Parkland', N'Pierce', N'98445', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (80, N'Fernhill Park', N'502 S 88th St', N'Tacoma', N'Pierce', N'98444', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (81, N'Stewart Heights Park', N'402 E 56th St', N'Tacoma', N'Pierce', N'98404', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (82, N'Gas Station Park', N'4802 S Park Ave', N'Tacoma', N'Pierce', N'98408', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (83, N'Dawson Playfield', N'9000 Portland Ave E', N'Tacoma', N'Pierce', N'98445', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (84, N'Cloverdale Park', N'1635 E 59th St', N'Tacoma', N'Pierce', N'98404', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (85, N'Swan Creek County Park', N'2820 Pioneer Way', N'Tacoma', N'Pierce', N'98404', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (86, N'South Hill Park', N'144th St E', N'South Hill', N'Pierce', N'98373', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (87, N'Orting Dog Park', N'Levee Rd SW', N'Orting', N'Pierce', N'98360', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (88, N'Whitehawk Park', N'Orting Ave NW', N'Orting', N'Pierce', N'98360', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (89, N'Orting Park - North, Central and South', N'Van Scoyoc Ave SW', N'Orting', N'Pierce', N'98360', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (90, N'Orting Skate Park', N'Olive St SE', N'Orting', N'Pierce', N'98360', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (91, N'Orting Lyons Club', N'19725 Orville Rd E', N'Orting', N'Pierce', N'98360', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (92, N'VanderHoof Park', N'SR 410', N'Buckley', N'Pierce', N'98321', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (93, N'Thunderbird Park', N'SR 410', N'Buckley', N'Pierce', N'98321', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (94, N'A Street Park', N'875 Jefferson St', N'Buckley', N'Pierce', N'98321', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (95, N'Elk Heights Park', N'Davis St', N'Buckley', N'Pierce', N'98321', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (96, N'Mountain View Ave Park', N'600 Mountain View Ave', N'Orting', N'Pierce', N'98321', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (97, N'Third Street Park', N'206 3rd St SW', N'South Prairie', N'Pierce', N'98321', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (98, N'Cedarview Park', N'9301 208th Ave E', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (99, N'Ken Simmons Park', N'18200 74th St E', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (100, N'Madrona Park', N'7730 182nd Ave E', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (101, N'Victor Falls Park', N'18212 Rhodes Lake Rd E', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
GO
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (102, N'Viking Park', N'18902 82nd St E', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (103, N'Sprout Holler', N'Village Parkway E', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (104, N'The Edge', N'Canyon View Blvd', N'Bonney Lake', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (105, N'Manorwood Park', N'2310 Manorwood Dr', N'Puyallup', N'Pierce', N'98374', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (106, N'Riverside County Park', N'78th St E', N'Sumner', N'Pierce', N'98390', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (107, N'Loyalty Park', N'1300 Park St', N'Sumner', N'Pierce', N'98390', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (108, N'Daffodil Valley Sports Complex', N'15225 Washington St E', N'Sumner', N'Pierce', N'98390', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (109, N'Reuben A. Knoblauch Heritage Park', N'914 Kincaid Ave', N'Sumner', N'Pierce', N'98391', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (110, N'Rainier View Park', N'15603 Meade McCumber Rd', N'Sumner', N'Pierce', N'98390', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (111, N'Seibenthaller Park', N'1602 Bonney Ave', N'Sumner', N'Pierce', N'98390', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (112, N'Callistoga Park', N'Skinner Rd', N'Orting', N'Pierce', N'98360', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (113, N'Tacoma Narrows Park', N'1502 Lucille Parkway NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (114, N'Sanskie Brothers Park', N'3211 Harborview Dr', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (115, N'Civic Center Green', N'3510 Grandview St', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (116, N'Adam Tallman Park', N'6626 Wagner Way NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (117, N'Wollochet Bay Estuary Park', N'Wollochet Drive NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (118, N'Fox Island Sand Spit', N'Bella Bella Drive FI', N'Fox Island', N'Pierce', N'98333', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (119, N'Fox Island Fishing Pier', N'1453 Ozette Dr FI', N'Fox Island', N'Pierce', N'98333', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (120, N'Hales Pass Park', N'3607 Ray Nash Dr NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (121, N'Kopachuk State Park', N'10712 56th St NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (122, N'Cutts Island State Park', N'Cutts Island', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (123, N'Kenneth Leo Marvin Veterans Memorial Park', N'3580 50th St Ct NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (124, N'City Park at Crescent Creek', N'3303 Vernhardson St', N'Gig Harbor', N'Pierce', N'98332', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (125, N'Eddon Boat Park', N'3805 Harborview Dr', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (126, N'Donkey Creek Park', N'8714 Harborview Dr', N'Gig Harbor', N'Pierce', N'98332', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (127, N'Rosedale Park', N'86th Ave NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (128, N'Sunrise Beach Park', N'10015 Sunrise Beach Dr NW', N'Gig Harbor', N'Pierce', N'98332', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (129, N'Sehmel Homestead Park', N'10123 78th Ave NW', N'Gig Harbor', N'Pierce', N'98332', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (130, N'McCormick Forest Park', N'10301 Bujacich Rd NW', N'Gig Harbor', N'Pierce', N'98332', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (131, N'Rotary Bark Park', N'10100 Bujacich Rd NW', N'Gig Harbor', N'Pierce', N'98332', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (132, N'Tubby''s Trail Dog Park ', N'1701 14th Ave NW', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (133, N'Crescent Lake County Park', N'3510 Grandview St', N'Gig Harbor', N'Pierce', N'98335', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (134, N'Maplewood Park', N'14600 14th Ave NW', N'Gig Harbor', N'Pierce', N'98332', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (135, N'Purdy Sand Spit', N'Washington SR 302', N'Gig Harbor', N'Pierce', N'98329', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (136, N'Penrose Point State Park', N'321 158th Ave KP South', N'Lakebay', N'Pierce', N'98349', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (137, N'Joemma Beach State Park', N'20001 Bay Road KP South', N'Longbranch', N'Pierce', N'98351', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (138, N'Key Peninsula Metro Parks', N'5514 Key Peninsula Highway', N'Lakebay', N'Pierce', N'98349', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (139, N'Springbrook Park', N'12601th St SW', N'Lakewood', N'Pierce', N'98499', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (140, N'Edgewater Park', N'9102 Edgewater Dr SW', N'Lakewood', N'Pierce', N'98499', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (141, N'Christopher Columbus Bocce Courts', N'Forrest Park Dr', N'Fircrest', N'Pierce', N'98466', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (142, N'George Masko Park', N'134 Ramsdell St', N'Fircrest', N'Pierce', N'98466', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (143, N'Homestead Park', N'3715 Bridgeport Way W', N'University Place', N'Pierce', N'98466', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (144, N'Fircrest Park', N'555 Contra Costa Ave', N'Fircrest', N'Pierce', N'98466', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (145, N'Cirque Bridgeport Park', N'7250 Cirque Dr W', N'University Place', N'Pierce', N'98466', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (146, N'Millpond Park', N'Alder St E', N'Eatonville', N'Pierce', N'98328', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (147, N'Pacific City Park', N'600 3rd Ave SE', N'Pacific', N'King', N'98047', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (148, N'Frontier Park', N'21718 Meridian Ave E', N'Graham', N'Pierce', N'98338', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (149, N'Sunrise Visitor Center', N'Sunrise Park Rd', N'Ashford', N'Pierce', N'98304', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (150, N'Henry M Jackson Visitor Center', N'39000 WA-706', N'Ashford', N'Pierce', N'98304', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (151, N'Alderwood Park', N'208 Browns Point Blvd', N'Tacoma', N'Pierce', N'98422', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (152, N'Alling Park', N'1134 S. 60th St.', N'Tacoma', N'Pierce', N'98408', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (153, N'Browns Point Athletic Complex', N'1526 51st St NE', N'Tacoma', N'Pierce', N'98422', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (154, N'Brown''s Point Lighthouse Park', N'201 Tulalip St NE', N'Tacoma', N'Pierce', N'98422', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (155, N'Browns Point Playfield', N'4915 La Hal Da Lane NE', N'Tacoma', N'Pierce', N'98422', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (156, N'Cumming''s Park', N'3939 Ruston Way', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (157, N'Dash Point Park', N'1500 Beach Dr NE', N'Tacoma', N'Pierce ', N'98422', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (158, N'Hamilton Park', N'321 Ruston Way', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (159, N'Irving Park', N'2502 Hosmer St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (160, N'Jack Hyde Park', N'2201 Ruston Way', N'Tacoma', N'Pierce', N'98402', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (161, N'Jane Clark Park', N'4825 N 39th St', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (162, N'Kandle Park', N'2323 N Shirley St', N'Tacoma', N'Pierce', N'98406', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (163, N'Lincoln Heights Park', N'3690 S. Steele St', N'Tacoma', N'Pierce', N'98409', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (164, N'Lots for Tots', N'1216 South I St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (165, N'Manitou Park', N'4408 American Lake Blvd', N'Tacoma', N'Pierce', N'98409', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (166, N'McCarver Park', N'2301 South J St', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (167, N'Norpoint', N'4818 Nassau Ave NE', N'Tacoma', N'Pierce', N'98422', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (168, N'North Slope Historic District Park', N'1015 N 85th St', N'Tacoma', N'Pierce', N'98403', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (169, N'Northeast Tacoma Playground', N'5520 29th St NE', N'Tacoma', N'Pierce', N'98422', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (170, N'Oakland Madrona Park', N'3114 S Madison St', N'Tacoma', N'Pierce', N'98409', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (171, N'Optimist Park', N'1330 N James St', N'Tacoma', N'Pierce', N'98406', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (172, N'Puget Park', N'3111 N. Proctor St', N'Tacoma', N'Pierce', N'98407', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (173, N'Rogers Park', N'3151 East L St', N'Tacoma', N'Pierce', N'98404', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (174, N'Roosevelt Park', N'3601 E Roosevelt Ave', N'Tacoma', N'Pierce', N'98404', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (175, N'Ryan''s Park', N'429 S. 80th St', N'Tacoma', N'Pierce', N'98408', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (176, N'Sawyer Tot Lot', N'3315 S. Sawyer St', N'Tacoma', N'Pierce', N'98418', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (177, N'Sheridan Park', N'2347 S. Sheridan Ave', N'Tacoma', N'Pierce', N'98405', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (178, N'South End Recreation and Adventure (SERA)', N'6002 S. Adam St', N'Tacoma', N'Pierce', N'98409', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (179, N'Ursich Park', N'2412 N. 29th St', N'Tacoma', N'Pierce', N'98403', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (180, N'Wapato Hills Park', N'6231 S. Wapato St', N'Tacoma', N'Pierce', N'98409', 47.3078759, -122.5309605)
INSERT [dbo].[Park] ([ParkId], [ParkName], [StreetAddress], [City], [County], [ZipCode], [Latitude], [Longitude]) VALUES (182, N'Lakewold Garden''s', N'12317 Gravelly Lake Dr SW', N'Lakewood', N'Pierce', N'98499', -122.5369351, 47.1461544)
SET IDENTITY_INSERT [dbo].[Park] OFF
ALTER TABLE [dbo].[FeaturesAtPark]  WITH CHECK ADD  CONSTRAINT [FK_FeaturesAtPark_Feature] FOREIGN KEY([FID])
REFERENCES [dbo].[Feature] ([FeatureId])
GO
ALTER TABLE [dbo].[FeaturesAtPark] CHECK CONSTRAINT [FK_FeaturesAtPark_Feature]
GO
ALTER TABLE [dbo].[FeaturesAtPark]  WITH CHECK ADD  CONSTRAINT [FK_FeaturesAtPark_Park] FOREIGN KEY([PID])
REFERENCES [dbo].[Park] ([ParkId])
GO
ALTER TABLE [dbo].[FeaturesAtPark] CHECK CONSTRAINT [FK_FeaturesAtPark_Park]
GO
USE [master]
GO
ALTER DATABASE [thePPF] SET  READ_WRITE 
GO
