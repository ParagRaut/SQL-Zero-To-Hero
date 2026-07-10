/*==============================================================
  TechShop — Step 2: Create tables & relationships
  Run AFTER 01_create_database.sql.

  Schema (an e-commerce store):
     Departments 1--* Employees (Employees also self-reference Manager)
     Categories (self-referencing tree) 1--* Products
     Suppliers 1--* Products
     Customers 1--* Orders *--1 Employees
     Orders 1--* OrderItems *--1 Products
     Orders 1--* Payments
     Products 1--* Reviews *--1 Customers
  ==============================================================*/

USE TechShop;
GO

-- Drop in dependency order so the script is re-runnable
IF OBJECT_ID('dbo.Reviews')      IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.Payments')     IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID('dbo.OrderItems')   IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders')       IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Products')     IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Suppliers')    IS NOT NULL DROP TABLE dbo.Suppliers;
IF OBJECT_ID('dbo.Categories')   IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Customers')    IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Employees')    IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Departments')  IS NOT NULL DROP TABLE dbo.Departments;
GO

CREATE TABLE dbo.Departments (
    DepartmentID   INT           IDENTITY(1,1) CONSTRAINT PK_Departments PRIMARY KEY,
    DepartmentName NVARCHAR(50)  NOT NULL CONSTRAINT UQ_Departments_Name UNIQUE
);
GO

CREATE TABLE dbo.Employees (
    EmployeeID   INT           IDENTITY(1,1) CONSTRAINT PK_Employees PRIMARY KEY,
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    Title        NVARCHAR(60)  NULL,
    ManagerID    INT           NULL,
    DepartmentID INT           NULL,
    HireDate     DATE          NOT NULL,
    Salary       DECIMAL(10,2) NOT NULL CONSTRAINT CK_Employees_Salary CHECK (Salary >= 0),
    Email        NVARCHAR(120) NULL,
    CONSTRAINT FK_Employees_Manager    FOREIGN KEY (ManagerID)    REFERENCES dbo.Employees(EmployeeID),
    CONSTRAINT FK_Employees_Department FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID)
);
GO

CREATE TABLE dbo.Categories (
    CategoryID       INT           IDENTITY(1,1) CONSTRAINT PK_Categories PRIMARY KEY,
    CategoryName     NVARCHAR(60)  NOT NULL,
    ParentCategoryID INT           NULL,
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryID) REFERENCES dbo.Categories(CategoryID)
);
GO

CREATE TABLE dbo.Suppliers (
    SupplierID   INT           IDENTITY(1,1) CONSTRAINT PK_Suppliers PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    ContactEmail NVARCHAR(120) NULL,
    City         NVARCHAR(60)  NULL,
    Country      NVARCHAR(60)  NULL
);
GO

CREATE TABLE dbo.Products (
    ProductID    INT           IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY,
    ProductName  NVARCHAR(120) NOT NULL,
    CategoryID   INT           NULL,
    SupplierID   INT           NULL,
    UnitPrice    DECIMAL(10,2) NOT NULL CONSTRAINT CK_Products_Price CHECK (UnitPrice >= 0),
    UnitsInStock INT           NOT NULL CONSTRAINT DF_Products_Stock DEFAULT (0),
    Discontinued BIT           NOT NULL CONSTRAINT DF_Products_Disc DEFAULT (0),
    CreatedAt    DATETIME2(0)  NOT NULL CONSTRAINT DF_Products_Created DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT FK_Products_Supplier FOREIGN KEY (SupplierID) REFERENCES dbo.Suppliers(SupplierID)
);
GO

CREATE TABLE dbo.Customers (
    CustomerID INT           IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
    FirstName  NVARCHAR(50)  NOT NULL,
    LastName   NVARCHAR(50)  NOT NULL,
    Email      NVARCHAR(120) NOT NULL CONSTRAINT UQ_Customers_Email UNIQUE,
    Phone      NVARCHAR(30)  NULL,
    City       NVARCHAR(60)  NULL,
    Country    NVARCHAR(60)  NULL,
    CreatedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_Customers_Created DEFAULT (SYSDATETIME())
);
GO

CREATE TABLE dbo.Orders (
    OrderID     INT          IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerID  INT          NOT NULL,
    EmployeeID  INT          NULL,
    OrderDate   DATE         NOT NULL,
    Status      NVARCHAR(20) NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('Pending')
                 CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending','Paid','Shipped','Delivered','Cancelled')),
    ShipCity    NVARCHAR(60) NULL,
    ShipCountry NVARCHAR(60) NULL,
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT FK_Orders_Employee FOREIGN KEY (EmployeeID) REFERENCES dbo.Employees(EmployeeID)
);
GO

CREATE TABLE dbo.OrderItems (
    OrderItemID INT           IDENTITY(1,1) CONSTRAINT PK_OrderItems PRIMARY KEY,
    OrderID     INT           NOT NULL,
    ProductID   INT           NOT NULL,
    Quantity    INT           NOT NULL CONSTRAINT CK_OrderItems_Qty CHECK (Quantity > 0),
    UnitPrice   DECIMAL(10,2) NOT NULL,   -- price captured at time of sale
    Discount    DECIMAL(4,2)  NOT NULL CONSTRAINT DF_OrderItems_Disc DEFAULT (0)
                 CONSTRAINT CK_OrderItems_Disc CHECK (Discount >= 0 AND Discount <= 1),
    CONSTRAINT FK_OrderItems_Order   FOREIGN KEY (OrderID)   REFERENCES dbo.Orders(OrderID),
    CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);
GO

CREATE TABLE dbo.Payments (
    PaymentID     INT           IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
    OrderID       INT           NOT NULL,
    Amount        DECIMAL(12,2) NOT NULL CONSTRAINT CK_Payments_Amount CHECK (Amount >= 0),
    PaymentMethod NVARCHAR(20)  NOT NULL
                   CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN ('Card','PayPal','BankTransfer','COD')),
    PaidAt        DATETIME2(0)  NOT NULL,
    CONSTRAINT FK_Payments_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID)
);
GO

CREATE TABLE dbo.Reviews (
    ReviewID   INT           IDENTITY(1,1) CONSTRAINT PK_Reviews PRIMARY KEY,
    ProductID  INT           NOT NULL,
    CustomerID INT           NOT NULL,
    Rating     TINYINT       NOT NULL CONSTRAINT CK_Reviews_Rating CHECK (Rating BETWEEN 1 AND 5),
    Comment    NVARCHAR(400) NULL,
    CreatedAt  DATETIME2(0)  NOT NULL CONSTRAINT DF_Reviews_Created DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Reviews_Product  FOREIGN KEY (ProductID)  REFERENCES dbo.Products(ProductID),
    CONSTRAINT FK_Reviews_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID)
);
GO

PRINT 'Tables created. Next: run 03_seed_data.sql';
GO
