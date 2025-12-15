-- 01_Index_Fragmentation.sql
-- Check Index Fragmentation
-- Source: Standard DMVs

SELECT
	DB_NAME(ips.database_id) AS [Database]
,	OBJECT_NAME(ips.object_id) AS [Table]
,	i.name AS [Index Name]
,	ips.index_type_desc
,	ips.avg_fragmentation_in_percent
,	ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
INNER JOIN sys.indexes AS i
	ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 1000 -- Filter out small tables
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Guidelines:
-- > 5% and < 30%: Reorganize
-- > 30%: Rebuild
