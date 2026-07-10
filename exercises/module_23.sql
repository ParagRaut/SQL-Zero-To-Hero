/*==============================================================
  Module 23 — Administration & Maintenance
  Topics: backups & restores, recovery models, index & statistics
          maintenance, DMVs for monitoring, reading the plan cache.
  --------------------------------------------------------------
  ⚠️ BACKUP/RESTORE touch the filesystem & server config. Read first;
     run only if you understand the paths and have permission.
  ==============================================================*/

USE TechShop;
GO

/*  Recovery models (per database):
    - SIMPLE   — log auto-truncates; NO point-in-time restore; simplest.
    - FULL     — every change logged; supports LOG backups & point-in-time.
    - BULK_LOGGED — like FULL but minimal logging for bulk ops.
    Check/set:                                                             */
SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'TechShop';
-- ALTER DATABASE TechShop SET RECOVERY FULL;   -- (only if you'll manage log backups)

-- 23.1  Backups (adjust the path to a folder your SQL Server service can write).
-- BACKUP DATABASE TechShop TO DISK = 'C:\SQLBackups\TechShop_FULL.bak' WITH INIT;
-- BACKUP DATABASE TechShop TO DISK = 'C:\SQLBackups\TechShop_DIFF.bak' WITH DIFFERENTIAL;
-- BACKUP LOG      TechShop TO DISK = 'C:\SQLBackups\TechShop_LOG.trn';   -- FULL model only

-- 23.2  Restore sequence (would overwrite the DB — DO NOT run casually):
-- RESTORE DATABASE TechShop FROM DISK = 'C:\SQLBackups\TechShop_FULL.bak'
--   WITH NORECOVERY, REPLACE;
-- RESTORE DATABASE TechShop FROM DISK = 'C:\SQLBackups\TechShop_DIFF.bak' WITH NORECOVERY;
-- RESTORE LOG      TechShop FROM DISK = 'C:\SQLBackups\TechShop_LOG.trn'  WITH RECOVERY;

-- 23.3  Index maintenance — reorganize (light) vs rebuild (heavy).
--       Rule of thumb: 5–30% fragmentation → REORGANIZE; >30% → REBUILD.
SELECT
    i.name AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
WHERE ips.page_count > 100     -- ignore tiny indexes
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- ALTER INDEX IX_Orders_CustomerID ON dbo.Orders REORGANIZE;
-- ALTER INDEX ALL ON dbo.Orders REBUILD WITH (FILLFACTOR = 90);

-- 23.4  Statistics maintenance.
-- UPDATE STATISTICS dbo.Orders WITH FULLSCAN;
-- EXEC sys.sp_updatestats;     -- all tables (quick, sampled)

-- 23.5  Monitoring DMVs — find the most expensive cached queries.
SELECT TOP (10)
    qs.total_worker_time / qs.execution_count AS AvgCPU,
    qs.total_logical_reads / qs.execution_count AS AvgReads,
    qs.execution_count,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY AvgCPU DESC;

-- 23.6  Currently running requests & any blocking.
SELECT session_id, status, wait_type, blocking_session_id, cpu_time, total_elapsed_time
FROM sys.dm_exec_requests
WHERE session_id <> @@SPID;

-- 23.7  Database size by file.
SELECT name AS LogicalFile, type_desc, size * 8 / 1024 AS SizeMB
FROM sys.database_files;

/*---------------- YOUR TURN ----------------
  a) Report the recovery model of TechShop.
  b) List all indexes with > 10% fragmentation and more than 100 pages.
  c) Write (don't run) the command to REBUILD all indexes on dbo.OrderItems
     with FILLFACTOR 90.
  d) Use the plan-cache DMV to find your top 5 queries by average logical reads.
  e) In a comment, explain why FULL recovery is required for point-in-time
     restore.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)  Answer:


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SELECT recovery_model_desc FROM sys.databases WHERE name = 'TechShop';
  b) (reuse 23.3 with WHERE ips.avg_fragmentation_in_percent > 10 AND page_count > 100)
  c) ALTER INDEX ALL ON dbo.OrderItems REBUILD WITH (FILLFACTOR = 90);
  d) (reuse 23.5 but ORDER BY AvgReads DESC)
  e) FULL recovery keeps every change in the transaction log until a log
     backup runs. Restoring FULL + DIFF + a chain of LOG backups lets you
     replay the log up to an exact moment. SIMPLE recovery truncates the log,
     so there's no log chain to replay → no point-in-time restore.
  ==============================================================*/
