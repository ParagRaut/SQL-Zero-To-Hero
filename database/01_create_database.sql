/*==============================================================
  TechShop — Step 1: Create the database
  Run this FIRST. Safe to re-run (drops & recreates).
  ==============================================================*/

USE master;
GO

-- Close existing connections and drop if it already exists
IF DB_ID('TechShop') IS NOT NULL
BEGIN
    ALTER DATABASE TechShop SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TechShop;
END
GO

CREATE DATABASE TechShop;
GO

-- Use a consistent, case-insensitive collation for the course
ALTER DATABASE TechShop COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

PRINT 'TechShop database created. Next: run 02_create_tables.sql';
GO
