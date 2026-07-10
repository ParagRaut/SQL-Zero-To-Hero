/*==============================================================
  Module 24 — Capstone Projects
  Prove mastery end-to-end on TechShop. Three tracks:
    1. Reporting     — write real business reports.
    2. Optimization  — take a slow report, read its plan, tune it, measure.
    3. Design        — add a "wishlist" + "returns" feature.
  --------------------------------------------------------------
  💡 Run 05_generate_large_data.sql first so the optimization work is real.
     Keep the ACTUAL plan (Ctrl+M) + STATISTICS IO, TIME ON while tuning.
  ==============================================================*/

USE TechShop;
GO

/*==============================================================
  TRACK 1 — REPORTING
  Write these queries yourself. Reference solutions are at the bottom.
  --------------------------------------------------------------
  R1. Monthly revenue: for each year-month, total revenue across all orders.
      Revenue per line = Quantity * UnitPrice * (1 - Discount).
  R2. Top 10 customers by lifetime revenue (name + total).
  R3. Product performance: units sold and revenue per product, best first.
  R4. Category breakdown: revenue and order count per category.
  R5. Cohort retention (stretch): group customers by the month of their FIRST
      order, then count how many ordered again in later months.
==============================================================*/

-- R1.


-- R2.


-- R3.


-- R4.


-- R5.


/*==============================================================
  TRACK 2 — OPTIMIZATION
  --------------------------------------------------------------
  Below is a deliberately slow report. Your job:
    (a) Capture the ACTUAL plan + STATISTICS IO/TIME (the "before").
    (b) Identify the problems (scans, key lookups, non-SARGable predicate,
        implicit conversion, missing index).
    (c) Rewrite the query and/or add an index to fix them.
    (d) Re-measure and record the improvement (reads & time).
==============================================================*/

-- O1. SLOW: non-SARGable date filter + function on column + SELECT *.
SELECT *
FROM   dbo.Orders o
WHERE  YEAR(o.OrderDate) = 2025
  AND  o.ShipCountry = 'Germany';
-- YOUR TUNED VERSION (make it SARGable, select only needed cols, add an index):


-- O2. SLOW: filtering a joined child then losing the seek.
SELECT o.OrderID, oi.ProductID, oi.Quantity
FROM   dbo.Orders o
JOIN   dbo.OrderItems oi ON oi.OrderID = o.OrderID
WHERE  oi.ProductID = 10;
-- YOUR TUNED VERSION (consider an index on OrderItems(ProductID) INCLUDE(...)):


/*==============================================================
  TRACK 3 — DESIGN (build in the sandbox schema, then wire to TechShop)
  --------------------------------------------------------------
  D1. Wishlist feature:
      - Create table dbo.Wishlist (WishlistID PK, CustomerID FK→Customers,
        ProductID FK→Products, AddedAt DATETIME2 default now,
        UNIQUE(CustomerID, ProductID) so a product can't be added twice).
  D2. Returns feature:
      - Create table dbo.Returns (ReturnID PK, OrderItemID FK→OrderItems,
        Quantity INT CHECK > 0, Reason NVARCHAR(200), ReturnedAt default now).
      - Add a CHECK/logic note: returned quantity shouldn't exceed the
        ordered quantity (enforce via a trigger or a validating proc).
  D3. Write a stored proc usp_AddToWishlist @CustomerID, @ProductID that
      inserts only if not already present (idempotent).
  D4. Add the indexes these features need (FK columns) and justify them.
==============================================================*/

-- D1.


-- D2.


-- D3.


-- D4.


