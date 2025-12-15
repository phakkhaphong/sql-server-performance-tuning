/*
    SCRIPT: 03_TempDB_Configuration.sql
    [CRITICAL]: EXECUTE IN MASTER context to access sys.master_files
*/
USE [master];
GO

-- Checks TempDB file count, size, and growth settings against best practices.

SELECT
	name AS [FileName]
,	size * 8.0 / 1024 AS [Size_MB]
,	growth * 8.0 / 1024 AS [Growth_MB]
,	is_percent_growth
,	physical_name
FROM sys.master_files
WHERE database_id = 2;

-- Best Practice Check:
-- 1. Number of data files should match logical core count (up to 8).
-- 2. All data files should have the SAME size and SAME autogrowth.
-- 3. Trace Flag 1118 (Uniform Extent) is default in SQL 2016+
