/*==============================================================
  Module 9 — Modifying Data (DML)
  Topics: INSERT, UPDATE (with joins), DELETE, TRUNCATE vs DELETE,
          MERGE (upsert), OUTPUT clause. Test safely!
  --------------------------------------------------------------
  ⚠️ These statements CHANGE data. Wrap experiments in a transaction
     you can roll back, and always SELECT first to preview the rows.
  ==============================================================*/

USE TechShop;
GO

-- 9.0  Safety pattern: preview → change inside a transaction → verify → rollback.
BEGIN TRAN;
    -- 9.1  INSERT a single row.
    INSERT INTO dbo.Categories (CategoryName, ParentCategoryID)
    VALUES ('Demo Category', NULL);

    -- 9.2  INSERT multiple rows at once.
    INSERT INTO dbo.Categories (CategoryName, ParentCategoryID)
    VALUES ('Demo A', NULL),
           ('Demo B', NULL);

    SELECT * FROM dbo.Categories WHERE CategoryName LIKE 'Demo%';
ROLLBACK TRAN;   -- undo everything above so the DB stays clean.

-- 9.3  INSERT ... SELECT — copy rows from a query.
--      (Demonstration inside a rollback.)
BEGIN TRAN;
    INSERT INTO dbo.Categories (CategoryName, ParentCategoryID)
    SELECT CategoryName + ' (copy)', ParentCategoryID
    FROM   dbo.Categories
    WHERE  ParentCategoryID IS NULL;
    SELECT * FROM dbo.Categories WHERE CategoryName LIKE '%(copy)%';
ROLLBACK TRAN;

-- 9.4  UPDATE with the OUTPUT clause to capture what changed.
BEGIN TRAN;
    UPDATE dbo.Products
    SET    UnitPrice = UnitPrice * 1.10
    OUTPUT deleted.ProductID, deleted.UnitPrice AS OldPrice,
           inserted.UnitPrice AS NewPrice
    WHERE  CategoryID = 1;
ROLLBACK TRAN;

-- 9.5  UPDATE using a JOIN (update Products based on another table).
BEGIN TRAN;
    UPDATE p
    SET    p.Discontinued = 1
    FROM   dbo.Products p
    JOIN   dbo.Suppliers s ON s.SupplierID = p.SupplierID
    WHERE  s.Country = 'Nowhere';   -- (matches nothing; safe demo)
ROLLBACK TRAN;

-- 9.6  DELETE vs TRUNCATE.
--      DELETE   = row-by-row, logged, can have WHERE, fires triggers.
--      TRUNCATE = deallocates pages, minimal logging, no WHERE, resets IDENTITY,
--                 cannot run if the table is referenced by a FK.
BEGIN TRAN;
    DELETE FROM dbo.Categories WHERE CategoryName = 'Nonexistent';
ROLLBACK TRAN;

-- 9.7  MERGE (upsert) — insert if missing, update if present.
--      Caveat: MERGE has known edge-case bugs; many teams prefer explicit
--      INSERT/UPDATE. Shown here for awareness.
/*
MERGE dbo.Categories AS target
USING (SELECT 'Electronics' AS CategoryName) AS src
   ON target.CategoryName = src.CategoryName
WHEN MATCHED THEN UPDATE SET target.CategoryName = src.CategoryName
WHEN NOT MATCHED THEN INSERT (CategoryName) VALUES (src.CategoryName);
*/

/*---------------- YOUR TURN (all inside BEGIN TRAN ... ROLLBACK) ----------------
  a) Insert a new supplier, SELECT it back, then ROLLBACK.
  b) Give every product in CategoryID = 2 a 5% price cut; use OUTPUT to see
     old vs new prices; ROLLBACK.
  c) Delete all reviews with Rating = 1 (preview with SELECT first); ROLLBACK.
  d) Explain in a comment: why can't you TRUNCATE dbo.Products right now?
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)  Answer:


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) BEGIN TRAN;
       INSERT INTO dbo.Suppliers (SupplierName, City, Country)
       VALUES ('Acme Test', 'Pune', 'India');
       SELECT * FROM dbo.Suppliers WHERE SupplierName = 'Acme Test';
     ROLLBACK TRAN;
  b) BEGIN TRAN;
       UPDATE dbo.Products SET UnitPrice = UnitPrice * 0.95
       OUTPUT deleted.UnitPrice AS OldPrice, inserted.UnitPrice AS NewPrice
       WHERE CategoryID = 2;
     ROLLBACK TRAN;
  c) BEGIN TRAN;
       SELECT * FROM dbo.Reviews WHERE Rating = 1;   -- preview
       DELETE FROM dbo.Reviews WHERE Rating = 1;
     ROLLBACK TRAN;
  d) Products is referenced by OrderItems (a FOREIGN KEY). TRUNCATE is blocked
     on any table referenced by an FK constraint.
  ==============================================================*/
