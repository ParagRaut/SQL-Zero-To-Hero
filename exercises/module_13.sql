/*==============================================================
  Module 13 — Stored Procedures & Functions
  Topics: procedures (params, defaults, OUTPUT, RETURN),
          scalar & table-valued functions (inline vs multi-statement),
          variables, control-of-flow, TRY...CATCH.
  ==============================================================*/

USE TechShop;
GO

-- 13.1  Variables & control-of-flow (a batch, not yet a proc).
DECLARE @threshold DECIMAL(10,2) = 100;
DECLARE @count INT;
SELECT @count = COUNT(*) FROM dbo.Products WHERE UnitPrice > @threshold;
IF @count > 0
    PRINT CONCAT(@count, ' products cost more than ', @threshold);
ELSE
    PRINT 'No expensive products.';
GO

-- 13.2  A stored procedure with an input parameter + a default.
CREATE OR ALTER PROCEDURE dbo.usp_ProductsByCategory
    @CategoryID INT,
    @MinPrice   DECIMAL(10,2) = 0        -- default value
AS
BEGIN
    SET NOCOUNT ON;                       -- suppress "rows affected" messages
    SELECT ProductID, ProductName, UnitPrice
    FROM   dbo.Products
    WHERE  CategoryID = @CategoryID
      AND  UnitPrice >= @MinPrice
    ORDER BY UnitPrice DESC;
END
GO
EXEC dbo.usp_ProductsByCategory @CategoryID = 1, @MinPrice = 50;

-- 13.3  OUTPUT parameter + RETURN code.
CREATE OR ALTER PROCEDURE dbo.usp_CountOrders
    @CustomerID INT,
    @OrderCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @OrderCount = COUNT(*) FROM dbo.Orders WHERE CustomerID = @CustomerID;
    RETURN 0;                              -- 0 = success by convention
END
GO
DECLARE @n INT;
EXEC dbo.usp_CountOrders @CustomerID = 1, @OrderCount = @n OUTPUT;
SELECT @n AS OrdersForCustomer1;

-- 13.4  TRY...CATCH for error handling inside a proc.
CREATE OR ALTER PROCEDURE dbo.usp_SafeDivide @a INT, @b INT
AS
BEGIN
    BEGIN TRY
        SELECT @a / @b AS Result;          -- divide by zero throws
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrNo, ERROR_MESSAGE() AS ErrMsg;
    END CATCH
END
GO
EXEC dbo.usp_SafeDivide 10, 0;

-- 13.5  Inline table-valued function (iTVF) — the fast kind (gets inlined).
CREATE OR ALTER FUNCTION dbo.fn_ProductsOver(@price DECIMAL(10,2))
RETURNS TABLE
AS
RETURN
(
    SELECT ProductID, ProductName, UnitPrice
    FROM   dbo.Products
    WHERE  UnitPrice > @price
);
GO
SELECT * FROM dbo.fn_ProductsOver(200);

-- 13.6  Scalar function — convenient but can hurt performance if used per-row.
CREATE OR ALTER FUNCTION dbo.fn_LineRevenue(@qty INT, @price DECIMAL(10,2), @disc DECIMAL(4,3))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN @qty * @price * (1 - @disc);
END
GO
SELECT TOP (5) OrderItemID, dbo.fn_LineRevenue(Quantity, UnitPrice, Discount) AS Rev
FROM dbo.OrderItems;

/*  When to use what:
    - View: a saved SELECT (no parameters).
    - Inline TVF: a "parameterized view" — prefer over scalar/multi-statement.
    - Scalar function: single value; beware row-by-row overhead.
    - Stored proc: multi-statement logic, side effects, transactions.       */

/*---------------- YOUR TURN ----------------
  a) Write usp_CustomersByCountry @Country that returns customers in a country.
  b) Write an inline TVF fn_OrdersByStatus(@Status) returning matching orders.
  c) Write a scalar fn_FullName(@first, @last) returning 'First Last'
     (use CONCAT to be NULL-safe).
  d) Write usp_TotalRevenueForOrder @OrderID with an OUTPUT @Revenue param.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) CREATE OR ALTER PROCEDURE dbo.usp_CustomersByCountry @Country NVARCHAR(50)
     AS BEGIN SET NOCOUNT ON;
        SELECT CustomerID, FirstName, LastName, City
        FROM dbo.Customers WHERE Country = @Country; END
  b) CREATE OR ALTER FUNCTION dbo.fn_OrdersByStatus(@Status NVARCHAR(20))
     RETURNS TABLE AS RETURN (
        SELECT OrderID, OrderDate, CustomerID FROM dbo.Orders WHERE Status = @Status);
  c) CREATE OR ALTER FUNCTION dbo.fn_FullName(@first NVARCHAR(50), @last NVARCHAR(50))
     RETURNS NVARCHAR(101) AS BEGIN RETURN CONCAT(@first, ' ', @last); END
  d) CREATE OR ALTER PROCEDURE dbo.usp_TotalRevenueForOrder
        @OrderID INT, @Revenue DECIMAL(12,2) OUTPUT
     AS BEGIN SET NOCOUNT ON;
        SELECT @Revenue = SUM(Quantity * UnitPrice * (1 - Discount))
        FROM dbo.OrderItems WHERE OrderID = @OrderID; END
  ==============================================================*/
