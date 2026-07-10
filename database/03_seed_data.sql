/*==============================================================
  TechShop — Step 3: Seed realistic sample data
  Run AFTER 02_create_tables.sql.

  Produces a small-but-realistic dataset:
    4 departments, 10 employees, 12 categories, 8 suppliers,
    ~40 products, 30 customers, ~200 orders, order items,
    payments and reviews.
  For the performance/index modules, ALSO run 05_generate_large_data.sql.
  ==============================================================*/

USE TechShop;
GO
SET NOCOUNT ON;

/*-------------------------------------------------
  Departments
-------------------------------------------------*/
INSERT INTO dbo.Departments (DepartmentName) VALUES
('Management'), ('Sales'), ('Support'), ('Warehouse');

/*-------------------------------------------------
  Employees  (ManagerID references earlier rows)
-------------------------------------------------*/
-- CEO first (no manager)
INSERT INTO dbo.Employees (FirstName, LastName, Title, ManagerID, DepartmentID, HireDate, Salary, Email) VALUES
('Alice','Morgan','CEO',            NULL, 1, '2015-01-05', 220000, 'alice.morgan@techshop.com');   -- 1
INSERT INTO dbo.Employees (FirstName, LastName, Title, ManagerID, DepartmentID, HireDate, Salary, Email) VALUES
('Ben','Carter','Sales Manager',    1,    2, '2016-03-10', 120000, 'ben.carter@techshop.com'),     -- 2
('Chloe','Nguyen','Support Manager',1,    3, '2016-07-22', 118000, 'chloe.nguyen@techshop.com'),   -- 3
('David','Owens','Warehouse Manager',1,   4, '2017-02-14',  98000, 'david.owens@techshop.com'),    -- 4
('Emma','Reed','Sales Rep',         2,    2, '2018-05-30',  62000, 'emma.reed@techshop.com'),       -- 5
('Frank','Silva','Sales Rep',       2,    2, '2019-09-01',  60000, 'frank.silva@techshop.com'),     -- 6
('Grace','Hall','Support Agent',    3,    3, '2019-11-15',  54000, 'grace.hall@techshop.com'),      -- 7
('Henry','Ito','Support Agent',     3,    3, '2020-04-20',  52000, 'henry.ito@techshop.com'),       -- 8
('Ivy','Brooks','Stock Clerk',      4,    4, '2021-01-11',  45000, 'ivy.brooks@techshop.com'),      -- 9
('Jack','Lee','Sales Rep',          2,    2, '2022-06-05',  58000, 'jack.lee@techshop.com');        -- 10

/*-------------------------------------------------
  Categories  (self-referencing tree)
-------------------------------------------------*/
INSERT INTO dbo.Categories (CategoryName, ParentCategoryID) VALUES
('Electronics', NULL),        -- 1
('Computers', 1),             -- 2
('Mobile', 1),                -- 3
('Accessories', 1),           -- 4
('Laptops', 2),               -- 5
('Desktops', 2),              -- 6
('Smartphones', 3),           -- 7
('Tablets', 3),               -- 8
('Audio', 4),                 -- 9
('Cables & Chargers', 4),     -- 10
('Storage', 4),               -- 11
('Wearables', 1);             -- 12

/*-------------------------------------------------
  Suppliers
-------------------------------------------------*/
INSERT INTO dbo.Suppliers (SupplierName, ContactEmail, City, Country) VALUES
('Globex Components','sales@globex.com','Austin','USA'),
('Initech Devices','hello@initech.com','San Jose','USA'),
('Umbrella Tech','contact@umbrella.co','London','UK'),
('Stark Peripherals','orders@stark.io','Berlin','Germany'),
('Wayne Hardware','supply@wayne.com','Toronto','Canada'),
('Hooli Gadgets','info@hooli.com','Bengaluru','India'),
('Acme Supplies','acme@acme.com','Sydney','Australia'),
('Soylent Parts','parts@soylent.com','Osaka','Japan');

