-- 02_Find_Implicit_Conversions.sql
-- Finds queries in the Plan Cache that have Implicit Conversions (a major performance killer).
-- Look for CONVERT_IMPLICIT in the XML plan.

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT TOP 20
	cp.usecounts
,	cp.cacheobjtype
,	cp.objtype
,	st.text
,	qp.query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE qp.query_plan.exist('//PlanAffectingConvert') = 1
ORDER BY cp.usecounts DESC;
