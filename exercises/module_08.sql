/*==============================================================
  Module 8 — Window Functions
  Topics: OVER(PARTITION BY ... ORDER BY ...), ranking, offset,
          aggregate windows (running totals / moving averages),
          ROWS vs RANGE framing, de-duplication pattern.
  ==============================================================*/

USE TechShop;
GO

-- 8.1  Aggregate window — keeps every row, adds a group-level value.
--      Each product with its category's average price alongside it.
SELECT
    ProductName,
    CategoryID,
    UnitPrice,
    AVG(UnitPrice) OVER (PARTITION BY CategoryID) AS CategoryAvg,
    UnitPrice - AVG(UnitPrice) OVER (PARTITION BY CategoryID) AS DiffFromAvg
FROM dbo.Products;

-- 8.2  Ranking functions.
--      ROW_NUMBER: always unique 1,2,3...
--      RANK:       ties share a rank, then a gap (1,1,3)
--      DENSE_RANK: ties share a rank, no gap (1,1,2)
SELECT
    ProductName,
    CategoryID,
    UnitPrice,
    ROW_NUMBER() OVER (PARTITION BY CategoryID ORDER BY UnitPrice DESC) AS RowNum,
    RANK()       OVER (PARTITION BY CategoryID ORDER BY UnitPrice DESC) AS Rnk,
    DENSE_RANK() OVER (PARTITION BY CategoryID ORDER BY UnitPrice DESC) AS DenseRnk
FROM dbo.Products;

-- 8.3  NTILE — split rows into N buckets (e.g., price quartiles).
SELECT ProductName, UnitPrice,
       NTILE(4) OVER (ORDER BY UnitPrice) AS PriceQuartile
FROM dbo.Products;

-- 8.4  Offset functions — compare a row to the previous/next.
--      Running order value vs the previous order (by date).
SELECT
    OrderID,
    OrderDate,
    LAG(OrderDate)  OVER (ORDER BY OrderDate) AS PrevOrderDate,
    LEAD(OrderDate) OVER (ORDER BY OrderDate) AS NextOrderDate
FROM dbo.Orders;

-- 8.5  Running total with an explicit frame.
--      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
SELECT
    OrderID,
    OrderDate,
    SUM(1) OVER (ORDER BY OrderDate
                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningOrderCount
FROM dbo.Orders;

-- 8.6  De-duplication pattern — keep the newest row per group.
--      (Here: one row per CustomerID, their latest order.)
WITH Ranked AS (
    SELECT o.*,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS rn
    FROM dbo.Orders o
)
SELECT * FROM Ranked WHERE rn = 1;

/*---------------- YOUR TURN ----------------
  a) Rank products by UnitPrice within each category (highest = rank 1),
     using DENSE_RANK.
  b) For each product show its price and the category average side-by-side.
  c) Number all orders chronologically with ROW_NUMBER (oldest = 1).
  d) For each order, show the previous order's OrderID using LAG (by date).
  e) Compute a running COUNT of orders over time.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT ProductName, CategoryID, UnitPrice,
            DENSE_RANK() OVER (PARTITION BY CategoryID ORDER BY UnitPrice DESC) AS PriceRank
     FROM dbo.Products;
  b) SELECT ProductName, UnitPrice,
            AVG(UnitPrice) OVER (PARTITION BY CategoryID) AS CategoryAvg
     FROM dbo.Products;
  c) SELECT OrderID, OrderDate,
            ROW_NUMBER() OVER (ORDER BY OrderDate) AS SeqNo
     FROM dbo.Orders;
  d) SELECT OrderID, OrderDate,
            LAG(OrderID) OVER (ORDER BY OrderDate) AS PrevOrderID
     FROM dbo.Orders;
  e) SELECT OrderID, OrderDate,
            COUNT(*) OVER (ORDER BY OrderDate
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningCount
     FROM dbo.Orders;
  ==============================================================*/
