/*==============================================================
  Module 20 — Query Tuning & Best Practices
  Topics: SARGability, implicit conversions, EXISTS vs IN vs JOIN,
          UNION ALL vs UNION, paging (OFFSET/FETCH vs keyset),
          temp tables vs table variables vs CTEs, key-lookup
          reduction, recompilation & plan cache, OPTION hints.
  --------------------------------------------------------------
  💡 Run 05_generate_large_data.sql first so differences are visible.
     Keep the ACTUAL plan (Ctrl+M) and STATISTICS IO on while comparing.
  ==============================================================*/

USE TechShop;
GO
SET STATISTICS IO ON;

-- 20.1  SARGability — keep the indexed column "bare" in the predicate.
--       BAD (non-SARGable: function on the column → scan):
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2025;
--       GOOD (SARGable range → index seek possible):
SELECT * FROM dbo.Orders
WHERE  OrderDate >= '2025-01-01' AND OrderDate < '2026-01-01';

-- 20.2  Avoid implicit conversions (data-type mismatch forces a scan + warning).
--       If a column is INT, compare to an INT literal, not a string.
--       BAD:  WHERE SomeIntColumn = '42'      -- may convert every row
--       GOOD: WHERE SomeIntColumn = 42

-- 20.3  EXISTS vs IN vs JOIN for "does a related row exist?".
--       EXISTS short-circuits and is NULL-safe; often the clearest & fastest.
SELECT c.CustomerID, c.FirstName
FROM   dbo.Customers c
WHERE  EXISTS (SELECT 1 FROM dbo.Orders o WHERE o.CustomerID = c.CustomerID);
--       A JOIN can duplicate rows if the child side has many matches — use
--       DISTINCT or GROUP BY if you only want existence.

-- 20.4  UNION ALL vs UNION — UNION adds a costly DISTINCT sort.
--       Use UNION ALL when duplicates are impossible or acceptable.
SELECT City FROM dbo.Customers
UNION ALL
SELECT City FROM dbo.Suppliers;

-- 20.5  Paging: OFFSET/FETCH vs keyset (seek) pagination.
--       OFFSET/FETCH is simple but gets slower on deep pages (it still scans
--       and discards the skipped rows).
SELECT OrderID, OrderDate
FROM   dbo.Orders
ORDER BY OrderID
OFFSET 100 ROWS FETCH NEXT 20 ROWS ONLY;      -- page 6 of 20/page

--       Keyset/seek pagination stays fast at any depth (remembers the last key):
SELECT TOP (20) OrderID, OrderDate
FROM   dbo.Orders
WHERE  OrderID > 120           -- 120 = last OrderID from the previous page
ORDER BY OrderID;

-- 20.6  Temp table vs table variable vs CTE.
--       CTE            = just an inline query definition (no storage, no stats).
--       @table var     = in-memory-ish, NO column statistics (est. = 1 row) —
--                        fine for tiny sets, risky for big ones.
--       #temp table    = real table in tempdb WITH statistics & indexes —
--                        better for larger intermediate result sets.
CREATE TABLE #Big (OrderID INT PRIMARY KEY, Revenue DECIMAL(12,2));
INSERT INTO #Big (OrderID, Revenue)
SELECT OrderID, SUM(Quantity * UnitPrice * (1 - Discount))
FROM   dbo.OrderItems GROUP BY OrderID;
SELECT * FROM #Big WHERE Revenue > 1000 ORDER BY Revenue DESC;
DROP TABLE #Big;

-- 20.7  Reduce key lookups with a covering index (recap from Module 18).
--       If a query seeks then does many lookups, INCLUDE the output columns.

-- 20.8  Recompilation & the plan cache.
--       Plans are cached and reused. For a proc that suffers bad parameter
--       sniffing, OPTION (RECOMPILE) trades compile cost for a fresh plan.
--       Hints are a LAST RESORT — fix indexes/SARGability first.
SELECT * FROM dbo.Orders WHERE Status = 'Shipped' OPTION (RECOMPILE);

SET STATISTICS IO OFF;

/*---------------- YOUR TURN ----------------
  a) Rewrite this to be SARGable:
     SELECT * FROM dbo.Products WHERE UPPER(ProductName) = 'LAPTOP';
     (hint: rely on case-insensitive collation, drop the function).
  b) Compare logical reads: UNION vs UNION ALL on Customers/Suppliers City.
  c) Write page 3 (rows 41–60) of dbo.Products ordered by ProductID two ways:
     OFFSET/FETCH, and keyset (WHERE ProductID > ...).
  d) In a comment, say when you'd choose a #temp table over a table variable.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)  Answer:


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT * FROM dbo.Products WHERE ProductName = 'Laptop';
     -- default SQL Server collation is case-insensitive; no need for UPPER(),
     -- which would block an index seek on ProductName.
  b) SELECT City FROM dbo.Customers UNION     SELECT City FROM dbo.Suppliers;   -- more reads (sort/distinct)
     SELECT City FROM dbo.Customers UNION ALL SELECT City FROM dbo.Suppliers;   -- fewer (no dedupe)
  c) OFFSET: SELECT ProductID, ProductName FROM dbo.Products
             ORDER BY ProductID OFFSET 40 ROWS FETCH NEXT 20 ROWS ONLY;
     Keyset: SELECT TOP (20) ProductID, ProductName FROM dbo.Products
             WHERE ProductID > 40 ORDER BY ProductID;   -- (assuming contiguous IDs)
  d) Choose a #temp table when the intermediate set is large or you need
     statistics/indexes on it for a good plan; table variables assume ~1 row
     and can mislead the optimizer at scale.
  ==============================================================*/
