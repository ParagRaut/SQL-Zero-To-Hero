/*==============================================================
  Module 17 — Statistics & the Optimizer
  Topics: cost-based optimizer, cardinality estimation, statistics
          (histograms), UPDATE STATISTICS, STATISTICS IO/TIME,
          parameter sniffing.
  --------------------------------------------------------------
  💡 Run 05_generate_large_data.sql first for realistic estimates.
  ==============================================================*/

USE TechShop;
GO

/*  How SQL Server runs your query:
    1. Parse & bind.
    2. The COST-BASED OPTIMIZER generates candidate plans and picks the
       cheapest ESTIMATED one.
    3. Cost depends on CARDINALITY ESTIMATES — "how many rows will this
       operator produce?" — which come from STATISTICS (histograms).
    Stale/missing stats → bad estimates → bad plans.                     */

-- 17.1  Measure work: logical reads + CPU/elapsed time.
SET STATISTICS IO, TIME ON;
SELECT * FROM dbo.Orders WHERE Status = 'Shipped';
SET STATISTICS IO, TIME OFF;

-- 17.2  What statistics exist on a table?
SELECT s.name AS StatName, s.auto_created, s.user_created,
       STATS_DATE(s.object_id, s.stats_id) AS LastUpdated
FROM   sys.stats s
WHERE  s.object_id = OBJECT_ID('dbo.Orders');

-- 17.3  Look at a histogram (the distribution the optimizer relies on).
DBCC SHOW_STATISTICS ('dbo.Orders', 'PK_Orders') WITH HISTOGRAM;
-- (replace the 2nd arg with a real stats/index name from 17.2 if needed)

-- 17.4  Refresh statistics (with a full scan for accuracy).
UPDATE STATISTICS dbo.Orders WITH FULLSCAN;

-- 17.5  Estimated vs actual rows.
--       Turn on the ACTUAL execution plan (Ctrl+M) and run a query.
--       Hover an operator: compare "Estimated Number of Rows" vs "Actual".
--       A big mismatch = stale stats or a non-SARGable predicate.
SELECT * FROM dbo.Orders WHERE OrderDate >= '2025-01-01';

/*  Parameter sniffing:
    On first execution, SQL Server "sniffs" the parameter value and builds
    a plan optimal for THAT value, then caches it. If later calls pass very
    different values (skewed data), the cached plan can be poor.
    Mitigations: OPTION (RECOMPILE), OPTIMIZE FOR, local variables, or
    plan guides — use sparingly (Module 20).                              */

-- 17.6  Demonstrate a cached plan with a proc, then force a recompile.
CREATE OR ALTER PROCEDURE dbo.usp_OrdersByStatus @Status NVARCHAR(20)
AS
    SELECT * FROM dbo.Orders WHERE Status = @Status
    OPTION (RECOMPILE);      -- fresh plan each call (avoids bad sniffing here)
GO
EXEC dbo.usp_OrdersByStatus @Status = 'Shipped';

/*---------------- YOUR TURN ----------------
  a) Turn on STATISTICS IO, TIME and run a filtered query on dbo.OrderItems;
     record logical reads and CPU time.
  b) List the statistics objects on dbo.Products (sys.stats).
  c) Run UPDATE STATISTICS on dbo.Products WITH FULLSCAN.
  d) Turn on the actual plan and find a query where Estimated vs Actual rows
     differ; in a comment, guess why.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)  Answer:


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SET STATISTICS IO, TIME ON;
     SELECT * FROM dbo.OrderItems WHERE Quantity > 5;
     SET STATISTICS IO, TIME OFF;
  b) SELECT name, auto_created, STATS_DATE(object_id, stats_id) AS LastUpdated
     FROM sys.stats WHERE object_id = OBJECT_ID('dbo.Products');
  c) UPDATE STATISTICS dbo.Products WITH FULLSCAN;
  d) Big skew usually means stale statistics or a predicate the optimizer
     can't estimate well (e.g., a function wrapped around the column, or
     a local variable whose value isn't known at compile time).
  ==============================================================*/
