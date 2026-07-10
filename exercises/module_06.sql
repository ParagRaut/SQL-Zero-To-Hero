/*==============================================================
  Module 6 — Subqueries & CTEs
  Topics: scalar / multi-row / correlated subqueries,
          IN / NOT IN / EXISTS / NOT EXISTS, derived tables,
          CTEs (WITH), recursive CTEs.
  ==============================================================*/

USE TechShop;
GO

-- 6.1  Scalar subquery — returns a single value used inline.
--      Products priced above the overall average.
SELECT ProductName, UnitPrice
FROM   dbo.Products
WHERE  UnitPrice > (SELECT AVG(UnitPrice) FROM dbo.Products);

-- 6.2  Multi-row subquery with IN.
--      Customers who have placed at least one order.
SELECT FirstName, LastName
FROM   dbo.Customers
WHERE  CustomerID IN (SELECT CustomerID FROM dbo.Orders);

-- 6.3  EXISTS — usually preferred over IN for "is there a match?".
--      Stops at the first match; NULL-safe (unlike NOT IN).
SELECT c.FirstName, c.LastName
FROM   dbo.Customers c
WHERE  EXISTS (SELECT 1 FROM dbo.Orders o WHERE o.CustomerID = c.CustomerID);

-- 6.4  NOT EXISTS — customers with NO orders (safe anti-join).
SELECT c.FirstName, c.LastName
FROM   dbo.Customers c
WHERE  NOT EXISTS (SELECT 1 FROM dbo.Orders o WHERE o.CustomerID = c.CustomerID);

/*  ⚠️ NOT IN trap: if the subquery returns any NULL, NOT IN yields no rows.
    Prefer NOT EXISTS for anti-joins.                                       */

-- 6.5  Correlated subquery — references the outer row.
--      Each product's price vs its own category average.
SELECT p.ProductName, p.UnitPrice,
       (SELECT AVG(p2.UnitPrice)
        FROM   dbo.Products p2
        WHERE  p2.CategoryID = p.CategoryID) AS CategoryAvg
FROM dbo.Products p;

-- 6.6  Derived table (subquery in FROM).
SELECT t.CategoryID, t.AvgPrice
FROM  (SELECT CategoryID, AVG(UnitPrice) AS AvgPrice
       FROM   dbo.Products
       GROUP BY CategoryID) AS t
WHERE t.AvgPrice > 100;

-- 6.7  CTE — same idea, more readable. You can chain multiple CTEs.
WITH CategoryAvg AS (
    SELECT CategoryID, AVG(UnitPrice) AS AvgPrice
    FROM   dbo.Products
    GROUP BY CategoryID
)
SELECT c.CategoryName, ca.AvgPrice
FROM   CategoryAvg ca
JOIN   dbo.Categories c ON c.CategoryID = ca.CategoryID
ORDER BY ca.AvgPrice DESC;

-- 6.8  Recursive CTE — walk the Category tree (parent → children).
WITH CategoryTree AS (
    -- anchor: top-level categories (no parent)
    SELECT CategoryID, CategoryName, ParentCategoryID, 0 AS Depth
    FROM   dbo.Categories
    WHERE  ParentCategoryID IS NULL
    UNION ALL
    -- recursive step: children of the previous level
    SELECT c.CategoryID, c.CategoryName, c.ParentCategoryID, ct.Depth + 1
    FROM   dbo.Categories c
    JOIN   CategoryTree  ct ON ct.CategoryID = c.ParentCategoryID
)
SELECT REPLICATE('  ', Depth) + CategoryName AS Indented, Depth
FROM   CategoryTree
ORDER BY Depth;

/*---------------- YOUR TURN ----------------
  a) Find products priced above the average price of ALL products.
  b) Using EXISTS, list products that have at least one review.
  c) Using NOT EXISTS, list customers who have never written a review.
  d) With a CTE, compute total revenue per order, then return only the
     orders whose revenue is above 1000.
  e) Recursive CTE: build the employee → manager chain (org hierarchy)
     starting from top-level employees (ManagerID IS NULL).
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT ProductName, UnitPrice FROM dbo.Products
     WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM dbo.Products);
  b) SELECT p.ProductName FROM dbo.Products p
     WHERE EXISTS (SELECT 1 FROM dbo.Reviews r WHERE r.ProductID = p.ProductID);
  c) SELECT c.FirstName, c.LastName FROM dbo.Customers c
     WHERE NOT EXISTS (SELECT 1 FROM dbo.Reviews r WHERE r.CustomerID = c.CustomerID);
  d) WITH Rev AS (
        SELECT OrderID, SUM(Quantity * UnitPrice * (1 - Discount)) AS Revenue
        FROM dbo.OrderItems GROUP BY OrderID)
     SELECT * FROM Rev WHERE Revenue > 1000 ORDER BY Revenue DESC;
  e) WITH OrgChart AS (
        SELECT EmployeeID, FirstName, LastName, ManagerID, 0 AS Depth
        FROM dbo.Employees WHERE ManagerID IS NULL
        UNION ALL
        SELECT e.EmployeeID, e.FirstName, e.LastName, e.ManagerID, oc.Depth + 1
        FROM dbo.Employees e JOIN OrgChart oc ON oc.EmployeeID = e.ManagerID)
     SELECT REPLICATE('  ', Depth) + FirstName + ' ' + LastName AS Person, Depth
     FROM OrgChart ORDER BY Depth;
  ==============================================================*/
