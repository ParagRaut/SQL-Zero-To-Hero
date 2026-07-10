/*==============================================================
  Module 22 — Security
  Topics: logins vs users, roles, GRANT/DENY/REVOKE, schema-level
          permissions, ownership chaining, least privilege,
          parameterization vs SQL injection.
  --------------------------------------------------------------
  ⚠️ Creating logins/users needs sufficient privileges. Everything
     below is wrapped so you can practice and then clean up.
  ==============================================================*/

USE TechShop;
GO

/*  Principals hierarchy:
    - LOGIN  = server-level identity (authenticates a connection).
    - USER   = database-level identity (mapped from a login).
    - ROLE   = a named bundle of permissions you assign users to.
    Permission verbs:
    - GRANT  = allow.   DENY = explicitly forbid (overrides GRANT).
    - REVOKE = remove a previously granted/denied entry (neutral).        */

-- 22.1  Create a login + a database user (demo names; clean up at the end).
-- CREATE LOGIN techshop_reader WITH PASSWORD = 'Str0ng!Pass#2026';
-- CREATE USER techshop_reader FOR LOGIN techshop_reader;

-- 22.2  Prefer ROLES over granting to users directly.
-- CREATE ROLE ReportingReaders;
-- ALTER ROLE ReportingReaders ADD MEMBER techshop_reader;

-- 22.3  GRANT least privilege — read only what's needed.
-- GRANT SELECT ON SCHEMA::dbo TO ReportingReaders;        -- read all dbo tables
-- GRANT SELECT ON dbo.vw_ProductCatalog TO ReportingReaders; -- or just a view

-- 22.4  DENY overrides GRANT — hide a sensitive column/table.
-- DENY SELECT ON dbo.Payments TO ReportingReaders;

-- 22.5  REVOKE — remove a permission entry (neither grant nor deny).
-- REVOKE SELECT ON dbo.Payments FROM ReportingReaders;

-- 22.6  Inspect effective permissions.
SELECT * FROM sys.database_principals WHERE type IN ('S','U','R');
SELECT * FROM fn_my_permissions('dbo.Products', 'OBJECT');   -- my own perms here

/*  Ownership chaining:
    If a view/proc and the tables it touches share the SAME owner, users can
    be granted access to the view/proc WITHOUT direct access to the tables.
    This is the main reason to expose data through views/procs: least
    privilege + abstraction. (Broken chains happen across different owners.) */

/*  SQL injection defense (ties back to Module 21):
    - NEVER concatenate user input into SQL text.
    - Use parameters (sp_executesql / parameterized commands in app code).
    - Grant the app account only the permissions it truly needs, so even a
      successful injection is limited in blast radius.                     */

-- 22.7  Reminder of the SAFE pattern:
DECLARE @email NVARCHAR(256) = N'user@example.com';       -- "user input"
EXEC sys.sp_executesql
     N'SELECT CustomerID FROM dbo.Customers WHERE Email = @e;',
     N'@e NVARCHAR(256)', @e = @email;

/*---------------- YOUR TURN (write the statements; run only if you have rights) ----------------
  a) Write the T-SQL to create a role 'SalesReadOnly' and grant it SELECT on
     dbo.Orders and dbo.OrderItems only.
  b) Write a DENY that prevents SalesReadOnly from reading dbo.Payments.
  c) In a comment, explain how ownership chaining lets you grant access to a
     reporting view without granting access to the base tables.
  d) In a comment, list two concrete ways to prevent SQL injection.
-------------------------------------------------*/

-- a)


-- b)


-- c)  Answer:


-- d)  Answer:


-- Clean up (if you created objects):
-- ALTER ROLE ReportingReaders DROP MEMBER techshop_reader;
-- DROP ROLE IF EXISTS ReportingReaders;
-- DROP USER IF EXISTS techshop_reader;
-- DROP LOGIN techshop_reader;

/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) CREATE ROLE SalesReadOnly;
     GRANT SELECT ON dbo.Orders     TO SalesReadOnly;
     GRANT SELECT ON dbo.OrderItems TO SalesReadOnly;
  b) DENY SELECT ON dbo.Payments TO SalesReadOnly;
  c) When the view and its base tables have the same owner, SQL Server does
     not re-check permissions on the base tables — access to the view is
     enough. So you GRANT SELECT on the view and never expose the tables.
  d) (1) Parameterize all queries (sp_executesql / parameterized app commands).
     (2) Apply least privilege to the app's DB account (+ validate/whitelist
         inputs) so an injection can do little damage.
  ==============================================================*/
