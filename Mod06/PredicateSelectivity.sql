-- Query Predicate Selectivity
SELECT EventDateTime
, count(*) counter
FROM sales.OrderTracking
GROUP BY EventDateTime
ORDER BY 1

CREATE INDEX IX_OrderTracking_EventDateTime ON Sales.OrderTracking(EventDateTime);

DBCC SHOW_STATISTICS('sales.ordertracking', 'IX_OrderTracking_EventDateTime')

SELECT [OrderTrackingID]
      ,[SalesOrderID]
      ,[CarrierTrackingNumber]
      ,[TrackingEventID]
      ,[EventDetails]
      ,[EventDateTime]
  FROM [AdventureWorks].[Sales].[OrderTracking]
  WHERE EventDateTime BETWEEN '2011-07-10' AND '2011-07-31'

SELECT [OrderTrackingID]
	  ,[SalesOrderID]
      ,[CarrierTrackingNumber]
      ,[TrackingEventID]
      ,[EventDetails]
      ,[EventDateTime]
  FROM [AdventureWorks].[Sales].[OrderTracking]
  WHERE EventDateTime BETWEEN '2014-03-31' AND '2014-04-01'

SELECT [OrderTrackingID]
      ,[SalesOrderID]
      ,[CarrierTrackingNumber]
      ,[TrackingEventID]
      ,[EventDetails]
      ,[EventDateTime]
  FROM [AdventureWorks].[Sales].[OrderTracking]
  WHERE EventDateTime BETWEEN '2014-03-31' AND '2014-04-01'
  AND CarrierTrackingNumber = '410B211-69F0-4D29-86ED-A2