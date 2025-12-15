-- ============================================================
-- Script: 03_VLF_Analysis.sql
-- Module: Module 03 - Database Structures
-- Purpose: Analyze Virtual Log Files (VLF) Count
-- Source: Glenn Berry / SQL Server Community
-- ============================================================

-- ============================================================
-- STEP 1: VLF Count for All Databases
-- ============================================================

-- SQL Server 2016+ Method using sys.dm_db_log_info
SELECT
	DB_NAME(database_id) AS [Database Name]
,	COUNT(*) AS [VLF Count]
,	SUM(vlf_size_mb) AS [Total Log Size (MB)]
,	CASE
		WHEN COUNT(*) > 1000 THEN '⚠️ Critical - Too many VLFs!'
		WHEN COUNT(*) > 500 THEN '⚡ Warning - High VLF count'
		WHEN COUNT(*) > 100 THEN '📊 Moderate'
		ELSE '✅ Good'
	END AS [Status]
FROM sys.dm_db_log_info(NULL)
GROUP BY database_id
ORDER BY COUNT(*) DESC;

-- ============================================================
-- STEP 2: Detail VLF Info for Specific Database
-- ============================================================

-- Change database name as needed
DECLARE @DBName NVARCHAR(128) = 'AdventureWorks2022';

SELECT
	database_id
,	file_id
,	vlf_begin_offset
,	vlf_size_mb
,	vlf_sequence_number
,	vlf_status
,	vlf_parity
,	CASE vlf_status
		WHEN 0 THEN 'Inactive'
		WHEN 1 THEN 'Initialized but unused'
		WHEN 2 THEN 'Active'
		ELSE 'Other'
	END AS [VLF Status Description]
FROM sys.dm_db_log_info(DB_ID(@DBName));

-- ============================================================
-- STEP 3: Why VLF Count Matters
-- ============================================================

/*
=== Impact of High VLF Count ===
1. Database Startup: ต้อง Scan ทุก VLF ทำให้เริ่มช้า
2. Database Recovery: Log recovery ช้ากว่าปกติ
3. Replication/Mirroring: Log reader ทำงานช้า
4. Backup/Restore: Transaction log backup/restore ช้า

=== Causes of High VLF ===
- Auto-Growth ขนาดเล็ก (เช่น 1MB, 10%) ทำให้เกิด VLF จำนวนมาก
- Grow/Shrink วนซ้ำ (Bad practice)

=== VLF Creation Rules (SQL Server 2014+) ===
- Growth <= 64 MB: 4 VLFs
- Growth > 64 MB and <= 1 GB: 8 VLFs
- Growth > 1 GB: 16 VLFs
*/

-- ============================================================
-- STEP 4: Fix High VLF Count (Manual Shrink & Regrow)
-- ============================================================

/*
-- ⚠️ WARNING: Run this during maintenance window only!

USE [YourDatabase];
GO

-- 1. Backup the transaction log first
BACKUP LOG [YourDatabase] TO DISK = 'C:\Backup\YourDatabase_Log.trn';

-- 2. Shrink the log file (make it as small as possible)
DBCC SHRINKFILE (N'YourDatabase_Log', 1);

-- 3. Verify log is small
SELECT name, size/128.0 AS [Size(MB)] 
FROM sys.database_files 
WHERE type_desc = 'LOG';

-- 4. Grow log file in one large chunk (e.g., 8GB = 8192 MB)
ALTER DATABASE [YourDatabase]
MODIFY FILE (NAME = N'YourDatabase_Log', SIZE = 8192MB);

-- 5. Verify VLF count is now lower
SELECT COUNT(*) AS [New VLF Count]
FROM sys.dm_db_log_info(DB_ID('YourDatabase'));
*/

-- ============================================================
-- STEP 5: Recommended Log File Growth Settings
-- ============================================================

SELECT
	DB_NAME(database_id) AS [Database]
,	name AS [File Name]
,	type_desc
,	size * 8 / 1024 AS [Current Size (MB)]
,	growth AS growth_value
,	CASE is_percent_growth
		WHEN 1 THEN CAST(growth AS VARCHAR) + '%'
		ELSE CAST(growth * 8 / 1024 AS VARCHAR) + ' MB'
	END AS [Growth Setting]
,	CASE
		WHEN is_percent_growth = 1 THEN '⚠️ Change to Fixed MB!'
		WHEN growth * 8 / 1024 < 64 THEN '⚠️ Too small - Increase to 64-512 MB'
		WHEN growth * 8 / 1024 > 1024 THEN '⚡ Large growth - OK for big databases'
		ELSE '✅ Good'
	END AS [Recommendation]
FROM sys.master_files
WHERE type_desc = 'LOG'
ORDER BY [Current Size (MB)] DESC;
