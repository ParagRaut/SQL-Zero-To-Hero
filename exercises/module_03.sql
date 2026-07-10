/*==============================================================
  Module 3 — Built-in Functions
  Topics: string, date/time, numeric, conditional functions,
          CAST / CONVERT / TRY_CAST.
  ==============================================================*/

USE TechShop;
GO

-- 3.1  String functions.
SELECT
    ProductName,
    LEN(ProductName)                         AS NameLength,
    UPPER(ProductName)                       AS Upper,
    LEFT(ProductName, 3)                      AS First3,
    SUBSTRING(ProductName, 1, 5)              AS First5,
    REPLACE(ProductName, ' ', '_')           AS Underscored
FROM dbo.Products;

-- 3.2  CONCAT handles NULLs gracefully (treats NULL as empty string),
--      unlike the + operator which returns NULL if any part is NULL.
SELECT
    CONCAT(FirstName, ' ', LastName)         AS FullName,
    TRIM(Email)                              AS CleanEmail
FROM dbo.Customers;

-- 3.3  CHARINDEX finds the position of a substring (0 = not found).
SELECT Email, CHARINDEX('@', Email) AS AtPosition
FROM   dbo.Customers;

-- 3.4  Date/time functions.
SELECT
    GETDATE()                                AS NowLocal,
    SYSDATETIME()                            AS NowPrecise,
    DATEADD(DAY, 30, OrderDate)              AS Plus30Days,
    DATEDIFF(DAY, OrderDate, GETDATE())      AS DaysSinceOrder,
    DATEPART(YEAR, OrderDate)                AS OrderYear,
    EOMONTH(OrderDate)                       AS EndOfOrderMonth
FROM dbo.Orders;

-- 3.5  Numeric functions.
SELECT
    UnitPrice,
    ROUND(UnitPrice, 0)                      AS Rounded,
    CEILING(UnitPrice)                       AS RoundedUp,
    FLOOR(UnitPrice)                         AS RoundedDown,
    UnitPrice % 10                           AS PriceModulo10
FROM dbo.Products;

-- 3.6  Conditional expressions.
SELECT
    ProductName,
    UnitPrice,
    CASE
        WHEN UnitPrice < 50  THEN 'Cheap'
        WHEN UnitPrice < 200 THEN 'Mid'
        ELSE 'Premium'
    END                                      AS PriceBand,
    IIF(UnitsInStock = 0, 'Out of stock', 'Available') AS Availability,
    NULLIF(UnitsInStock, 0)                  AS StockOrNull   -- NULL when 0
FROM dbo.Products;

-- 3.7  CAST vs CONVERT vs TRY_CAST.
--      TRY_CAST returns NULL instead of erroring on bad input.
SELECT
    CAST(UnitPrice AS INT)                    AS PriceAsInt,
    CONVERT(VARCHAR(20), OrderDate, 23)       AS IsoDate,   -- style 23 = yyyy-mm-dd
    TRY_CAST('not a number' AS INT)           AS SafeCast   -- returns NULL
FROM dbo.Orders;

/*---------------- YOUR TURN ----------------
  a) Show each customer's email in UPPERCASE and its length.
  b) Show the domain part of each customer's email
     (everything after the '@'). Hint: SUBSTRING + CHARINDEX.
  c) For each order, show OrderDate and how many days ago it was placed.
  d) Classify products into 'Low' (<100) / 'High' (>=100) stock-value bands
     using CASE, where stock value = UnitPrice * UnitsInStock.
  e) Show OrderDate formatted as yyyy-MM-dd text.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT UPPER(Email) AS UpperEmail, LEN(Email) AS EmailLength
     FROM dbo.Customers;
  b) SELECT Email,
            SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS Domain
     FROM dbo.Customers;
  c) SELECT OrderID, OrderDate, DATEDIFF(DAY, OrderDate, GETDATE()) AS DaysAgo
     FROM dbo.Orders;
  d) SELECT ProductName,
            CASE WHEN UnitPrice * UnitsInStock < 100 THEN 'Low' ELSE 'High' END AS StockValueBand
     FROM dbo.Products;
  e) SELECT OrderID, CONVERT(VARCHAR(10), OrderDate, 23) AS OrderDateText
     FROM dbo.Orders;
  ==============================================================*/
