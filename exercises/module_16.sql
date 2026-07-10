/*==============================================================
  Module 16 — Storage Internals
  Topics: pages (8 KB) & extents, heaps vs clustered tables,
          fill factor, page splits, fragmentation, logical vs
          physical reads, DMVs to inspect physical structure.
  --------------------------------------------------------------
  💡 Run 05_generate_large_data.sql first for meaningful numbers.
  ==============================================================*/

USE TechShop;
GO

/*  Mental model:
    - Data is stored in 8 KB PAGES. 8 contiguous pages = one EXTENT (64 KB).
    - HEAP     = table with no clustered index (rows unordered, RID-addressed).
    - CLUSTERED index = the table itself, sorted by the clustering key.
    - A PAGE SPLIT happens when a row won't fit on its page during an insert/
      update; half the rows move to a new page → fragmentation.
    - FILL FACTOR leaves free space on pages to reduce splits (trade: more pages).
    - Logical reads  = pages read from the buffer pool (memory).
    - Physical reads = pages read from disk (cold cache).                 */

-- 16.1  Turn on IO stats so every query reports pages read.
SET STATISTICS IO ON;
SELECT * FROM dbo.Orders;           -- watch the "logical reads" in Messages
SET STATISTICS IO OFF;

-- 16.2  How many pages / rows does a table use? (allocation view)
SELECT
    OBJECT_NAME(p.object_id)  AS TableName,
    i.name                    AS IndexName,
    i.type_desc               AS IndexType,   -- HEAP / CLUSTERED / NONCLUSTERED
    p.rows                    AS [RowCount],
    au.total_pages            AS TotalPages,
    au.used_pages             AS UsedPages
FROM sys.partitions p
JOIN sys.allocation_units au ON au.container_id = p.partition_id
JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE p.object_id = OBJECT_ID('dbo.Orders');

-- 16.3  Fragmentation & page fullness for a table's indexes.
SELECT
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.avg_page_space_used_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.Orders'), NULL, NULL, 'SAMPLED') ips
JOIN sys.indexes i ON i.object_id = ips.object_id AND i.index_id = ips.index_id;

-- 16.4  Heap vs clustered: which tables are heaps? (index_id = 0 → heap)
SELECT OBJECT_NAME(object_id) AS TableName, type_desc
FROM   sys.indexes
WHERE  index_id IN (0,1) AND OBJECTPROPERTY(object_id, 'IsUserTable') = 1
ORDER BY TableName;

/*  Fixing fragmentation (Module 23 covers maintenance in depth):
    - REORGANIZE  (online, light) for moderate fragmentation.
    - REBUILD     (heavier) for heavy fragmentation; can set FILLFACTOR.  */

/*---------------- YOUR TURN ----------------
  a) Turn on STATISTICS IO and note the logical reads for
     SELECT * FROM dbo.OrderItems.
  b) Using the sys.partitions query, report row & page counts for
     dbo.Products.
  c) Check fragmentation for dbo.OrderItems with dm_db_index_physical_stats.
  d) In a comment, explain what a page split is and why it causes
     fragmentation.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)  Answer:


/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) SET STATISTICS IO ON;
     SELECT * FROM dbo.OrderItems;
     SET STATISTICS IO OFF;   -- read "logical reads N" from the Messages tab
  b) (reuse 16.2 with OBJECT_ID('dbo.Products'))
  c) SELECT ips.avg_fragmentation_in_percent, ips.page_count
     FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.OrderItems'),
          NULL, NULL, 'SAMPLED') ips;
  d) On insert/update, if a row doesn't fit on its target page, SQL Server
     allocates a new page and moves ~half the rows to it. The new page is
     usually not physically adjacent, so logical order ≠ physical order →
     fragmentation, which increases IO for range scans.
  ==============================================================*/
