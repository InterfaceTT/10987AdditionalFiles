-- Module 7 - Demo 1

USE AdventureWorks;
GO

-- Step 1 - query simplification 1
-- Highlight this query and generate an estimated execution plan (Ctrl+L)
-- Note that a reference to Sales.SalesOrderHeader does not appear in the plan
-- The foreign key from Sales.SalesOrderDetail to Sales.SalesOrderHeader means that no rows can exist which do not meet the
-- JOIN criteria, so the reference is eliminated.
SELECT pp.Name
FROM Production.Product pp 
JOIN Sales.SalesOrderDetail ss
ON pp.ProductID=ss.ProductID
JOIN Sales.SalesOrderHeader oh
ON ss.SalesOrderID=oh.SalesOrderID;

-- Step 2 - query simplification 2
-- Highlight this query and generate an estimated execution plan (Ctrl+L)
-- Note that no reference to the table appears in the plan at all. 
-- HumanResources.Employee.SickLeaveHours has a constraint which limits the value to less than 120 hours,
-- so no rows can ever fulfil this filter, and the query is simplified
SELECT * FROM HumanResources.Employee WHERE SickLeaveHours = 500;

-- view the check constraint with the following query:
SELECT CHECK_CLAUSE FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_NAME = 'CK_Employee_SickLeaveHours'

-- Step 3 - Trivial plan
-- Enable Actual Execution Plan (Ctrl+M), then execute the following query.
-- On the Execution plan tab in the results pane, right-click the left-most operator (SELECT cost 0%) 
-- and click Properties (keyboard F4).
-- In the Properties pane, notice that the "Optimization Level" attribute has the value "TRIVIAL"
SELECT * FROM HumanResources.Employee;

-- Step 4 - Transformation Rules
-- Execute all the code for this step in one go
-- The results will show the transformation rules in sys.dm_exec_query_transformation_stats
-- which were used in compiling a plan for the SELECT statement.

DROP TABLE IF EXISTS #snapshot
DROP TABLE IF EXISTS #result

SELECT *
INTO #snapshot
FROM sys.dm_exec_query_transformation_stats;

--This is the statement we are interested in results for
SELECT pp.ProductID, Count(*) ProductCount 
INTO #result
FROM Production.Product pp 
INNER JOIN Sales.SalesOrderDetail ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10
GROUP BY pp.ProductID
OPTION (RECOMPILE);

SELECT  QTS.name,
        promise = QTS.promised - S.promised,
        promise_value_avg = 
            CASE
                WHEN QTS.promised = S.promised
                    THEN 0
                ELSE
                    (QTS.promise_total - S.promise_total) /
                    (QTS.promised - S.promised)
            END,
        built = QTS.built_substitute - S.built_substitute,
        success = QTS.succeeded - S.succeeded
FROM    #Snapshot S
JOIN    sys.dm_exec_query_transformation_stats QTS
        ON QTS.name = S.name
WHERE   QTS.succeeded != S.succeeded
ORDER   BY
        promise_value_avg DESC
OPTION  (KEEPFIXED PLAN);

-- Name is the transformation rule
-- Number of times the rule was asked for a promise value
-- Promise Value is an internal assessment of the Value of the transformation 
--    Commonly used transformations have higher value
-- Avg Promise value returned when requested
-- Built is the number of times the rule produced an alternative implementation
-- Success is the number of the rule generated a tranformation that was added to space 
--    of valid alternative strategies.  May still not be used.

--End Step 4

-- Step 5 adding a query hint to use a stream aggregate

DROP TABLE IF EXISTS #snapshot
DROP TABLE IF EXISTS #result

SELECT *
INTO #snapshot
FROM sys.dm_exec_query_transformation_stats;

--This is the statement we are interested in results for
SELECT pp.ProductID, Count(*) ProductCount 
INTO #result
FROM Production.Product pp 
INNER JOIN Sales.SalesOrderDetail ss
ON pp.ProductID=ss.ProductID
WHERE ss.OrderQty > 10
GROUP BY pp.ProductID
OPTION (RECOMPILE, ORDER GROUP);

SELECT  QTS.name,
        promise = QTS.promised - S.promised,
        promise_value_avg = 
            CASE
                WHEN QTS.promised = S.promised
                    THEN 0
                ELSE
                    (QTS.promise_total - S.promise_total) /
                    (QTS.promised - S.promised)
            END,
        built = QTS.built_substitute - S.built_substitute,
        success = QTS.succeeded - S.succeeded
FROM    #Snapshot S
JOIN    sys.dm_exec_query_transformation_stats QTS
        ON QTS.name = S.name
WHERE   QTS.succeeded != S.succeeded
ORDER   BY
        promise_value_avg DESC
OPTION  (KEEPFIXED PLAN);