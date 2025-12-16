-- 03_Current_Executing_Requests.sql
-- Inspect executing requests and what they are waiting for
-- Source: Standard DMVs

SELECT
	er.session_id
,	er.start_time
,	er.status
,	er.command
,	er.wait_type
,	er.wait_time
,	er.wait_resource
,	er.blocking_session_id
,	st.text AS query_text
,	qp.query_plan
FROM sys.dm_exec_requests AS er
	INNER JOIN sys.dm_exec_sessions AS es ON er.session_id = es.session_id
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(er.plan_handle) AS qp
WHERE er.session_id <> @@SPID AND es.is_user_process = 1
-- Filter user processes only
ORDER BY er.cpu_time DESC;
