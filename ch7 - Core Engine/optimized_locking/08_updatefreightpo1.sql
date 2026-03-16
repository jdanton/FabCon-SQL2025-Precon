USE AdventureWorks;
GO

/*


This updates freight for orders with odd-numbered purchase order numbers.

Execute only the first batch up to the GO statement. Leave the transaction open.

Show locks, run 09 script during this. 

*/
-- Update a specific purchase order number
DECLARE @minsalesorderid INT;
SELECT @minsalesorderid = MIN(SalesOrderID) FROM Sales.SalesOrderHeader;
BEGIN TRAN;
UPDATE Sales.SalesOrderHeader
SET Freight = Freight * .10
WHERE PurchaseOrderNumber = 'PO522145787';
GO

-- Rollback transaction if needed
ROLLBACK TRAN;
GO

