-- Demo 1 in Module 5 on Concurrency
-- Attach the AdventureworksLT database
-- Copy AdventureworksLT_Data.mdf in to the C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA folder
CREATE DATABASE AdventureworksLT ON 
	(FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureworksLT_Data.mdf')
	FOR ATTACH_REBUILD_LOG;
GO
-- Set READ_COMMITTED_SNAPSHOT and ALLOW_SNAPSHOT_ISOLATION to ON for the AdventureworksLT database
ALTER DATABASE AdventureworksLT SET READ_COMMITTED_SNAPSHOT ON
GO
ALTER DATABASE AdventureworksLT SET ALLOW_SNAPSHOT_ISOLATION ON
GO