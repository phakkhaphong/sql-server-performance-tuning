-- 02_Page_Life_Expectancy.sql
-- Check Page Life Expectancy (PLE)
-- Source: Glenn Berry
-- PLE measures the average time (in seconds) that a data page stays in the buffer pool.

SELECT
	[object_name]
,	[counter_name]
,	[cntr_value] AS [PLE (Seconds)]
FROM sys.dm_os_performance_counters
WHERE [counter_name] = N'Page life expectancy'
ORDER BY [cntr_value] ASC;

-- Rule of Thumb:
-- Historical value was 300s (5 mins).
-- Modern server with lots of RAM: standard is roughly (DataCacheSizeGB / 4GB) * 300.
-- Sudden drops in PLE indicate memory pressure.