/*==============================================================
  REFERENCE SOLUTIONS
  --------------------------------------------------------------
  R1. SELECT FORMAT(o.OrderDate,'yyyy-MM') AS YearMonth,
             SUM(oi.Quantity*oi.UnitPrice*(1-oi.Discount)) AS Revenue
      FROM dbo.Orders o JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID
      GROUP BY FORMAT(o.OrderDate,'yyyy-MM') ORDER BY YearMonth;

  R2. SELECT TOP (10) c.CustomerID, c.FirstName, c.LastName,
             SUM(oi.Quantity*oi.UnitPrice*(1-oi.Discount)) AS Lifetime
      FROM dbo.Customers c
      JOIN dbo.Orders o ON o.CustomerID=c.CustomerID
      JOIN dbo.OrderItems oi ON oi.OrderID=o.OrderID
      GROUP BY c.CustomerID, c.FirstName, c.LastName
      ORDER BY Lifetime DESC;

  R3. SELECT p.ProductID, p.ProductName,
             SUM(oi.Quantity) AS UnitsSold,
             SUM(oi.Quantity*oi.UnitPrice*(1-oi.Discount)) AS Revenue
      FROM dbo.Products p JOIN dbo.OrderItems oi ON oi.ProductID=p.ProductID
      GROUP BY p.ProductID, p.ProductName ORDER BY Revenue DESC;

  R4. SELECT cat.CategoryName,
             COUNT(DISTINCT o.OrderID) AS Orders,
             SUM(oi.Quantity*oi.UnitPrice*(1-oi.Discount)) AS Revenue
      FROM dbo.Categories cat
      JOIN dbo.Products p ON p.CategoryID=cat.CategoryID
      JOIN dbo.OrderItems oi ON oi.ProductID=p.ProductID
      JOIN dbo.Orders o ON o.OrderID=oi.OrderID
      GROUP BY cat.CategoryName ORDER BY Revenue DESC;

  R5. WITH FirstOrder AS (
         SELECT CustomerID, MIN(OrderDate) AS FirstDate FROM dbo.Orders GROUP BY CustomerID),
       Cohort AS (
         SELECT o.CustomerID,
                FORMAT(f.FirstDate,'yyyy-MM') AS CohortMonth,
                DATEDIFF(MONTH, f.FirstDate, o.OrderDate) AS MonthOffset
         FROM dbo.Orders o JOIN FirstOrder f ON f.CustomerID=o.CustomerID)
      SELECT CohortMonth, MonthOffset, COUNT(DISTINCT CustomerID) AS Customers
      FROM Cohort GROUP BY CohortMonth, MonthOffset ORDER BY CohortMonth, MonthOffset;

  O1. SELECT o.OrderID, o.OrderDate, o.CustomerID, o.ShipCountry
      FROM dbo.Orders o
      WHERE o.OrderDate >= '2025-01-01' AND o.OrderDate < '2026-01-01'
        AND o.ShipCountry = 'Germany';
      -- Support: CREATE NONCLUSTERED INDEX IX_Orders_Ship_Date
      --   ON dbo.Orders (ShipCountry, OrderDate) INCLUDE (CustomerID);

  O2. -- CREATE NONCLUSTERED INDEX IX_OI_Product_Cov
      --   ON dbo.OrderItems (ProductID) INCLUDE (OrderID, Quantity);
      -- The existing query is then a seek with no key lookup.

  D1. CREATE TABLE dbo.Wishlist (
        WishlistID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID),
        ProductID  INT NOT NULL REFERENCES dbo.Products(ProductID),
        AddedAt    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_Wishlist UNIQUE (CustomerID, ProductID));

  D2. CREATE TABLE dbo.Returns (
        ReturnID    INT IDENTITY(1,1) PRIMARY KEY,
        OrderItemID INT NOT NULL REFERENCES dbo.OrderItems(OrderItemID),
        Quantity    INT NOT NULL CHECK (Quantity > 0),
        Reason      NVARCHAR(200) NULL,
        ReturnedAt  DATETIME2 NOT NULL DEFAULT SYSDATETIME());
      -- Enforce "not more than ordered" via a trigger or validating proc.

  D3. CREATE OR ALTER PROCEDURE dbo.usp_AddToWishlist @CustomerID INT, @ProductID INT
      AS BEGIN SET NOCOUNT ON;
        IF NOT EXISTS (SELECT 1 FROM dbo.Wishlist
                       WHERE CustomerID=@CustomerID AND ProductID=@ProductID)
           INSERT INTO dbo.Wishlist (CustomerID, ProductID)
           VALUES (@CustomerID, @ProductID);
      END

  D4. CREATE INDEX IX_Wishlist_Customer ON dbo.Wishlist (CustomerID);
      CREATE INDEX IX_Returns_OrderItem ON dbo.Returns (OrderItemID);
      -- FK columns are frequent join/filter targets; indexing them avoids
      -- scans and speeds referential lookups.
  ==============================================================*/
