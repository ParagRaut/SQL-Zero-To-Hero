/*==============================================================
  Module 4 — Aggregation & Grouping
  Topics: COUNT/SUM/AVG/MIN/MAX, GROUP BY, HAVING vs WHERE,
          DISTINCT in aggregates, logical processing order.
  ==============================================================*/

USE TechShop;
GO

-- 4.1  Aggregates over the whole table (one row back).
SELECT
    COUNT(*)         AS ProductCount,
    AVG(UnitPrice)   AS AvgPrice,
    MIN(UnitPrice)   AS Cheapest,
    MAX(UnitPrice)   AS Priciest,
    SUM(UnitsInStock) AS TotalUnits
FROM dbo.Products;

-- 4.2  COUNT(*) counts rows; COUNT(col) skips NULLs in that column.
SELECT
    COUNT(*)            AS AllProducts,
    COUNT(SupplierID)   AS WithSupplier,     -- excludes NULL SupplierIDs
    COUNT(DISTINCT CategoryID) AS DistinctCategories
FROM dbo.Products;

-- 4.3  GROUP BY — one row per group.
SELECT
    CategoryID,
    COUNT(*)        AS ProductsInCategory,
    AVG(UnitPrice)  AS AvgPrice
FROM dbo.Products
GROUP BY CategoryID
ORDER BY ProductsInCategory DESC;

-- 4.4  WHERE filters ROWS (before grouping);
--      HAVING filters GROUPS (after grouping).
SELECT
    CategoryID,
    COUNT(*) AS ProductCount
FROM dbo.Products
WHERE Discontinued = 0            -- row filter: ignore discontinued
GROUP BY CategoryID
HAVING COUNT(*) >= 3              -- group filter: only busy categories
ORDER BY ProductCount DESC;

-- 4.5  Grouping by multiple columns.
SELECT
    ShipCountry,
    Status,
    COUNT(*) AS OrderCount
FROM dbo.Orders
GROUP BY ShipCountry, Status
ORDER BY ShipCountry, Status;

/*  Logical query processing order (important!):
    FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
    That's why you can't use a SELECT alias in WHERE/GROUP BY/HAVING,
    but you CAN use it in ORDER BY.                                     */

/*---------------- YOUR TURN ----------------
  a) How many customers are there per Country? Order by count desc.
  b) What is the average, min, and max UnitPrice per CategoryID?
  c) Count orders per Status.
  d) Which countries have MORE THAN 5 customers? (HAVING)
  e) Total revenue per OrderID from OrderItems.
     Revenue per line = Quantity * UnitPrice * (1 - Discount).
     Hint: SUM(Quantity * UnitPrice * (1 - Discount)).
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT Country, COUNT(*) AS CustomerCount FROM dbo.Customers
     GROUP BY Country ORDER BY CustomerCount DESC;
  b) SELECT CategoryID, AVG(UnitPrice) AS Avg, MIN(UnitPrice) AS Min,
            MAX(UnitPrice) AS Max
     FROM dbo.Products GROUP BY CategoryID;
  c) SELECT Status, COUNT(*) AS OrderCount FROM dbo.Orders GROUP BY Status;
  d) SELECT Country, COUNT(*) AS CustomerCount FROM dbo.Customers
     GROUP BY Country HAVING COUNT(*) > 5 ORDER BY CustomerCount DESC;
  e) SELECT OrderID,
            SUM(Quantity * UnitPrice * (1 - Discount)) AS LineRevenue
     FROM dbo.OrderItems GROUP BY OrderID ORDER BY LineRevenue DESC;
  ==============================================================*/
