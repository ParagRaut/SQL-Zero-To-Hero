/*==============================================================
  Module 2 — Filtering with WHERE
  Topics: comparison operators, AND/OR/NOT & precedence,
          BETWEEN, IN, LIKE, NULL & three-valued logic,
          ISNULL / COALESCE.
  ==============================================================*/

USE TechShop;
GO

-- 2.1  Simple comparison — products over $100.
SELECT ProductName, UnitPrice
FROM   dbo.Products
WHERE  UnitPrice > 100;

-- 2.2  Combine conditions with AND (both must be true).
SELECT ProductName, UnitPrice, UnitsInStock
FROM   dbo.Products
WHERE  UnitPrice > 100 AND UnitsInStock > 0;

-- 2.3  OR + parentheses. Without the parens, AND binds tighter than OR
--      and you'd get a different (usually wrong) result.
SELECT ProductName, UnitPrice, Discontinued
FROM   dbo.Products
WHERE  (UnitPrice > 500 OR Discontinued = 1)
  AND  UnitsInStock > 0;

-- 2.4  BETWEEN is inclusive of both ends (>= 50 AND <= 100).
SELECT ProductName, UnitPrice
FROM   dbo.Products
WHERE  UnitPrice BETWEEN 50 AND 100
ORDER BY UnitPrice;

-- 2.5  IN — a shorthand for many OR equals.
SELECT FirstName, LastName, Country
FROM   dbo.Customers
WHERE  Country IN ('USA', 'Canada', 'UK');

-- 2.6  LIKE — pattern matching.
--      %  = any run of characters (including none)
--      _  = exactly one character
SELECT ProductName
FROM   dbo.Products
WHERE  ProductName LIKE '%Pro%';          -- contains "Pro"

SELECT FirstName, LastName
FROM   dbo.Customers
WHERE  LastName LIKE 'S%';                -- starts with S

-- 2.7  NULL & three-valued logic.
--      A NULL means "unknown". Comparisons WITH null are never TRUE,
--      so `= NULL` returns nothing. Use IS NULL / IS NOT NULL.
SELECT ProductName, SupplierID
FROM   dbo.Products
WHERE  SupplierID IS NULL;                -- products with no supplier

-- 2.8  ISNULL / COALESCE — substitute a value when something is NULL.
SELECT ProductName,
       ISNULL(SupplierID, -1)                 AS SupplierOrMinus1,
       COALESCE(SupplierID, CategoryID, 0)     AS FirstNonNull
FROM   dbo.Products;

/*---------------- YOUR TURN ----------------
  a) Find all products priced under $20.
  b) Find customers who are in either 'Germany' or 'France'
     (use IN).
  c) Find products whose name contains the word "Wireless".
  d) Find orders whose Status is NOT 'Cancelled'.
  e) Find products that have NO supplier assigned (SupplierID is NULL).
  f) Find products priced between $200 and $400 that are still in stock
     (UnitsInStock > 0). Sort cheapest first.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)


-- f)


/*==============================================================
  Solutions (try first, then scroll)
  --------------------------------------------------------------
  a) SELECT ProductName, UnitPrice FROM dbo.Products WHERE UnitPrice < 20;
  b) SELECT FirstName, LastName, Country FROM dbo.Customers
     WHERE Country IN ('Germany', 'France');
  c) SELECT ProductName FROM dbo.Products WHERE ProductName LIKE '%Wireless%';
  d) SELECT OrderID, Status FROM dbo.Orders WHERE Status <> 'Cancelled';
     -- note: rows where Status IS NULL are NOT returned by <> (three-valued logic)
  e) SELECT ProductName FROM dbo.Products WHERE SupplierID IS NULL;
  f) SELECT ProductName, UnitPrice FROM dbo.Products
     WHERE UnitPrice BETWEEN 200 AND 400 AND UnitsInStock > 0
     ORDER BY UnitPrice ASC;
  ==============================================================*/
