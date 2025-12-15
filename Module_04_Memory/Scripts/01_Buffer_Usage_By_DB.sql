-- 01_Buffer_Usage_By_DB.sql
-- Check which database is using the most memory in the Buffer Pool
-- Source: Microsoft Learn / Glenn Berry

SELECT
	DB_NAME(database_id) AS [Database Name]
,	COUNT(*) * 8 / 1024 AS [Cached Size (MB)]
,	CAST(COUNT(*) * 100.0 / CAST(SUM(COUNT(*)) OVER() AS DECIMAL(18,2)) AS DECIMAL(5,2)) AS [Buffer Pool Percent]
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY [Cached Size (MB)] DESC;

-- Clean buffer pool command (Don't run in Prod unless necessary):
-- DBCC DROPCLEANBUFFERS;
