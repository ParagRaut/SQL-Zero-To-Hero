/*==============================================================
  Module 0 — Environment & Mental Model
  Goal: confirm your setup works and get oriented.
  Run each block, read the comment, observe the result.
  ==============================================================*/

USE TechShop;
GO

-- 0.1  Which server/database/version am I on?
SELECT
    @@SERVERNAME       AS ServerName,
    DB_NAME()          AS CurrentDatabase,
    @@VERSION          AS SqlServerVersion;

-- 0.2  List every table in this database (the data dictionary).
SELECT TABLE_SCHEMA, TABLE_NAME
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- 0.3  Inspect the columns & data types of one table.
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME = 'Products'
ORDER BY ORDINAL_POSITION;

-- 0.4  Peek at some data (TOP limits how many rows come back).
SELECT TOP (10) * FROM dbo.Products;

/*---------------- YOUR TURN ----------------
  a) Show the TOP 5 customers.
  b) List the column names & data types of the Orders table.
  c) How many rows are in the Orders table? (hint: COUNT(*))
-------------------------------------------------*/

-- a) 
SELECT TOP (5) * FROM dbo.Customers;


-- b)
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders';
-- ✔ Correct. Suggestion: add ORDER BY ORDINAL_POSITION so columns come back
--   in table order instead of an arbitrary order (predictable, readable output):
--   ORDER BY ORDINAL_POSITION;

-- c)
SELECT COUNT(*) FROM dbo.Orders;
-- ✔ Correct. Suggestion: alias the column so the result header is meaningful
--   (otherwise SSMS shows "(No column name)"):
--   SELECT COUNT(*) AS OrderCount FROM dbo.Orders;

/*==============================================================
  Solutions (try first, then scroll)
  --------------------------------------------------------------
  a) SELECT TOP (5) * FROM dbo.Customers;
  b) SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = 'Orders' ORDER BY ORDINAL_POSITION;
  c) SELECT COUNT(*) AS OrderCount FROM dbo.Orders;
  ==============================================================*/
