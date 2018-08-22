-- Module 7 - Demo 3

USE AdventureWorks;
GO
-- Step 1 - Query plan with parallelism and warnings
-- Highlight the code for this step and type Ctrl + L (or click Query then click Display Estimated Execution Plan)
-- Note the warning indicator
SELECT *
FROM master.dbo.spt_values AS a
CROSS JOIN master.dbo.spt_values AS b;

-- Step 2 - comparing query plans with SSMS
-- Right-click the plan generated in step 1, then click Compare Showplan
-- In the Open dialog box, select D:\Demofiles\Mod07\demo2_step3.sqlplan.
-- Click Open. The two plans will be displayed together.

-- Step 3 - illustrating that different T-SQL statements may generate the same plan
-- Generate an estimated execution plan for both statements below. (Ctrl+L)
-- Demonstrate that both statements have the same estimated query plan
-- Enable the actual execution plan and execute both statements. (Ctrl+M)
-- Demonstrate that the actual execution plans are the same.
-- Note the warning on the Clustered Index Seek of the Orders table (no statistics)
-- Also note the discrepancy between the actual and estimated number of rows for the Clustered Index Seek of the Orders table.
--  This is caused because the Nested Loops join ran the lower seach once for each row in the upper search.
SELECT o.orderid, o.orderdate,
od.productid, od.unitprice, od.qty 
FROM TSQL.Sales.Orders AS o 
INNER JOIN TSQL.Sales.OrderDetails AS od 
ON o.orderid = od.orderid ; 


SELECT o.orderid, o.orderdate,
od.productid, od.unitprice, od.qty 
FROM TSQL.Sales.Orders AS o
CROSS APPLY (	SELECT productid, unitprice, qty 
				FROM TSQL.Sales.OrderDetails AS so 
				WHERE so.orderid = o.orderid
			) AS od;


-- Step 4 - resolving the warning found in step 3
-- run the statement below, then regenerate an estimated execution plan for the statements in step 3
-- Notice that the missing statistics warning is no longer shown
CREATE STATISTICS Orders_OrderId
    ON TSQL.Sales.Orders (orderid)
    WITH FULLSCAN

-- Step 5 - Adding an index to get a better execution plan
-- Execute the query below to examime the actual query plan. Note the Estimated Subtree Cost from the SELECT operator
-- Also note the missing index suggestion.
SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice
FROM Production.Product AS pp 
JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10

-- Step 6 - Create a covering index
-- Execute the following statement to create a covering index
CREATE NONCLUSTERED INDEX ix_SalesOrderDetail_OrderQty
ON Sales.SalesOrderDetail (OrderQty)
INCLUDE (ProductID,UnitPrice)

-- Code to drop the index, should you need to
--DROP INDEX Sales.SalesOrderDetail.ix_SalesOrderDetail_OrderQty

-- Step 7 - re-run the query
-- note that the subtree cost of the actual execution plan has gone down
SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice
FROM Production.Product AS pp 
INNER JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10


-- Compare previous query with higher selectivity on the OrderQty value
-- and adding a non-covered column to output.
SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice
FROM Production.Product AS pp 
INNER JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 20

SELECT 
	pp.Name,
	pp.ProductLine,
	ss.UnitPrice,
	ss.CarrierTrackingNumber
FROM Production.Product AS pp 
INNER JOIN Sales.SalesOrderDetail AS ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 20


-- Try different join hints to see why it selected Merge Join