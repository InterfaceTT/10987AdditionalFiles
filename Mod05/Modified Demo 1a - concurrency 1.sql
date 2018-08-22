-- Module 5 Modified Demonstration 1 File 1

-- Step 1: Switch this query window to use your copy of the AdventureWorksLT database

-- Step 2: Switch the Demo 1b - concurrency 2.sql query to use your copy of the AdventureWorksLT database

-- Step 3: Demonstrate the settings for ALLOW_SNAPSHOT_ISOLATION and READ_COMMITTED_SNAPSHOT 
SELECT name, snapshot_isolation_state, is_read_committed_snapshot_on FROM sys.databases;

-- Step 4: Examine the row the examples will change
-- The value of the Phone column is 170-555-0127
SELECT CustomerID, Phone FROM SalesLT.Customer WHERE CustomerID = 2;

-- Step 5: Demonstrate a dirty read in READ UNCOMMITTED isolation
-- Execute QUERY 1 Update to 999-555-999
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO
SELECT CustomerID, Phone 
FROM SalesLT.Customer
WHERE CustomerID = 2;
GO

-- Step 6: Demonstrate Writer blocks reader when READ COMMITTED isolation with READ_COMMITTED_SNAPSHOT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
SELECT CustomerID, Phone 
FROM SalesLT.Customer WITH (READCOMMITTEDLOCK) -- Turns off Read Committed Snapshot
WHERE CustomerID = 2;
GO
-- Execute QUERY 2 Rollback

-- Step 7: Demonstrate Non-Repeatable Read when READ COMMITTED isolation with READ_COMMITTED_SNAPSHOT OFF
-- Run the following statements
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer WITH (READCOMMITTEDLOCK)
	WHERE CustomerID = 2;

-- Execute QUERY 3  Update to 333-555-333
-- Run the following query. Note that the value of the Phone column has changed during the transaction
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer WITH (READCOMMITTEDLOCK)
	WHERE CustomerID = 2;
COMMIT

-- Step 8: Demonstrate that REPEATABLE READ isolation prevents a non-repeatable read
-- Run the following statements
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
BEGIN TRANSACTION
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer
	WHERE CustomerID = 2;

-- Execut QUERY 4 Update to 444-555-4444
-- Update is blocked
-- Run the following query. Note that the value of the Phone column has not changed during the transaction

	SELECT CustomerID, Phone 
	FROM SalesLT.Customer
	WHERE CustomerID = 2;
COMMIT
-- QUERY 4 Completes

-- Step 9: Demonstrate that REPEATABLE READ isolation allows a Insert in Range
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
GO
BEGIN TRANSACTION
	SELECT COUNT(*) AS CustCount 
	FROM SalesLT.Customer
	WHERE Phone < '111-555-2222';

-- Execute QUERY 5 Insert Row with 111-555-1111
-- Run the following query. Note that the value of the count has increased by one
	SELECT COUNT(*) AS CustCount 
	FROM SalesLT.Customer
	WHERE Phone < '111-555-2222';
COMMIT

-- Step 10: Demonstrate that SERIALIZABLE isolation prevents an Insert in Range
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
	SELECT COUNT(*) AS CustCount 
	FROM SalesLT.Customer
	WHERE Phone < '111-555-2222';

-- Execute QUERY 5 Insert Row with 111-555-1111
-- Insert is blocked
-- Run the following query. Note that the value of the count matches the first query
	SELECT COUNT(*) AS CustCount 
	FROM SalesLT.Customer
	WHERE Phone < '111-555-2222';
COMMIT
-- QUERY 5 Completes

-- Step 11: Demonstrate READ COMMITTED SNAPSHOT in READ COMMITTED isolation 
-- Reset the Phone value for customerID = 2
UPDATE SalesLT.Customer SET Phone = N'170-555-0127' WHERE CustomerID = 2
GO
-- Execute QUERY 6 Update to 616-555-6161
-- Note that the committed value of the row is returned
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO
BEGIN TRANSACTION 
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer
	WHERE CustomerID = 2;

-- Execute QUERY 7 Commit 
-- Execute the following statements. Note that the updated value of the row is returned
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer
	WHERE CustomerID = 2;
COMMIT

-- Step 12: Demonstrate SNAPSHOT isolation
-- Reset the Phone value for customerID = 2
UPDATE SalesLT.Customer SET Phone = N'170-555-0127' WHERE CustomerID = 2
GO
-- Execute QUERY 6 Update to 616-555-6161
-- run the following statements. Note that the committed value of the row is returned
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
GO
BEGIN TRANSACTION 
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer
	WHERE CustomerID = 2;

-- Execute QUERY 7 Commit 
-- Execute the following statements. Note that the original value of the row is still returned
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer
	WHERE CustomerID = 2;
COMMIT

-- Step 13: Demonstrate an update conflict in SNAPSHOT isolation:
-- Reset the Phone value for customerID = 2
UPDATE SalesLT.Customer SET Phone = N'170-555-0127' WHERE CustomerID = 2
GO
-- Execute QUERY 6 Update to 616-555-6161
-- Note that the committed value of the row is returned
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
GO
BEGIN TRANSACTION 
	SELECT CustomerID, Phone 
	FROM SalesLT.Customer
	WHERE CustomerID = 2;

	UPDATE SalesLT.Customer
	SET Phone = N'777-555-7777'
	WHERE CustomerID = 2;

-- Execute QUERY 7 Commit
-- Note the error message

-- Execute the following statement to show that the transaction was aborted
SELECT @@TRANCOUNT;


