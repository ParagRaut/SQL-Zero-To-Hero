/*==============================================================
  Module 5 — Joins
  Topics: INNER / LEFT / RIGHT / FULL / CROSS joins, self-joins,
          multi-table joins, ON vs WHERE for outer joins, anti-joins.
  ==============================================================*/

USE TechShop;
GO

-- 5.1  INNER JOIN — only rows that match in BOTH tables.
SELECT p.ProductName, c.CategoryName
FROM   dbo.Products   AS p
JOIN   dbo.Categories AS c ON c.CategoryID = p.CategoryID;

-- 5.2  LEFT JOIN — keep ALL products, even those with no supplier.
--      Unmatched supplier columns come back as NULL.
SELECT p.ProductName, s.SupplierName
FROM   dbo.Products  AS p
LEFT JOIN dbo.Suppliers AS s ON s.SupplierID = p.SupplierID;

-- 5.3  Multi-table join — orders with their customer and handling employee.
SELECT
    o.OrderID,
    o.OrderDate,
    cu.FirstName + ' ' + cu.LastName AS Customer,
    e.FirstName + ' ' + e.LastName   AS Employee
FROM dbo.Orders    AS o
JOIN dbo.Customers AS cu ON cu.CustomerID = o.CustomerID
LEFT JOIN dbo.Employees AS e ON e.EmployeeID = o.EmployeeID;

-- 5.4  Self-join — employee to their manager (same table twice).
SELECT
    e.FirstName + ' ' + e.LastName AS Employee,
    m.FirstName + ' ' + m.LastName AS Manager
FROM dbo.Employees AS e
LEFT JOIN dbo.Employees AS m ON m.EmployeeID = e.ManagerID;

-- 5.5  ON vs WHERE for OUTER joins — a classic bug.
--      Filtering the RIGHT table in WHERE turns a LEFT join into an INNER join.
--      Put the filter in ON to keep unmatched left rows.
SELECT p.ProductName, s.SupplierName
FROM   dbo.Products AS p
LEFT JOIN dbo.Suppliers AS s
       ON s.SupplierID = p.SupplierID
      AND s.Country = 'USA';        -- keep all products; supplier only if USA

-- 5.6  Anti-join — products that have NO reviews.
SELECT p.ProductName
FROM   dbo.Products AS p
LEFT JOIN dbo.Reviews AS r ON r.ProductID = p.ProductID
WHERE  r.ReviewID IS NULL;         -- no matching review row

/*---------------- YOUR TURN ----------------
  a) List each product with its supplier's name and country (INNER JOIN).
  b) List every customer and their order count, INCLUDING customers with
     zero orders (LEFT JOIN + GROUP BY).
  c) Show each order's line items with product names
     (Orders → OrderItems → Products).
  d) Find products that have never been ordered (anti-join on OrderItems).
  e) List employees alongside their department name.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT p.ProductName, s.SupplierName, s.Country
     FROM dbo.Products p JOIN dbo.Suppliers s ON s.SupplierID = p.SupplierID;
  b) SELECT cu.CustomerID, cu.FirstName, cu.LastName, COUNT(o.OrderID) AS Orders
     FROM dbo.Customers cu
     LEFT JOIN dbo.Orders o ON o.CustomerID = cu.CustomerID
     GROUP BY cu.CustomerID, cu.FirstName, cu.LastName
     ORDER BY Orders DESC;
  c) SELECT o.OrderID, p.ProductName, oi.Quantity, oi.UnitPrice
     FROM dbo.Orders o
     JOIN dbo.OrderItems oi ON oi.OrderID = o.OrderID
     JOIN dbo.Products p ON p.ProductID = oi.ProductID;
  d) SELECT p.ProductName
     FROM dbo.Products p
     LEFT JOIN dbo.OrderItems oi ON oi.ProductID = p.ProductID
     WHERE oi.OrderItemID IS NULL;
  e) SELECT e.FirstName, e.LastName, d.DepartmentName
     FROM dbo.Employees e
     JOIN dbo.Departments d ON d.DepartmentID = e.DepartmentID;
  ==============================================================*/
