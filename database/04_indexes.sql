/*==============================================================
  TechShop — Step 4: Indexes (belongs to Module 18)
  DO NOT run this during early modules.

  The whole point of Module 18/19 is to measure a query's
  execution plan and STATISTICS IO *before* indexing, then add
  the index and measure again. So:

    1. First, in Module 18, run the "before" queries with:
         SET STATISTICS IO ON;
         SET STATISTICS TIME ON;
       and capture the actual execution plan (Ctrl+M in SSMS).
    2. THEN run the relevant index below and re-measure.

  These indexes assume you also ran 05_generate_large_data.sql
  so the difference is visible.
  ==============================================================*/

USE TechShop;
GO

/*---------------------------------------------------------------
  1) Nonclustered index to support filtering orders by date.
     Try:  SELECT * FROM Orders WHERE OrderDate >= '2026-01-01';
---------------------------------------------------------------*/
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
    ON dbo.Orders (OrderDate);
GO

/*---------------------------------------------------------------
  2) Composite index — column order matters (left-most prefix).
     Supports: WHERE CustomerID = ? ORDER BY OrderDate.
---------------------------------------------------------------*/
CREATE NONCLUSTERED INDEX IX_Orders_Customer_Date
    ON dbo.Orders (CustomerID, OrderDate);
GO

/*---------------------------------------------------------------
  3) COVERING index with INCLUDE — lets a query be answered
     entirely from the index (an "index-only scan"), avoiding
     key lookups back to the clustered index.
     Try:  SELECT OrderID, Quantity, UnitPrice
           FROM OrderItems WHERE ProductID = 8;
---------------------------------------------------------------*/
CREATE NONCLUSTERED INDEX IX_OrderItems_Product_Covering
    ON dbo.OrderItems (ProductID)
    INCLUDE (OrderID, Quantity, UnitPrice, Discount);
GO

/*---------------------------------------------------------------
  4) FILTERED index — indexes only the rows you actually query.
     Great for "active" subsets.
     Try:  SELECT * FROM Products WHERE Discontinued = 0 AND CategoryID = 7;
---------------------------------------------------------------*/
CREATE NONCLUSTERED INDEX IX_Products_Active_Category
    ON dbo.Products (CategoryID)
    INCLUDE (ProductName, UnitPrice)
    WHERE Discontinued = 0;
GO

/*---------------------------------------------------------------
  5) UNIQUE index — enforces uniqueness AND helps the optimizer.
     (Customers.Email already has one via the UNIQUE constraint.)
     Example of adding a supporting index for lookups by email:
---------------------------------------------------------------*/
-- (Already exists as UQ_Customers_Email; shown for reference.)

/*---------------------------------------------------------------
  To DROP them again (to re-run the "before" experiment):

  DROP INDEX IX_Orders_OrderDate            ON dbo.Orders;
  DROP INDEX IX_Orders_Customer_Date        ON dbo.Orders;
  DROP INDEX IX_OrderItems_Product_Covering ON dbo.OrderItems;
  DROP INDEX IX_Products_Active_Category     ON dbo.Products;
---------------------------------------------------------------*/

PRINT 'Module 18 indexes created. Re-run your queries and compare plans!';
GO
