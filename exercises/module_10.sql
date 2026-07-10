/*==============================================================
  Module 10 — Schema Design & DDL
  Topics: CREATE / ALTER / DROP TABLE, schemas, data-type choice,
          IDENTITY / SEQUENCE / computed columns, normalization,
          naming conventions.
  --------------------------------------------------------------
  We build objects in a separate 'sandbox' schema so we never
  touch the real TechShop tables. Clean up at the end.
  ==============================================================*/

USE TechShop;
GO

-- 10.1  Create a schema to hold our practice objects.
IF SCHEMA_ID('sandbox') IS NULL
    EXEC('CREATE SCHEMA sandbox');
GO

-- 10.2  CREATE TABLE with sensible types, IDENTITY PK, defaults, computed col.
IF OBJECT_ID('sandbox.Widget') IS NOT NULL DROP TABLE sandbox.Widget;
GO
CREATE TABLE sandbox.Widget
(
    WidgetID     INT           IDENTITY(1,1) PRIMARY KEY,   -- surrogate key
    Name         NVARCHAR(100) NOT NULL,
    Price        DECIMAL(10,2) NOT NULL,
    Quantity     INT           NOT NULL DEFAULT (0),
    LineValue    AS (Price * Quantity),                     -- computed column
    CreatedAt    DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

-- 10.3  ALTER TABLE — add / modify / drop a column.
ALTER TABLE sandbox.Widget ADD Color NVARCHAR(20) NULL;
ALTER TABLE sandbox.Widget ALTER COLUMN Color NVARCHAR(30) NULL;
-- ALTER TABLE sandbox.Widget DROP COLUMN Color;

-- 10.4  SEQUENCE — a standalone number generator (shareable across tables).
IF OBJECT_ID('sandbox.OrderNoSeq') IS NOT NULL DROP SEQUENCE sandbox.OrderNoSeq;
GO
CREATE SEQUENCE sandbox.OrderNoSeq AS INT START WITH 1000 INCREMENT BY 1;
SELECT NEXT VALUE FOR sandbox.OrderNoSeq AS NextOrderNo;

-- 10.5  Insert + observe IDENTITY and computed column behaviour.
INSERT INTO sandbox.Widget (Name, Price, Quantity, Color)
VALUES ('Gizmo', 9.99, 3, 'Red'),
       ('Gadget', 19.50, 0, 'Blue');
SELECT * FROM sandbox.Widget;

/*  Normalization in one breath:
    1NF: atomic values, no repeating groups.
    2NF: no partial dependency on part of a composite key.
    3NF: no non-key column depends on another non-key column.
    Denormalize deliberately (e.g., store a computed total) only for
    a measured performance reason.                                       */

/*  Naming conventions used in TechShop:
    - Singular-ish table names (Products, Orders).
    - PascalCase columns; PK = <Table>ID; FK matches the referenced PK name.  */

/*---------------- YOUR TURN ----------------
  a) In the sandbox schema, CREATE TABLE sandbox.Author with:
     AuthorID (IDENTITY PK), FullName (NVARCHAR NOT NULL),
     Country (NVARCHAR NULL), CreatedAt (DATETIME2 default now).
  b) ALTER it to add a BIT column IsActive defaulting to 1.
  c) Insert two authors and SELECT them.
  d) In a comment, say which normal form is violated if you stored a
     comma-separated list of book titles in an Author row.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)  Answer:


-- 10.9  CLEAN UP the sandbox when you're done.
-- DROP TABLE IF EXISTS sandbox.Widget;
-- DROP TABLE IF EXISTS sandbox.Author;
-- DROP SEQUENCE IF EXISTS sandbox.OrderNoSeq;
-- DROP SCHEMA IF EXISTS sandbox;

/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) CREATE TABLE sandbox.Author (
        AuthorID  INT IDENTITY(1,1) PRIMARY KEY,
        FullName  NVARCHAR(100) NOT NULL,
        Country   NVARCHAR(50) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME());
  b) ALTER TABLE sandbox.Author ADD IsActive BIT NOT NULL DEFAULT (1);
  c) INSERT INTO sandbox.Author (FullName, Country)
     VALUES ('Ada Lovelace', 'UK'), ('Alan Turing', 'UK');
     SELECT * FROM sandbox.Author;
  d) 1NF — a comma-separated list is a repeating group / non-atomic value.
  ==============================================================*/
