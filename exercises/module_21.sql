/*==============================================================
  Module 21 — Advanced T-SQL Toolkit
  Topics: PIVOT/UNPIVOT, conditional aggregation, APPLY,
          GROUPING SETS/ROLLUP/CUBE, JSON, STRING_AGG/STRING_SPLIT,
          dynamic SQL & injection safety.
  ==============================================================*/

USE TechShop;
GO

-- 21.1  Conditional aggregation (the "manual pivot" — often clearest).
--       Order counts per country, split by status, in one row per country.
SELECT
    ShipCountry,
    SUM(CASE WHEN Status = 'Paid'      THEN 1 ELSE 0 END) AS Paid,
    SUM(CASE WHEN Status = 'Shipped'   THEN 1 ELSE 0 END) AS Shipped,
    SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS Delivered
FROM dbo.Orders
GROUP BY ShipCountry;

-- 21.2  PIVOT — same idea with the built-in operator.
SELECT ShipCountry, [Paid], [Shipped], [Delivered]
FROM (
    SELECT ShipCountry, Status FROM dbo.Orders
) src
PIVOT (
    COUNT(Status) FOR Status IN ([Paid], [Shipped], [Delivered])
) pvt;

-- 21.3  CROSS APPLY — call a table expression per outer row (like a join to a
--       function). Here: the top 2 most expensive products per category.
SELECT c.CategoryName, t.ProductName, t.UnitPrice
FROM dbo.Categories c
CROSS APPLY (
    SELECT TOP (2) p.ProductName, p.UnitPrice
    FROM   dbo.Products p
    WHERE  p.CategoryID = c.CategoryID
    ORDER BY p.UnitPrice DESC
) t;

-- 21.4  GROUPING SETS / ROLLUP / CUBE — multiple aggregation levels at once.
SELECT ShipCountry, Status, COUNT(*) AS Orders
FROM dbo.Orders
GROUP BY ROLLUP (ShipCountry, Status);   -- per country+status, per country, grand total

-- 21.5  STRING_AGG — concatenate group values into one delimited string.
SELECT CategoryID,
       STRING_AGG(ProductName, ', ') WITHIN GROUP (ORDER BY ProductName) AS Products
FROM dbo.Products
GROUP BY CategoryID;

-- 21.6  STRING_SPLIT — turn a delimited string into rows.
SELECT value AS Tag
FROM STRING_SPLIT('sql,index,tuning', ',');

-- 21.7  JSON — shape a result as JSON, and parse JSON back into rows.
SELECT TOP (3) ProductID, ProductName, UnitPrice
FROM dbo.Products
FOR JSON PATH;                              -- serialize rows to JSON

DECLARE @j NVARCHAR(MAX) = N'[{"id":1,"name":"A"},{"id":2,"name":"B"}]';
SELECT * FROM OPENJSON(@j)
WITH (id INT '$.id', name NVARCHAR(50) '$.name');   -- parse JSON to a table

-- 21.8  Dynamic SQL — build SQL at runtime. ALWAYS parameterize with
--       sp_executesql to prevent SQL injection. NEVER concatenate user input.
DECLARE @country NVARCHAR(50) = 'Germany';         -- pretend this is user input
DECLARE @sql NVARCHAR(MAX) =
    N'SELECT CustomerID, FirstName, LastName
      FROM dbo.Customers WHERE Country = @c;';      -- @c is a real parameter
EXEC sys.sp_executesql @sql, N'@c NVARCHAR(50)', @c = @country;
--  ❌ NEVER do: EXEC('... WHERE Country = ''' + @country + '''');  -- injectable!

/*---------------- YOUR TURN ----------------
  a) Using conditional aggregation, count orders per ShipCountry split into
     'Cancelled' vs 'NotCancelled'.
  b) With CROSS APPLY, list each customer's single most recent order.
  c) Use STRING_AGG to list, per supplier, all product names they supply.
  d) Rewrite this INJECTABLE snippet safely with sp_executesql:
        EXEC('SELECT * FROM dbo.Products WHERE ProductName = ''' + @name + '''');
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT ShipCountry,
            SUM(CASE WHEN Status='Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
            SUM(CASE WHEN Status<>'Cancelled' THEN 1 ELSE 0 END) AS NotCancelled
     FROM dbo.Orders GROUP BY ShipCountry;
  b) SELECT cu.CustomerID, t.OrderID, t.OrderDate
     FROM dbo.Customers cu
     CROSS APPLY (SELECT TOP (1) o.OrderID, o.OrderDate FROM dbo.Orders o
                  WHERE o.CustomerID = cu.CustomerID ORDER BY o.OrderDate DESC) t;
  c) SELECT s.SupplierName,
            STRING_AGG(p.ProductName, ', ') AS Products
     FROM dbo.Suppliers s JOIN dbo.Products p ON p.SupplierID = s.SupplierID
     GROUP BY s.SupplierName;
  d) DECLARE @q NVARCHAR(MAX) = N'SELECT * FROM dbo.Products WHERE ProductName = @n;';
     EXEC sys.sp_executesql @q, N'@n NVARCHAR(100)', @n = @name;
  ==============================================================*/
