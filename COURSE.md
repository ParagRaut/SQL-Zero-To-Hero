# SQL Zero → Hero — Full Curriculum

**Database engine:** Microsoft SQL Server (local instance)
**Practice database:** TechShop (an e-commerce store)
**Tooling:** SSMS or Azure Data Studio

Legend: 🎯 objective · 🧪 exercise file · 📖 external reading

The course is grouped into 5 stages. Each module builds on the last — do them in order.

---

## STAGE 1 — Foundations

### Module 0 — Environment & Mental Model
🎯 Understand what a relational database is and get your tools working.
- What is an RDBMS? Tables, rows, columns, keys, relationships.
- SQL Server architecture at a glance: instance → databases → schemas → objects.
- SQL vs T-SQL. Declarative thinking ("what" not "how").
- Connecting with SSMS / Azure Data Studio. Object Explorer tour.
- Running the setup scripts in [database/](database/).
- Data types overview: `INT`, `BIGINT`, `DECIMAL`, `VARCHAR`/`NVARCHAR`, `DATE`, `DATETIME2`, `BIT`.
🧪 [exercises/module_00.sql](exercises/module_00.sql)

### Module 1 — SELECT Basics
🎯 Retrieve and shape data from a single table.
- `SELECT`, `FROM`, column lists vs `*` (and why `*` is a smell).
- Column & table aliases (`AS`).
- `ORDER BY` (ASC/DESC, multiple keys).
- `DISTINCT`. `TOP (n)` and `TOP (n) WITH TIES`.
- Computed columns and simple expressions in SELECT.
🧪 [exercises/module_01.sql](exercises/module_01.sql)

### Module 2 — Filtering with WHERE
🎯 Return only the rows you want.
- Comparison operators, `AND` / `OR` / `NOT`, precedence & parentheses.
- `BETWEEN`, `IN`, `LIKE` (wildcards `%` `_`), escaping.
- `NULL` and three-valued logic: `IS NULL`, `IS NOT NULL`, why `= NULL` fails.
- `ISNULL` / `COALESCE`.
🧪 [exercises/module_02.sql](exercises/module_02.sql)

### Module 3 — Built-in Functions
🎯 Transform values row-by-row.
- String: `LEN`, `LEFT`/`RIGHT`, `SUBSTRING`, `CHARINDEX`, `REPLACE`, `CONCAT`, `TRIM`, `UPPER`/`LOWER`, `FORMAT`.
- Date/time: `GETDATE`, `SYSDATETIME`, `DATEADD`, `DATEDIFF`, `DATEPART`, `EOMONTH`, `CAST`/`CONVERT` for dates.
- Numeric: `ROUND`, `CEILING`, `FLOOR`, `ABS`, `%` modulo.
- Conditional: `CASE`, `IIF`, `CHOOSE`, `NULLIF`.
- `CAST` vs `CONVERT` vs `TRY_CAST`.
🧪 [exercises/module_03.sql](exercises/module_03.sql)

---

## STAGE 2 — Working with Multiple Rows & Tables

