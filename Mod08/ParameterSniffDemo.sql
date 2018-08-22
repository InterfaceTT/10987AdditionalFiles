USE Adventureworks
GO

CREATE INDEX ix_SalesOrderHeader_OrderDate ON Sales.SalesOrderHeader(OrderDate)
GO 

CREATE PROCEDURE dbo.OrdersByDates @Start_Date datetime, @End_Date datetime
AS
SELECT *
FROM sales.salesorderheader 
WHERE OrderDate BETWEEN @Start_Date AND @End_Date
GO

CREATE PROCEDURE dbo.OrdersByDatesVar @Start_Date datetime, @End_Date datetime
AS
DECLARE @Var_Start_Date datetime, 
	@Var_End_Date datetime
SET @Var_Start_Date = @Start_Date
SET @Var_End_Date = @End_Date
SELECT *
FROM sales.salesorderheader 
WHERE OrderDate BETWEEN @Var_Start_Date AND @Var_End_Date
GO
DBCC FREEPROCCACHE
-- Turn on Actual Execution Plan
SET STATISTICS IO ON
-- Execute the next batch and review the Logical IO count  (Very Different)
-- Also compare the Estimated Number of rows vs Actual in both Execution Plans 
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2013'
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2014'
GO

-- Execute the next batch and review the Logical IO count (the same)
-- Also compare the Estimated Number of rows vs Actual in both Execution Plans 
-- Review rows returned in Execution Plans last step
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2014'
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2013'
GO

-- Plans are always same, conservative
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2013' 
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2014'
GO
-- The same no matter what the sequence
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2013' 
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2014'
GO

-- Add with Recompile to the Execution
-- Execute the next batch and review the Logical IO count  (Very Different)
-- Also compare the Estimated Number of rows vs Actual in both Execution Plans 
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2013' WITH RECOMPILE
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2014' WITH RECOMPILE
GO

-- Execute the next batch and review the Logical IO count (the same)
-- Also compare the Estimated Number of rows vs Actual in both Execution Plans 
-- Review rows returned in Execution Plans last step
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2014' WITH RECOMPILE
EXEC dbo.OrdersbyDates @Start_Date = '7/1/2013', @End_Date = '7/1/2013' WITH RECOMPILE
GO

-- Plans are always same, conservative
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2013' WITH RECOMPILE 
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2014' WITH RECOMPILE
GO
-- The same no matter what the sequence
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2013' WITH RECOMPILE 
EXEC dbo.OrdersbyDatesVar @Start_Date = '7/1/2013', @End_Date = '7/1/2014' WITH RECOMPILE
GO


-- Create a version of the Variable version using Statement Level recompile
CREATE PROCEDURE dbo.OrdersByDatesVarSComp @Start_Date datetime, @End_Date datetime
AS
DECLARE @Var_Start_Date datetime, 
	@Var_End_Date datetime
SET @Var_Start_Date = @Start_Date
SET @Var_End_Date = @End_Date
SELECT *
FROM sales.salesorderheader 
WHERE OrderDate BETWEEN @Var_Start_Date AND @Var_End_Date
OPTION(RECOMPILE)
GO


-- Statement Level recompile sniffed the Variables
EXEC dbo.OrdersbyDatesVarScomp @Start_Date = '7/1/2013', @End_Date = '7/1/2013' 
EXEC dbo.OrdersbyDatesVarScomp @Start_Date = '7/1/2013', @End_Date = '7/1/2014'
GO

EXEC dbo.OrdersbyDatesVarScomp @Start_Date = '7/1/2013', @End_Date = '7/1/2013' 
EXEC dbo.OrdersbyDatesVarScomp @Start_Date = '7/1/2013', @End_Date = '7/1/2014'
GO


-- Clean up
DROP INDEX IX_SalesOrderHeader_OrderDate ON Sales.SalesOrderHeader
DROP PROCEDURE dbo.OrdersByDates
DROP PROCEDURE dbo.OrdersByDatesVar
DROP PROCEDURE dbo.OrdersByDatesVarScomp