/*-------------------------------------------------
  Products (~40)
-------------------------------------------------*/
INSERT INTO dbo.Products (ProductName, CategoryID, SupplierID, UnitPrice, UnitsInStock, Discontinued) VALUES
('UltraBook 14 Pro',        5, 2, 1299.00, 40, 0),
('UltraBook 15 Air',        5, 2,  999.00, 55, 0),
('PowerLap Gaming 17',      5, 4, 1799.00, 18, 0),
('BudgetBook 14',           5, 6,  499.00, 90, 0),
('TowerPC Ryzen 7',         6, 4, 1099.00, 25, 0),
('TowerPC Core i5',         6, 1,  849.00, 30, 0),
('MiniPC Cube',             6, 6,  429.00, 60, 0),
('Galaxy S Ultra',          7, 6,  1099.00, 70, 0),
('Galaxy S Lite',           7, 6,  599.00, 120, 0),
('iFone 15',                7, 2, 1199.00, 65, 0),
('iFone SE',                7, 2,  529.00, 80, 0),
('PixelView 8',             7, 1,  899.00, 45, 0),
('Tab Pro 11',              8, 2,  749.00, 50, 0),
('Tab Mini 8',              8, 6,  349.00, 100, 0),
('Tab Kids 7',              8, 7,  199.00, 75, 0),
('NoiseCancel Headphones',  9, 3,  299.00, 60, 0),
('Studio Over-Ear',         9, 3,  179.00, 85, 0),
('EarBuds Pro',             9, 2,  199.00, 150, 0),
('EarBuds Lite',            9, 6,   59.00, 300, 0),
('Bluetooth Speaker Mini',  9, 7,   79.00, 130, 0),
('USB-C Cable 1m',         10, 1,   12.99, 500, 0),
('USB-C Cable 2m',         10, 1,   16.99, 400, 0),
('Lightning Cable 1m',     10, 8,   14.99, 350, 0),
('65W GaN Charger',        10, 4,   45.00, 200, 0),
('Wireless Charge Pad',    10, 3,   35.00, 180, 0),
('SSD 1TB NVMe',           11, 1,  109.00, 140, 0),
('SSD 2TB NVMe',           11, 1,  189.00, 90, 0),
('Portable SSD 1TB',       11, 5,  139.00, 110, 0),
('microSD 256GB',          11, 8,   29.99, 400, 0),
('USB Flash 128GB',        11, 8,   17.99, 320, 0),
('SmartWatch Series 6',    12, 2,  399.00, 70, 0),
('SmartWatch SE',          12, 2,  249.00, 95, 0),
('FitBand 4',              12, 6,   99.00, 160, 0),
('Laptop Sleeve 14',        4, 5,   24.99, 220, 0),
('Wireless Mouse',          4, 4,   29.99, 260, 0),
('Mechanical Keyboard',     4, 4,   89.00, 120, 0),
('Webcam 1080p',            4, 3,   59.00, 140, 0),
('USB Hub 7-Port',          4, 1,   34.99, 175, 0),
('Old Netbook 10',          5, 6,  199.00,  0, 1),   -- discontinued
('Legacy MP3 Player',       9, 8,   49.00,  0, 1);   -- discontinued

/*-------------------------------------------------
  Customers (30)
-------------------------------------------------*/
INSERT INTO dbo.Customers (FirstName, LastName, Email, Phone, City, Country) VALUES
('Liam','Anderson','liam.anderson@mail.com','+1-202-555-0101','New York','USA'),
('Olivia','Baker','olivia.baker@mail.com','+1-202-555-0102','Chicago','USA'),
('Noah','Clark','noah.clark@mail.com','+1-202-555-0103','Los Angeles','USA'),
('Emma','Davis','emma.davis@mail.com','+44-20-7946-0001','London','UK'),
('Oliver','Evans','oliver.evans@mail.com','+44-20-7946-0002','Manchester','UK'),
('Ava','Foster','ava.foster@mail.com','+49-30-123456','Berlin','Germany'),
('Elijah','Green','elijah.green@mail.com','+49-89-123456','Munich','Germany'),
('Sophia','Harris','sophia.harris@mail.com','+1-416-555-0201','Toronto','Canada'),
('James','Irwin','james.irwin@mail.com','+1-604-555-0202','Vancouver','Canada'),
('Isabella','Jones','isabella.jones@mail.com','+91-80-40001111','Bengaluru','India'),
('Lucas','Khan','lucas.khan@mail.com','+91-22-40002222','Mumbai','India'),
('Mia','Lopez','mia.lopez@mail.com','+61-2-5550-0301','Sydney','Australia'),
('Mason','Martin','mason.martin@mail.com','+61-3-5550-0302','Melbourne','Australia'),
('Charlotte','Nelson','charlotte.nelson@mail.com','+81-3-5550-0401','Tokyo','Japan'),
('Ethan','Ortiz','ethan.ortiz@mail.com','+81-6-5550-0402','Osaka','Japan'),
('Amelia','Parker','amelia.parker@mail.com','+1-202-555-0104','Houston','USA'),
('Logan','Quinn','logan.quinn@mail.com','+1-202-555-0105','Phoenix','USA'),
('Harper','Reed','harper.reed@mail.com','+44-20-7946-0003','Leeds','UK'),
('Benjamin','Scott','benjamin.scott@mail.com','+49-40-123456','Hamburg','Germany'),
('Evelyn','Turner','evelyn.turner@mail.com','+1-416-555-0203','Ottawa','Canada'),
('Henry','Underwood','henry.underwood@mail.com','+91-11-40003333','Delhi','India'),
('Abigail','Vance','abigail.vance@mail.com','+61-7-5550-0303','Brisbane','Australia'),
('Sebastian','White','sebastian.white@mail.com','+81-52-5550-0403','Nagoya','Japan'),
('Emily','Young','emily.young@mail.com','+1-202-555-0106','Seattle','USA'),
('Jack','Zimmer','jack.zimmer@mail.com','+44-20-7946-0004','Bristol','UK'),
('Grace','Adams','grace.adams@mail.com','+1-202-555-0107','Boston','USA'),
('Daniel','Brooks','daniel.brooks@mail.com','+49-69-123456','Frankfurt','Germany'),
('Chloe','Cole','chloe.cole@mail.com','+1-416-555-0204','Calgary','Canada'),
('Matthew','Diaz','matthew.diaz@mail.com','+91-44-40004444','Chennai','India'),
('Zoe','Ellis','zoe.ellis@mail.com','+61-8-5550-0304','Perth','Australia');

