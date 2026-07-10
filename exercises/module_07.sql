/*==============================================================
  Module 7 — Set Operators
  Topics: UNION vs UNION ALL, INTERSECT, EXCEPT, and the rules.
  ==============================================================*/

USE TechShop;
GO

/*  Rules for all set operators:
    - Each query must return the SAME number of columns.
    - Corresponding columns must have COMPATIBLE data types.
    - Column names come from the FIRST query.
    - A single ORDER BY (if any) goes at the very end.                */

-- 7.1  UNION — combine + remove duplicates (does a costly DISTINCT sort).
--      All distinct cities where we have either a customer or a supplier.
SELECT City FROM dbo.Customers
UNION
SELECT City FROM dbo.Suppliers
ORDER BY City;

-- 7.2  UNION ALL — combine and KEEP duplicates (faster: no dedupe).
--      Prefer this when you know there are no dupes, or you want counts.
SELECT City FROM dbo.Customers
UNION ALL
SELECT City FROM dbo.Suppliers;

-- 7.3  INTERSECT — rows present in BOTH result sets.
--      Cities that have both a customer AND a supplier.
SELECT City FROM dbo.Customers
INTERSECT
SELECT City FROM dbo.Suppliers;

-- 7.4  EXCEPT — rows in the first set that are NOT in the second.
--      Customer cities that have no supplier.
SELECT City FROM dbo.Customers
EXCEPT
SELECT City FROM dbo.Suppliers;

-- 7.5  Tagging rows before a UNION ALL to keep track of the source.
SELECT 'Customer' AS Kind, FirstName, LastName, City FROM dbo.Customers
UNION ALL
SELECT 'Employee' AS Kind, FirstName, LastName, NULL FROM dbo.Employees;

/*---------------- YOUR TURN ----------------
  a) Get one combined, de-duplicated list of all Countries appearing in
     either Customers or Suppliers.
  b) Which countries appear in BOTH Customers and Suppliers? (INTERSECT)
  c) Which supplier countries have NO customers? (EXCEPT)
  d) Build one list labelling each name as 'Customer' or 'Employee'
     using UNION ALL.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT Country FROM dbo.Customers
     UNION
     SELECT Country FROM dbo.Suppliers
     ORDER BY Country;
  b) SELECT Country FROM dbo.Customers
     INTERSECT
     SELECT Country FROM dbo.Suppliers;
  c) SELECT Country FROM dbo.Suppliers
     EXCEPT
     SELECT Country FROM dbo.Customers;
  d) SELECT 'Customer' AS Kind, FirstName, LastName FROM dbo.Customers
     UNION ALL
     SELECT 'Employee', FirstName, LastName FROM dbo.Employees;
  ==============================================================*/
