/*==============================================================
  Module 1 — SELECT Basics
  Topics: SELECT, column lists, aliases, ORDER BY, DISTINCT, TOP,
          expressions in SELECT.
  ==============================================================*/

USE TechShop;
GO

-- 1.1  Select specific columns (prefer this over SELECT *).
SELECT ProductName, UnitPrice
FROM   dbo.Products;

-- 1.2  Column aliases + a computed expression.
SELECT
    ProductName                       AS Product,
    UnitPrice                         AS Price,
    UnitPrice * 1.20                  AS PriceWithTax   -- 20% tax
FROM dbo.Products;

-- 1.3  ORDER BY (most expensive first).
SELECT ProductName, UnitPrice
FROM   dbo.Products
ORDER BY UnitPrice DESC;

-- 1.4  TOP with ties, and ordering.
SELECT TOP (5) WITH TIES ProductName, UnitPrice
FROM   dbo.Products
ORDER BY UnitPrice DESC;

-- 1.5  DISTINCT — unique list of countries our customers are in.
SELECT DISTINCT Country
FROM   dbo.Customers
ORDER BY Country;

/*---------------- YOUR TURN ----------------
  a) List product name and units in stock, cheapest first.
  b) Show each customer's full name as one column called "FullName"
     (hint: FirstName + ' ' + LastName).
  c) Show the 3 most recently created products.
  d) Get the distinct list of cities suppliers are in.
-------------------------------------------------*/

-- a)
SELECT P.ProductName, P.UnitsInStock FROM dbo.Products P
ORDER BY P.UnitPrice ASC;

-- b)
SELECT C.FirstName + ' ' + C.LastName AS FullName FROM dbo.Customers C;

-- c)
SELECT TOP (3) P.ProductName FROM dbo.Products P
ORDER BY P.CreatedAt DESC;

-- d)
SELECT DISTINCT S.City FROM dbo.Suppliers S;


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT ProductName, UnitsInStock FROM dbo.Products ORDER BY UnitPrice ASC;
  b) SELECT FirstName + ' ' + LastName AS FullName FROM dbo.Customers;
  c) SELECT TOP (3) ProductName, CreatedAt FROM dbo.Products ORDER BY CreatedAt DESC;
  d) SELECT DISTINCT City FROM dbo.Suppliers ORDER BY City;
  ==============================================================*/