/*-------------------------------------------------
  Orders (~200) — generated deterministically
  Spread across the last ~2 years. Uses a numbers
  table built from system objects.
-------------------------------------------------*/
;WITH Numbers AS (
    SELECT TOP (200) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Orders (CustomerID, EmployeeID, OrderDate, Status, ShipCity, ShipCountry)
SELECT
    ((n * 7) % 30) + 1                                   AS CustomerID,
    CASE WHEN n % 5 = 0 THEN NULL ELSE ((n % 4) + 5) END AS EmployeeID,  -- sales reps 5,6,7,8 (or NULL)
    DATEADD(DAY, -((n * 3) % 730), CAST('2026-06-30' AS DATE)) AS OrderDate,
    CHOOSE(((n % 5) + 1), 'Delivered','Shipped','Paid','Delivered','Pending') AS Status,
    c.City, c.Country
FROM Numbers
JOIN dbo.Customers c ON c.CustomerID = ((Numbers.n * 7) % 30) + 1;

/*-------------------------------------------------
  OrderItems — 1 to 3 items per order
-------------------------------------------------*/
;WITH ItemSpec AS (
    SELECT o.OrderID,
           v.slot,
           -- pick a product id 1..38 (avoid the 2 discontinued 39,40 for sales)
           (((o.OrderID * 3) + v.slot * 11) % 38) + 1 AS ProductID,
           ((o.OrderID + v.slot) % 3) + 1              AS Quantity
    FROM dbo.Orders o
    CROSS APPLY (VALUES (0),(1),(2)) AS v(slot)
    WHERE v.slot <= (o.OrderID % 3)   -- 1..3 items depending on order
)
INSERT INTO dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice, Discount)
SELECT s.OrderID, s.ProductID, s.Quantity, p.UnitPrice,
       CASE WHEN s.OrderID % 7 = 0 THEN 0.10 ELSE 0 END
FROM ItemSpec s
JOIN dbo.Products p ON p.ProductID = s.ProductID;

/*-------------------------------------------------
  Payments — for orders that are Paid/Shipped/Delivered
-------------------------------------------------*/
INSERT INTO dbo.Payments (OrderID, Amount, PaymentMethod, PaidAt)
SELECT o.OrderID,
       SUM(oi.Quantity * oi.UnitPrice * (1 - oi.Discount)) AS Amount,
       CHOOSE((o.OrderID % 4) + 1, 'Card','PayPal','BankTransfer','COD'),
       CAST(DATEADD(HOUR, 6, o.OrderDate) AS DATETIME2(0))
FROM dbo.Orders o
JOIN dbo.OrderItems oi ON oi.OrderID = o.OrderID
WHERE o.Status IN ('Paid','Shipped','Delivered')
GROUP BY o.OrderID, o.OrderDate;

/*-------------------------------------------------
  Reviews — some products get reviews
-------------------------------------------------*/
;WITH ReviewSpec AS (
    SELECT DISTINCT
           oi.ProductID,
           o.CustomerID,
           (ABS(CHECKSUM(oi.ProductID, o.CustomerID)) % 5) + 1 AS Rating
    FROM dbo.OrderItems oi
    JOIN dbo.Orders o ON o.OrderID = oi.OrderID
    WHERE (oi.OrderItemID % 4) = 0
)
INSERT INTO dbo.Reviews (ProductID, CustomerID, Rating, Comment)
SELECT ProductID, CustomerID, Rating,
       CASE Rating
            WHEN 5 THEN 'Excellent — highly recommend!'
            WHEN 4 THEN 'Very good, works as expected.'
            WHEN 3 THEN 'Okay for the price.'
            WHEN 2 THEN 'Not great, had some issues.'
            ELSE 'Disappointed, would not buy again.'
       END
FROM ReviewSpec;

/*-------------------------------------------------
  Summary
-------------------------------------------------*/
SELECT 'Departments' AS TableName, COUNT(*) AS Rows FROM dbo.Departments
UNION ALL SELECT 'Employees', COUNT(*) FROM dbo.Employees
UNION ALL SELECT 'Categories', COUNT(*) FROM dbo.Categories
UNION ALL SELECT 'Suppliers', COUNT(*) FROM dbo.Suppliers
UNION ALL SELECT 'Products', COUNT(*) FROM dbo.Products
UNION ALL SELECT 'Customers', COUNT(*) FROM dbo.Customers
UNION ALL SELECT 'Orders', COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderItems', COUNT(*) FROM dbo.OrderItems
UNION ALL SELECT 'Payments', COUNT(*) FROM dbo.Payments
UNION ALL SELECT 'Reviews', COUNT(*) FROM dbo.Reviews;

PRINT 'Seed data loaded. You are ready for Module 0!';
GO
