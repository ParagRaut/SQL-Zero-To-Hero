# SQL Zero → Hero (SQL Server Edition)

A self-paced, hands-on course to take you from **zero to hero** in T-SQL on Microsoft SQL Server, using a custom practice database called **TechShop**.

## How this repo works

| File / Folder | Purpose |
|---|---|
| [COURSE.md](COURSE.md) | The full curriculum. 24 modules, ordered beginner → advanced. Your main study guide. |
| [MILESTONES.md](MILESTONES.md) | Progress tracker. Check off modules as you complete them. Updated as we go. |
| [SESSION.md](SESSION.md) | **Session restore** file. When you say *"end session"*, I snapshot where we are here so we resume instantly next time. |
| [database/](database/) | SQL scripts to build the TechShop practice database and load data. |
| [exercises/](exercises/) | Practice questions and solution scripts per module. |
| [notes/](notes/) | Your personal cheat-sheets and takeaways (added as we progress). |

## First-time setup (run once)

Run these scripts **in order** in SQL Server Management Studio (SSMS) or Azure Data Studio against your local instance:

1. [database/01_create_database.sql](database/01_create_database.sql) — creates the `TechShop` database
2. [database/02_create_tables.sql](database/02_create_tables.sql) — creates all tables + relationships
3. [database/03_seed_data.sql](database/03_seed_data.sql) — loads realistic sample data
4. [database/05_generate_large_data.sql](database/05_generate_large_data.sql) — (optional, for the performance/index modules) inflates the data to ~500k+ rows so execution plans and indexes actually matter

> Do **not** run `04_indexes.sql` yet — that script belongs to Module 18 and we add indexes deliberately so you can *see* the before/after difference in query plans.

## How to study

1. Open [COURSE.md](COURSE.md), find your current module.
2. Read the concepts, run the example queries against TechShop.
3. Do the exercises in [exercises/](exercises/).
4. Tick the box in [MILESTONES.md](MILESTONES.md).
5. When you stop for the day, say **"end session"** and I'll update [SESSION.md](SESSION.md).

## Curated external resources

- **Microsoft Learn – SQL Server docs**: https://learn.microsoft.com/en-us/sql/sql-server/
- **Use The Index, Luke** (the best free guide to indexing & SQL performance): https://use-the-index-luke.com/
- **Brent Ozar** (SQL Server performance blog + free tools): https://www.brentozar.com/
- **SQLServerCentral** (community, stairways series): https://www.sqlservercentral.com/
- **Itzik Ben-Gan – T-SQL Fundamentals / Querying** (books, gold standard)
- **StatQuest / Microsoft Learn learning paths** for structured video/interactive learning

---
*Start at [COURSE.md → Module 0](COURSE.md#module-0--environment--mental-model).*
