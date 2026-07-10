/*==============================================================
  Module 15 — Transactions & Concurrency
  Topics: ACID, BEGIN/COMMIT/ROLLBACK, savepoints, XACT_ABORT,
          isolation levels, locking/blocking, deadlocks.
  --------------------------------------------------------------
  Some demos need TWO query windows (Session A / Session B) to
  observe blocking & deadlocks. Marked below.
  ==============================================================*/

USE TechShop;
GO

/*  ACID recap:
    Atomicity   — all or nothing.
    Consistency — constraints hold before & after.
    Isolation   — concurrent txns don't corrupt each other.
    Durability  — committed data survives a crash.                      */

-- 15.1  Basic transaction — commit vs rollback.
BEGIN TRAN;
    UPDATE dbo.Products SET UnitPrice = UnitPrice + 1 WHERE ProductID = 1;
    -- decide the outcome:
    ROLLBACK TRAN;      -- or COMMIT TRAN;
SELECT UnitPrice FROM dbo.Products WHERE ProductID = 1;   -- unchanged

-- 15.2  Savepoints — partial rollback within one transaction.
BEGIN TRAN;
    UPDATE dbo.Products SET UnitsInStock = UnitsInStock + 10 WHERE ProductID = 1;
    SAVE TRAN AfterFirst;
    UPDATE dbo.Products SET UnitsInStock = UnitsInStock + 100 WHERE ProductID = 2;
    ROLLBACK TRAN AfterFirst;   -- undo only the second update
    -- the first update is still pending here
ROLLBACK TRAN;                  -- undo everything for a clean demo

-- 15.3  XACT_ABORT — with it ON, any runtime error aborts the whole txn.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRAN;
        UPDATE dbo.Products SET UnitPrice = UnitPrice + 1 WHERE ProductID = 1;
        -- (imagine an error here) 
    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRAN;
    SELECT ERROR_MESSAGE() AS ErrMsg;
END CATCH
SET XACT_ABORT OFF;

/*  Isolation levels (weakest → strongest):
    READ UNCOMMITTED — dirty reads allowed (NOLOCK). Avoid for correctness.
    READ COMMITTED   — default; no dirty reads. Readers block writers.
    REPEATABLE READ  — rows you read stay stable for the txn.
    SERIALIZABLE     — full isolation via range locks; least concurrency.
    SNAPSHOT / RCSI  — readers see a consistent version WITHOUT blocking
                       writers (row-versioning in tempdb).                */

-- 15.4  Set an isolation level (session-scoped).
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;   -- back to default

/*---------------- BLOCKING DEMO (needs two windows) ----------------
  Session A:
     BEGIN TRAN;
     UPDATE dbo.Products SET UnitPrice = UnitPrice + 1 WHERE ProductID = 1;
     -- (do NOT commit yet)
  Session B (will be BLOCKED until A commits/rolls back):
     SELECT UnitPrice FROM dbo.Products WHERE ProductID = 1;
  Then in Session A:  ROLLBACK TRAN;   -- B unblocks.
  Inspect with:  SELECT * FROM sys.dm_exec_requests WHERE blocking_session_id <> 0;
-------------------------------------------------------------------*/

/*---------------- DEADLOCK DEMO (needs two windows) ----------------
  Session A:                         Session B:
    BEGIN TRAN;                        BEGIN TRAN;
    UPDATE Products SET ... WHERE ProductID = 1;
                                       UPDATE Products SET ... WHERE ProductID = 2;
    UPDATE Products SET ... WHERE ProductID = 2;  -- waits on B
                                       UPDATE Products SET ... WHERE ProductID = 1; -- waits on A
  → SQL Server detects the cycle and kills one as the deadlock victim (error 1205).
  Fix: access objects in a consistent order; keep txns short; add indexes.
-------------------------------------------------------------------*/

/*---------------- YOUR TURN ----------------
  a) Wrap two UPDATEs in a transaction; ROLLBACK; prove nothing changed.
  b) Use a savepoint: do two updates, roll back only the second.
  c) In a comment, name the isolation level that lets readers avoid blocking
     writers by using row versions.
  d) (Optional, two windows) Reproduce a block and find it in
     sys.dm_exec_requests.
-------------------------------------------------*/

-- a)


-- b)


-- c)  Answer:


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) BEGIN TRAN;
       UPDATE dbo.Products SET UnitPrice = UnitPrice + 5 WHERE ProductID = 1;
       UPDATE dbo.Products SET UnitPrice = UnitPrice + 5 WHERE ProductID = 2;
     ROLLBACK TRAN;
     SELECT ProductID, UnitPrice FROM dbo.Products WHERE ProductID IN (1,2);
  b) BEGIN TRAN;
       UPDATE dbo.Products SET UnitsInStock += 1 WHERE ProductID = 1;
       SAVE TRAN s1;
       UPDATE dbo.Products SET UnitsInStock += 1 WHERE ProductID = 2;
       ROLLBACK TRAN s1;   -- second undone, first still pending
     ROLLBACK TRAN;
  c) SNAPSHOT isolation (or READ COMMITTED SNAPSHOT / RCSI).
  ==============================================================*/
