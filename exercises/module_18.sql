/*==============================================================
  Module 18 — Indexes (Deep Dive)
  Topics: B-tree, clustered vs nonclustered, key vs INCLUDE columns,
          covering indexes, composite order & left-most prefix,
          unique/filtered/computed indexes, key lookups,
          columnstore overview, write cost, missing-index DMVs.
  --------------------------------------------------------------
  💡 Run 05_generate_large_data.sql first. MEASURE BEFORE, then run
     database/04_indexes.sql (or create indexes here), then MEASURE AFTER.
  ==============================================================*/

USE TechShop;
GO

/*  B-tree: a balanced tree. Root → intermediate → leaf pages.
    - CLUSTERED index leaf = the actual data rows (one per table).
    - NONCLUSTERED index leaf = key columns + a pointer (clustering key or RID)
      back to the row; plus any INCLUDEd columns.                          */

-- 18.1  MEASURE BEFORE: capture reads for a typical lookup.
SET STATISTICS IO ON;
SELECT OrderID, CustomerID, OrderDate
FROM   dbo.Orders
WHERE  CustomerID = 42;          -- likely a scan if no index on CustomerID
SET STATISTICS IO OFF;
-- Turn on the actual plan (Ctrl+M): look for a Clustered Index SCAN.

-- 18.2  Create a nonclustered index on the filter column.
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
    ON dbo.Orders (CustomerID);

-- 18.3  MEASURE AFTER: rerun 18.1. Plan should now show an Index SEEK,
--       but note a KEY LOOKUP to fetch OrderDate (not in the index).
SET STATISTICS IO ON;
SELECT OrderID, CustomerID, OrderDate
FROM   dbo.Orders
WHERE  CustomerID = 42;
SET STATISTICS IO OFF;

-- 18.4  COVERING index — INCLUDE the extra columns to kill the key lookup.
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID_Covering
    ON dbo.Orders (CustomerID)
    INCLUDE (OrderDate, Status);       -- now the index "covers" the query
-- Rerun 18.1: seek only, no lookup, fewer logical reads.

-- 18.5  COMPOSITE index & the LEFT-MOST PREFIX rule.
--       An index on (A, B) helps: WHERE A = ?,  WHERE A = ? AND B = ?
--       It does NOT help a query that only filters on B.
CREATE NONCLUSTERED INDEX IX_OrderItems_Product_Qty
    ON dbo.OrderItems (ProductID, Quantity);
-- Helped:      WHERE ProductID = 10
-- Helped:      WHERE ProductID = 10 AND Quantity > 3
-- NOT helped:  WHERE Quantity > 3        (ProductID missing → leading col unused)

-- 18.6  FILTERED index — index only the rows you query often.
--       (Two products are Discontinued = 1: IDs 39 & 40.)
CREATE NONCLUSTERED INDEX IX_Products_Discontinued
    ON dbo.Products (ProductID)
    WHERE Discontinued = 1;

-- 18.7  UNIQUE index — enforces uniqueness AND helps the optimizer.
--       (Customers.Email is already unique; example on sandbox-like use.)
-- CREATE UNIQUE NONCLUSTERED INDEX UX_Customers_Email ON dbo.Customers (Email);

-- 18.8  Missing-index suggestions (USE WITH CAUTION — they're greedy hints).
SELECT TOP (10)
       mid.statement            AS TableName,
       migs.avg_user_impact,
       mid.equality_columns,
       mid.inequality_columns,
       mid.included_columns
FROM sys.dm_db_missing_index_group_stats migs
JOIN sys.dm_db_missing_index_groups   mig ON mig.index_group_handle = migs.group_handle
JOIN sys.dm_db_missing_index_details  mid ON mid.index_handle = mig.index_handle
ORDER BY migs.avg_user_impact DESC;

/*  Columnstore (overview): stores data column-by-column, heavily compressed;
    great for analytics/aggregation over millions of rows (batch mode),
    poor for single-row OLTP lookups. CREATE [CLUSTERED|NONCLUSTERED]
    COLUMNSTORE INDEX ...                                                   */

/*  The cost of indexes:
    Every index must be MAINTAINED on INSERT/UPDATE/DELETE. Too many indexes
    slow writes and waste space. Index for your real query patterns, then
    verify with plans — don't blindly add every "missing index" suggestion. */

/*---------------- YOUR TURN ----------------
  a) Measure reads for: SELECT * FROM dbo.OrderItems WHERE ProductID = 10;
     (before any helpful index).
  b) Create a nonclustered index on OrderItems(ProductID); re-measure. Did the
     plan change from Scan to Seek?
  c) Make it a COVERING index for
     SELECT OrderID, Quantity FROM dbo.OrderItems WHERE ProductID = 10;
     by INCLUDE-ing the needed columns. Confirm the key lookup disappears.
  d) In a comment, explain why an index on (ProductID, Quantity) does NOT help
     WHERE Quantity = 5 alone.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)  Answer:


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SET STATISTICS IO ON;
     SELECT * FROM dbo.OrderItems WHERE ProductID = 10;
     SET STATISTICS IO OFF;
  b) CREATE NONCLUSTERED INDEX IX_OI_ProductID ON dbo.OrderItems (ProductID);
     -- rerun (a): expect an Index Seek instead of a Clustered Index Scan.
  c) CREATE NONCLUSTERED INDEX IX_OI_ProductID_Cov
        ON dbo.OrderItems (ProductID) INCLUDE (OrderID, Quantity);
     SELECT OrderID, Quantity FROM dbo.OrderItems WHERE ProductID = 10;
  d) The index is sorted by ProductID first; without a ProductID predicate the
     rows for a given Quantity are scattered across the whole index, so the
     leading-column (left-most prefix) can't be used to seek.
  ==============================================================*/
