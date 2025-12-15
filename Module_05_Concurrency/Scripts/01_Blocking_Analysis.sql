-- 01_Blocking_Analysis.sql
-- Check Blocking Chains
-- Source: Standard DMVs

SELECT
	[owt].[session_id] AS [Waiting Session]
,	[owt].[exec_context_id] AS [Waiting Exec Context]
,	[owt].[wait_duration_ms] AS [Wait Duration (ms)]
,	[owt].[wait_type] AS [Wait Type]
,	[owt].[blocking_session_id] AS [Blocking Session]
,	[er].[command] AS [Waiting Command]
,	[est].[text] AS [Waiting Query Text]
,	[es].[program_name] AS [Waiting Program]
FROM sys.dm_os_waiting_tasks AS [owt]
INNER JOIN sys.dm_exec_sessions AS [es]
	ON [owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests AS [er]
	ON [es].[session_id] = [er].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) AS [est]
WHERE [owt].[session_id] > 50
AND [owt].[blocking_session_id] IS NOT NULL
ORDER BY [owt].[wait_duration_ms] DESC;
