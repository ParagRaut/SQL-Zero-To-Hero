/*==============================================================
  Module 14 — Triggers
  Topics: AFTER vs INSTEAD OF triggers, inserted/deleted pseudo-tables,
          audit-log pattern, why triggers are easy to abuse.
  --------------------------------------------------------------
  We practice on a sandbox table so we never surprise the real data.
  ==============================================================*/

USE TechShop;
GO
IF SCHEMA_ID('sandbox') IS NULL EXEC('CREATE SCHEMA sandbox');
GO

-- 14.0  A table to audit, plus an audit-log table.
IF OBJECT_ID('sandbox.Account') IS NOT NULL DROP TABLE sandbox.Account;
IF OBJECT_ID('sandbox.AccountAudit') IS NOT NULL DROP TABLE sandbox.AccountAudit;
GO
CREATE TABLE sandbox.Account
(
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    Owner     NVARCHAR(100) NOT NULL,
    Balance   DECIMAL(12,2) NOT NULL DEFAULT (0)
);
CREATE TABLE sandbox.AccountAudit
(
    AuditID    INT IDENTITY(1,1) PRIMARY KEY,
    AccountID  INT,
    OldBalance DECIMAL(12,2) NULL,
    NewBalance DECIMAL(12,2) NULL,
    Action     NVARCHAR(10),
    ChangedAt  DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- 14.1  AFTER UPDATE trigger — writes to the audit log.
--       'inserted' = new row values, 'deleted' = old row values.
--       Triggers fire once per statement and operate on SETS, not single rows.
CREATE OR ALTER TRIGGER sandbox.trg_Account_Audit
ON sandbox.Account
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO sandbox.AccountAudit (AccountID, OldBalance, NewBalance, Action)
    SELECT i.AccountID, d.Balance, i.Balance, 'UPDATE'
    FROM   inserted i
    JOIN   deleted  d ON d.AccountID = i.AccountID;
END
GO

-- 14.2  See it work.
INSERT INTO sandbox.Account (Owner, Balance) VALUES ('Riya', 100), ('Dev', 50);
UPDATE sandbox.Account SET Balance = Balance + 25;   -- affects BOTH rows
SELECT * FROM sandbox.Account;
SELECT * FROM sandbox.AccountAudit;                  -- two audit rows appear

-- 14.3  INSTEAD OF trigger — runs in place of the action.
--       Example: block deletes, "soft-delete" instead. (Demo on a view/table.)
CREATE OR ALTER TRIGGER sandbox.trg_Account_NoDelete
ON sandbox.Account
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR('Accounts cannot be deleted directly.', 16, 1);
END
GO
-- DELETE FROM sandbox.Account WHERE AccountID = 1;   -- now blocked with an error.

/*  Why triggers are powerful but risky:
    - They run implicitly — easy to forget they exist ("spooky action").
    - Must be written set-based; a per-row mindset causes bugs on bulk DML.
    - Can chain/recurse and hurt performance.
    Use them for auditing / enforcing invariants, not business workflows.   */

/*---------------- YOUR TURN ----------------
  a) Add an AFTER INSERT trigger on sandbox.Account that logs new accounts
     into AccountAudit with Action = 'INSERT' (NewBalance = inserted.Balance).
  b) Insert a new account and confirm an 'INSERT' audit row appears.
  c) In a comment: why must the trigger JOIN inserted/deleted instead of
     assuming a single row?
-------------------------------------------------*/

-- a)


-- b)


-- c)  Answer:


-- Clean up:
-- DROP TABLE IF EXISTS sandbox.AccountAudit; DROP TABLE IF EXISTS sandbox.Account;

/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) CREATE OR ALTER TRIGGER sandbox.trg_Account_Insert
     ON sandbox.Account AFTER INSERT AS
     BEGIN SET NOCOUNT ON;
        INSERT INTO sandbox.AccountAudit (AccountID, OldBalance, NewBalance, Action)
        SELECT AccountID, NULL, Balance, 'INSERT' FROM inserted;
     END
  b) INSERT INTO sandbox.Account (Owner, Balance) VALUES ('Neha', 200);
     SELECT * FROM sandbox.AccountAudit WHERE Action = 'INSERT';
  c) A single statement can affect many rows, so inserted/deleted may hold
     multiple rows. Set-based logic (JOIN) handles all of them correctly;
     assuming one row silently loses/ corrupts data on multi-row DML.
  ==============================================================*/
