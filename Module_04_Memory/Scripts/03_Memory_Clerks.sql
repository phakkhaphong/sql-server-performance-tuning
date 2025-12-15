-- 03_Memory_Clerks.sql
-- Top Memory Clerks consuming SQL Server RAM.

SELECT TOP(10)
	mc.[type] AS [MemoryClerkType]
,	CAST((SUM(mc.pages_kb) / 1024.0) AS DECIMAL(15, 2)) AS [MemoryUsage_MB]
FROM sys.dm_os_memory_clerks AS mc
GROUP BY mc.[type]
ORDER BY SUM(mc.pages_kb) DESC;

-- Analysis Key:
-- MEMORYCLERK_SQLBUFFERPOOL: Normal (Data Cache)
-- CACHESTORE_SQLCP: Plan Cache (excessive = Adhoc plan bloat)
-- MEMORYCLERK_SQLQERESERVATIONS: Memory Grant (excessive = large sorts/hashes)
-- OBJECTSTORE_LOCK_MANAGER: High locking activity
