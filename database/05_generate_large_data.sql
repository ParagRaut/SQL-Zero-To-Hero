/*==============================================================
  TechShop — Step 5 (OPTIONAL): Generate LARGE data
  Run this before the performance modules (16–20) so that
  execution plans, indexes and STATISTICS IO show real
  differences. Without volume, SQL Server just scans everything
  and you can't "see" why indexes matter.

  This ADDS:
    +50,000 customers
    +500,000 orders
    +~1,000,000 order items

  Runs set-based (fast). Expect a few seconds to a minute.
  Safe to run once; running again appends more rows.
  ==============================================================*/

USE TechShop;
GO
SET NOCOUNT ON;

PRINT 'Generating large data... this inflates the tables for perf testing.';

/*---------- Numbers/tally table (in-memory) ----------*/
;WITH
 L0 AS (SELECT 1 AS c UNION ALL SELECT 1),
 L1 AS (SELECT a.c FROM L0 a CROSS JOIN L0 b),           -- 4
 L2 AS (SELECT a.c FROM L1 a CROSS JOIN L1 b),           -- 16
 L3 AS (SELECT a.c FROM L2 a CROSS JOIN L2 b),           -- 256
 L4 AS (SELECT a.c FROM L3 a CROSS JOIN L3 b),           -- 65,536
 L5 AS (SELECT a.c FROM L4 a CROSS JOIN L4 b),           -- ~4.29 billion
 Nums AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n FROM L5)
SELECT n INTO #Numbers FROM Nums WHERE n <= 500000;
CREATE UNIQUE CLUSTERED INDEX IX_Num ON #Numbers(n);

/*---------- 50,000 extra customers ----------*/
INSERT INTO dbo.Customers (FirstName, LastName, Email, Phone, City, Country)
SELECT
    'Cust' + CAST(n AS VARCHAR(10)),
    'User'  + CAST(n AS VARCHAR(10)),
    'cust' + CAST(n AS VARCHAR(10)) + '@techshop-demo.com',
    NULL,
    CHOOSE((n % 8) + 1,'New York','London','Berlin','Toronto','Bengaluru','Sydney','Tokyo','Paris'),
    CHOOSE((n % 8) + 1,'USA','UK','Germany','Canada','India','Australia','Japan','France')
FROM #Numbers
WHERE n <= 50000;

DECLARE @minCust INT = (SELECT MIN(CustomerID) FROM dbo.Customers);
DECLARE @maxCust INT = (SELECT MAX(CustomerID) FROM dbo.Customers);
DECLARE @maxProd INT = (SELECT MAX(ProductID)  FROM dbo.Products WHERE Discontinued = 0);

/*---------- 500,000 orders ----------*/
INSERT INTO dbo.Orders (CustomerID, EmployeeID, OrderDate, Status, ShipCity, ShipCountry)
SELECT
    @minCust + (ABS(CHECKSUM(NEWID())) % (@maxCust - @minCust + 1)),
    ((n % 4) + 5),
    DATEADD(DAY, -(ABS(CHECKSUM(n)) % 1095), CAST('2026-06-30' AS DATE)),  -- last 3 years
    CHOOSE((n % 5) + 1,'Delivered','Shipped','Paid','Delivered','Cancelled'),
    'City' + CAST((n % 100) AS VARCHAR(4)),
    CHOOSE((n % 5) + 1,'USA','UK','Germany','India','Japan')
FROM #Numbers
WHERE n <= 500000;

/*---------- ~1,000,000 order items (1–2 per new order) ----------*/
DECLARE @firstBigOrder INT = (SELECT MAX(OrderID) - 500000 + 1 FROM dbo.Orders);

INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice, Discount)
SELECT o.OrderID,
       p.ProductID,
       (ABS(CHECKSUM(o.OrderID, v.slot)) % 3) + 1,
       p.UnitPrice,
       0
FROM dbo.Orders o
CROSS APPLY (VALUES (0),(1)) AS v(slot)
CROSS APPLY (
    SELECT TOP 1 ProductID, UnitPrice
    FROM dbo.Products
    WHERE Discontinued = 0
      AND ProductID = (ABS(CHECKSUM(o.OrderID, v.slot)) % @maxProd) + 1
) p
WHERE o.OrderID >= @firstBigOrder
  AND (v.slot = 0 OR (o.OrderID % 2 = 0));   -- 1 or 2 items

DROP TABLE #Numbers;

SELECT 'Customers' AS TableName, COUNT(*) AS Rows FROM dbo.Customers
UNION ALL SELECT 'Orders', COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderItems', COUNT(*) FROM dbo.OrderItems;

PRINT 'Large data generated. Now the perf/index modules will be meaningful.';
GO
