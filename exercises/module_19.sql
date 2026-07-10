/*==============================================================
  Module 19 — Reading Execution Plans
  Topics: estimated vs actual plans, key operators, arrows/row counts,
          warnings, estimated-vs-actual skew, Live Query Statistics.
  --------------------------------------------------------------
  How to capture plans in SSMS:
    Ctrl+L = Estimated plan (doesn't run the query)
    Ctrl+M = include Actual plan (runs it, shows real row counts)
  In Azure Data Studio: "Explain" / "Enable Actual Plan" toolbar buttons.
  ==============================================================*/

USE TechShop;
GO

/*  Read a plan RIGHT-TO-LEFT, TOP-TO-BOTTOM (data flows leftward into the
    final SELECT). Each node shows an OPERATOR, its estimated/actual rows,
    and its relative cost.

    Key operators to recognize:
    - Table/Clustered Index SCAN  — reads all rows/pages (fine for small
      tables or when returning most rows; bad for a needle-in-haystack).
    - Index SEEK                  — navigates the B-tree to matching rows
      (what you usually want for selective filters).
    - Key Lookup / RID Lookup     — fetches columns missing from a
      nonclustered index (fix with a covering INCLUDE).
    - Nested Loops join           — good for small inputs.
    - Hash Match join             — good for large, unsorted inputs.
    - Merge join                  — good for two large SORTED inputs.
    - Sort                        — expensive; can spill to tempdb.
    - Spool                       — a temp cache of rows; sometimes a smell.

    Arrow THICKNESS = number of rows flowing (the "fat arrow" rule: a fat
    arrow feeding a Sort/Hash may indicate too much data being moved).      */

-- 19.1  A query likely to SCAN (no supporting index on the predicate).
--       Capture the ACTUAL plan (Ctrl+M) and look at the operators.
SELECT OrderID, CustomerID, OrderDate
FROM   dbo.Orders
WHERE  ShipCountry = 'Germany';

-- 19.2  A query likely to SEEK (filter on a key/indexed column).
SELECT * FROM dbo.Orders WHERE OrderID = 100;

-- 19.3  Force a Key Lookup so you can SEE it, then read the plan.
CREATE NONCLUSTERED INDEX IX_Orders_Status ON dbo.Orders (Status);
GO
-- This seeks IX_Orders_Status but must look up OrderDate (not in the index):
SELECT OrderID, OrderDate FROM dbo.Orders WHERE Status = 'Shipped';
-- The plan shows: Index Seek + Key Lookup + Nested Loops.

-- 19.4  Estimated vs Actual skew.
--       On the actual plan, hover the operators feeding a join/sort and
--       compare "Estimated Number of Rows" to "Actual Number of Rows".
--       A large gap ⇒ stale statistics or a non-SARGable predicate.
SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2025;   -- function ⇒ often a scan

-- 19.5  Warnings to watch for in a plan (yellow ! on an operator):
--       - "Type conversion may affect CardinalityEstimate" (implicit conversion)
--       - "Operator used tempdb to spill data" (a Sort/Hash spill — under-estimate)
--       Hover the operator or open its properties to read the warning text.

-- 19.6  Get a plan as XML/text without SSMS UI (optional).
SET SHOWPLAN_XML ON;   -- estimated plan as XML (query is NOT executed)
GO
SELECT * FROM dbo.Orders WHERE ShipCountry = 'Germany';
GO
SET SHOWPLAN_XML OFF;
GO

/*  Live Query Statistics (SSMS): the toolbar button shows row counts moving
    through operators in real time while the query runs — great for spotting
    the operator that stalls.                                               */

/*---------------- YOUR TURN ----------------
  a) Capture the actual plan for
     SELECT * FROM dbo.OrderItems WHERE Discount > 0;
     Is it a Seek or a Scan? Why?
  b) Find a query in your earlier modules that produces a Key Lookup and
     describe (in a comment) how to remove it.
  c) Run SELECT * FROM dbo.Orders WHERE YEAR(OrderDate) = 2025; and
     SELECT * FROM dbo.Orders WHERE OrderDate >= '2025-01-01' AND OrderDate < '2026-01-01';
     Compare their plans. Which is SARGable?
  d) In a comment, explain the "fat arrow" rule in your own words.
-------------------------------------------------*/

-- a)  Answer:


-- b)  Answer:


-- c)  Answer:


-- d)  Answer:


/*==============================================================
  Notes / Solutions
  --------------------------------------------------------------
  a) Scan — Discount > 0 isn't selective and there's no covering index;
     the optimizer reads the whole table.
  b) Any "SELECT col_not_in_index ... WHERE indexed_col = ?" query. Remove the
     lookup by INCLUDE-ing the selected columns in the nonclustered index
     (make it covering).
  c) The second is SARGable: OrderDate is "bare", so an index on OrderDate can
     seek a date range. YEAR(OrderDate) wraps the column in a function → the
     index can't be used → scan.
  d) A visually thick arrow means many rows are flowing between operators.
     A fat arrow into a Sort/Hash/Lookup is a hotspot: either the query needs
     a better index, or an estimate is off — investigate that operator first.
  ==============================================================*/
