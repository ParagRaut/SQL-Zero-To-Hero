/*==============================================================
  Module 12 — Views
  Topics: creating/altering views, updatable views, SCHEMABINDING,
          indexed (materialized) views, views for security/abstraction.
  ==============================================================*/

USE TechShop;
GO

-- 12.1  A simple view — save a query behind a name.
CREATE OR ALTER VIEW dbo.vw_ProductCatalog
AS
    SELECT p.ProductID, p.ProductName, p.UnitPrice,
           c.CategoryName, s.SupplierName
    FROM   dbo.Products   p
    LEFT JOIN dbo.Categories c ON c.CategoryID = p.CategoryID
    LEFT JOIN dbo.Suppliers  s ON s.SupplierID = p.SupplierID;
GO

-- Use it like a table:
SELECT * FROM dbo.vw_ProductCatalog ORDER BY UnitPrice DESC;

-- 12.2  A view can hide columns (security/abstraction) —
--       e.g., expose customers WITHOUT their email.
CREATE OR ALTER VIEW dbo.vw_CustomerPublic
AS
    SELECT CustomerID, FirstName, LastName, City, Country
    FROM   dbo.Customers;
GO
SELECT * FROM dbo.vw_CustomerPublic;

-- 12.3  A grouped/aggregated view — revenue per order.
CREATE OR ALTER VIEW dbo.vw_OrderRevenue
AS
    SELECT OrderID,
           SUM(Quantity * UnitPrice * (1 - Discount)) AS Revenue
    FROM   dbo.OrderItems
    GROUP BY OrderID;
GO
SELECT TOP (10) * FROM dbo.vw_OrderRevenue ORDER BY Revenue DESC;

/*  Updatable views:
    A view is updatable only if it maps to ONE base table, with no
    GROUP BY / DISTINCT / aggregates / computed columns being changed.
    vw_CustomerPublic is updatable; vw_OrderRevenue is NOT.               */

-- 12.4  SCHEMABINDING + indexed (materialized) view.
--       SCHEMABINDING ties the view to the exact table definitions so
--       columns can't be dropped from under it. Required for indexing.
CREATE OR ALTER VIEW dbo.vw_ProductStockValue
WITH SCHEMABINDING
AS
    SELECT ProductID,
           UnitPrice,
           UnitsInStock,
           UnitPrice * UnitsInStock AS StockValue
    FROM   dbo.Products;   -- note: two-part name (schema.table) required
GO
-- To materialize it, add a UNIQUE CLUSTERED index (the view's data is then stored):
-- CREATE UNIQUE CLUSTERED INDEX IX_vw_ProductStockValue ON dbo.vw_ProductStockValue (ProductID);

/*---------------- YOUR TURN ----------------
  a) Create a view vw_ActiveProducts that shows only products where
     Discontinued = 0 (ProductID, ProductName, UnitPrice).
  b) Create a view vw_CustomerOrderCount showing each customer's name and
     their number of orders.
  c) Query vw_ActiveProducts for items priced over 100.
  d) In a comment, say whether vw_CustomerOrderCount is updatable and why.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)  Answer:


-- Clean up (optional):
-- DROP VIEW IF EXISTS dbo.vw_ProductCatalog, dbo.vw_CustomerPublic,
--   dbo.vw_OrderRevenue, dbo.vw_ProductStockValue,
--   dbo.vw_ActiveProducts, dbo.vw_CustomerOrderCount;

/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) CREATE OR ALTER VIEW dbo.vw_ActiveProducts AS
       SELECT ProductID, ProductName, UnitPrice
       FROM dbo.Products WHERE Discontinued = 0;
  b) CREATE OR ALTER VIEW dbo.vw_CustomerOrderCount AS
       SELECT c.CustomerID, c.FirstName, c.LastName,
              COUNT(o.OrderID) AS OrderCount
       FROM dbo.Customers c
       LEFT JOIN dbo.Orders o ON o.CustomerID = c.CustomerID
       GROUP BY c.CustomerID, c.FirstName, c.LastName;
  c) SELECT * FROM dbo.vw_ActiveProducts WHERE UnitPrice > 100;
  d) Not updatable — it uses GROUP BY and an aggregate (COUNT), so there
     is no 1:1 mapping back to a single base-table row.
  ==============================================================*/
