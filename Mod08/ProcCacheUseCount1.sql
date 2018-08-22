/*Objtypes
Prepared - Adhoc queries that have defined parameters
Adhoc - Adhoc queries that have no defined parameters
Proc - Stored Procedure
ReplProc - Replication filter procedures
Trigger - Plans associated to Triggers
View - Parse tree generated for a view
Default - Parse tree generated for a default value
Check - Parse tree to generated for check constraints
UsrTab - Parse tree for a user table
SysTab - Parse tree for a system table
*/

SELECT  objtype AS [CacheType]
      , COUNT_BIG(*) AS [Total Plans]
      , SUM(CAST(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs]
      , AVG(usecounts) AS [Avg Use Count]
      , SUM(usecounts) AS [Total Use Count]
      , SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes
                       ELSE 0
                       END) AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs - USE Count 1]
      , SUM(CASE WHEN usecounts = 1 THEN 1
                 ELSE 0
                 END) AS [Total Plans - USE Count 1]
FROM    sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs - USE Count 1] DESC
GO

--DBCC FreeProcCache

-- Detail from the Procedure Cache
SELECT 
        st.text
      , cp.cacheobjtype
      , cp.objtype
      , cp.refcounts
      , cp.usecounts
      , cp.size_in_bytes
      , cp.bucketid
      , cp.plan_handle
FROM    sys.dm_exec_cached_plans cp
OUTER APPLY sys.dm_exec_sql_text(cp.plan_handle) st
ORDER BY cp.usecounts DESC

go