### Module 4 — Aggregation & Grouping
🎯 Summarize data.
- Aggregates: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`; `COUNT(*)` vs `COUNT(col)`.
- `GROUP BY` (single & multiple columns).
- `HAVING` vs `WHERE` (filter groups vs rows).
- `DISTINCT` inside aggregates.
- Logical query processing order (FROM→WHERE→GROUP BY→HAVING→SELECT→ORDER BY).
🧪 [exercises/module_04.sql](exercises/module_04.sql)

### Module 5 — Joins
🎯 Combine data from related tables.
- `INNER JOIN`, `LEFT`/`RIGHT`/`FULL OUTER JOIN`, `CROSS JOIN`.
- Self-joins (e.g., employee → manager).
- Multi-table joins, join order readability.
- Joins vs filtering; `ON` vs `WHERE` for outer joins (a classic bug).
- Anti-joins with `LEFT JOIN ... IS NULL`.
🧪 [exercises/module_05.sql](exercises/module_05.sql)

### Module 6 — Subqueries & CTEs
🎯 Compose queries out of queries.
- Scalar, multi-row, and correlated subqueries.
- `IN` / `NOT IN` / `EXISTS` / `NOT EXISTS` (and the NULL trap with `NOT IN`).
- Derived tables.
- Common Table Expressions (`WITH`), multiple CTEs.
- **Recursive CTEs** (e.g., org hierarchy, category tree).
🧪 [exercises/module_06.sql](exercises/module_06.sql)

### Module 7 — Set Operators
🎯 Stack and compare result sets.
- `UNION` vs `UNION ALL` (and the perf difference).
- `INTERSECT`, `EXCEPT`.
- Rules: column count/type/order.
🧪 [exercises/module_07.sql](exercises/module_07.sql)

### Module 8 — Window Functions
🎯 Analytics without collapsing rows.
- `OVER(PARTITION BY ... ORDER BY ...)`.
- Ranking: `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`.
- Offset: `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`.
- Aggregate windows: running totals, moving averages, `ROWS`/`RANGE` framing.
- De-duplication pattern with `ROW_NUMBER`.
🧪 [exercises/module_08.sql](exercises/module_08.sql)

---

## STAGE 3 — Building & Changing Databases

### Module 9 — Modifying Data (DML)
🎯 Write data safely.
- `INSERT` (single, multi-row, `INSERT ... SELECT`).
- `UPDATE` (with joins), `DELETE`, `TRUNCATE` vs `DELETE`.
- `MERGE` (upsert) and its caveats.
- `OUTPUT` clause to capture changed rows.
- Always test with a `SELECT` / transaction first.
🧪 [exercises/module_09.sql](exercises/module_09.sql)

### Module 10 — Schema Design & DDL
🎯 Create well-structured tables.
- `CREATE`/`ALTER`/`DROP TABLE`; schemas (`dbo`, custom).
- Choosing data types; `IDENTITY`, `SEQUENCE`, computed columns.
- **Normalization** (1NF→3NF) and when to denormalize.
- Naming conventions.
🧪 [exercises/module_10.sql](exercises/module_10.sql)

### Module 11 — Constraints & Data Integrity
🎯 Let the database enforce correctness.
- `PRIMARY KEY`, `FOREIGN KEY` (+ cascade options), `UNIQUE`, `CHECK`, `DEFAULT`, `NOT NULL`.
- Referential integrity, orphan rows.
- Surrogate vs natural keys.
🧪 [exercises/module_11.sql](exercises/module_11.sql)

### Module 12 — Views
🎯 Save and abstract queries.
- Creating/altering views, updatable views.
- `WITH SCHEMABINDING`, indexed (materialized) views.
- Views for security & abstraction.
🧪 [exercises/module_12.sql](exercises/module_12.sql)

### Module 13 — Stored Procedures & Functions
🎯 Package reusable logic.
- Stored procedures: parameters (in/out), defaults, `RETURN`.
- Scalar functions, table-valued functions (inline vs multi-statement) & their perf traps.
- Variables, control-of-flow (`IF`, `WHILE`), `TRY...CATCH`.
- When to use procs vs functions vs views.
🧪 [exercises/module_13.sql](exercises/module_13.sql)

### Module 14 — Triggers
🎯 React to data changes.
- `AFTER` vs `INSTEAD OF` triggers; `inserted`/`deleted` pseudo-tables.
- Audit-log pattern.
- Why triggers are powerful but easy to abuse.
🧪 [exercises/module_14.sql](exercises/module_14.sql)

---

## STAGE 4 — The "Hero" Layer: Performance & Internals

### Module 15 — Transactions & Concurrency
🎯 Keep data correct under concurrent access.
- ACID properties.
- `BEGIN/COMMIT/ROLLBACK TRAN`, savepoints, `XACT_ABORT`.
- Isolation levels: Read Uncommitted → Serializable; `SNAPSHOT`/RCSI.
- Locking, blocking, and **deadlocks** (cause + how to reproduce/resolve).
🧪 [exercises/module_15.sql](exercises/module_15.sql)

### Module 16 — Storage Internals
🎯 Know how SQL Server physically stores data.
- Pages (8 KB) & extents, heaps vs clustered tables.
- Rows, `fill factor`, page splits, fragmentation.
- How data is read: logical vs physical reads, buffer pool.
- Inspect with `sys.dm_db_index_physical_stats`, `DBCC PAGE` (concept).
🧪 [exercises/module_16.sql](exercises/module_16.sql)

### Module 17 — Statistics & the Optimizer
🎯 Understand how SQL Server decides *how* to run your query.
- The cost-based optimizer; cardinality estimation.
- Statistics: histograms, `UPDATE STATISTICS`, auto-create/update.
- `SET STATISTICS IO ON`, `SET STATISTICS TIME ON`.
- Parameter sniffing (good and bad).
🧪 [exercises/module_17.sql](exercises/module_17.sql)

### Module 18 — Indexes (Deep Dive)
🎯 Make queries fast on purpose.
- B-tree structure; **clustered** vs **nonclustered** indexes.
- Key columns vs `INCLUDE`d columns; **covering indexes**.
- Composite index column order & left-most prefix rule.
- Unique, filtered, and computed-column indexes.
- Key lookups & the RID/clustered-key lookup problem.
- Columnstore indexes (analytics) — overview.
- The cost of indexes on writes; avoiding over-indexing.
- Missing-index DMVs & warnings (use with caution).
- 👉 Run [database/04_indexes.sql](database/04_indexes.sql) *after* measuring the "before".
🧪 [exercises/module_18.sql](exercises/module_18.sql)
📖 https://use-the-index-luke.com/ · https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide

### Module 19 — Reading Execution Plans
🎯 Diagnose *why* a query is slow.
- Estimated vs actual plans; how to capture them (SSMS Ctrl+M / Ctrl+L).
- Key operators: Scan vs Seek, Nested Loops / Hash / Merge joins, Sort, Key Lookup, Spool.
- Reading arrows (row counts), warnings (implicit conversion, spills), and the fat-arrow rule.
- Estimated vs actual row skew = stale stats.
- Live Query Statistics.
🧪 [exercises/module_19.sql](exercises/module_19.sql)
📖 https://use-the-index-luke.com/sql/explain-plan/sql-server

### Module 20 — Query Tuning & Best Practices
🎯 Systematically make queries faster.
- **SARGability**: keep columns "bare" in `WHERE`; avoid functions on indexed columns.
- Avoid implicit conversions (data-type mismatches).
- `EXISTS` vs `IN` vs `JOIN`; `UNION ALL` vs `UNION`.
- Paging: `OFFSET/FETCH` vs keyset (seek) pagination.
- Temp tables vs table variables vs CTEs.
- Reducing key lookups with covering indexes.
- Recompilation, plan cache, `OPTION` hints (last resort).
🧪 [exercises/module_20.sql](exercises/module_20.sql)

---

## STAGE 5 — Professional Skills & Capstone

### Module 21 — Advanced T-SQL Toolkit
🎯 Round out your query vocabulary.
- `PIVOT` / `UNPIVOT`, conditional aggregation.
- `APPLY` (`CROSS`/`OUTER APPLY`).
- `GROUPING SETS`, `ROLLUP`, `CUBE`.
- JSON (`FOR JSON`, `OPENJSON`), `STRING_AGG`, `STRING_SPLIT`.
- Dynamic SQL (`sp_executesql`) and SQL-injection safety.
🧪 [exercises/module_21.sql](exercises/module_21.sql)

### Module 22 — Security
🎯 Control who can do what.
- Logins vs users; roles; `GRANT`/`DENY`/`REVOKE`.
- Schema-level permissions, ownership chaining.
- Least-privilege; parameterization to prevent SQL injection.
🧪 [exercises/module_22.sql](exercises/module_22.sql)

### Module 23 — Administration & Maintenance
🎯 Keep a database healthy.
- Backups & restores (FULL/DIFF/LOG), recovery models.
- Index & statistics maintenance (rebuild/reorganize).
- Dynamic Management Views (DMVs) for monitoring.
- Reading the plan cache; finding expensive queries.
🧪 [exercises/module_23.sql](exercises/module_23.sql)

### Module 24 — Capstone Projects
🎯 Prove mastery end-to-end on TechShop.
- **Reporting:** monthly revenue, top customers, product performance, cohort retention.
- **Optimization:** take a deliberately slow report, read its plan, index/rewrite it, measure the win.
- **Design:** add a "wishlist" + "returns" feature (tables, constraints, procs, indexes).
🧪 [exercises/module_24_capstone.sql](exercises/module_24_capstone.sql)

---

## Suggested pace
Roughly one module per study block. Stages 1–2 are quick; Stages 4–5 are where the "hero" work is — slow down and experiment with real plans.

Track your progress in [MILESTONES.md](MILESTONES.md).
