-- 01_Check_Schedulers.sql
-- Check SQL Server Schedulers and CPU Pressure
-- Source: Adapted from Microsoft Learn & Standard DMVs

SELECT
	scheduler_id
,	cpu_id
,	status
,	is_online
,	is_idle
,	current_tasks_count
,	runnable_tasks_count -- Key metric for CPU pressure (should be close to 0)
,	current_workers_count
,	active_workers_count
,	work_queue_count
,	pending_disk_io_count
,	load_factor
FROM sys.dm_os_schedulers
WHERE status = 'VISIBLE ONLINE'
ORDER BY cpu_id;

-- runnable_tasks_count > 0 generally indicates CPU pressure if persistent.
