select * FROM sys.dm_os_schedulers where status = 'VISIBLE ONLINE'

-- Get Avg task count and Avg runnable task count
SELECT AVG(current_tasks_count) AS [Avg Task Count] ,
AVG(runnable_tasks_count) AS [Avg Runnable Task Count], SUM(active_workers_count) active_wrkrs, SUM(current_workers_count) as current_wrkrs, SUM(current_tasks_count) as current_tasks
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255
AND [status] = 'VISIBLE ONLINE' ;


select * from sys.dm_os_threads where started_by_sqlservr = 1


select * from sys.dm_os_performance_counters where counter_name = 'Batch Requests/sec' OR counter_name like '%Procedure%'

SELECT
    [ReadLatency] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END,
    [WriteLatency] =
        CASE WHEN [num_of_writes] = 0
            THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END,
    [Latency] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END,
    [AvgBPerRead] =
        CASE WHEN [num_of_reads] = 0
            THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END,
    [AvgBPerWrite] =
        CASE WHEN [num_of_writes] = 0
            THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END,
    [AvgBPerTransfer] =
        CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
            THEN 0 ELSE
                (([num_of_bytes_read] + [num_of_bytes_written]) /
                ([num_of_reads] + [num_of_writes])) END,
    LEFT ([mf].[physical_name], 2) AS [Drive],
    DB_NAME ([vfs].[database_id]) AS [DB],
    [mf].[physical_name]
FROM
    sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]
JOIN sys.master_files AS [mf]
    ON [vfs].[database_id] = [mf].[database_id]
    AND [vfs].[file_id] = [mf].[file_id]
-- WHERE [vfs].[file_id] = 2 -- log files
-- ORDER BY [Latency] DESC
-- ORDER BY [ReadLatency] DESC
ORDER BY [WriteLatency] DESC;
GO


-- SQL Wait Stats and Queies
-- (C) Pinal Dave (http://blog.sqlauthority.com) 2016
-- Send query result to pinal@sqlauthority.com for quick feedback
SELECT  wait_type AS Wait_Type, 
wait_time_ms / 1000.0 AS Wait_Time_Seconds,
waiting_tasks_count AS Waiting_Tasks_Count,
-- CAST((wait_time_ms / 1000.0)/waiting_tasks_count AS decimal(10,4)) AS AVG_Waiting_Tasks_Count,
wait_time_ms * 100.0 / SUM(wait_time_ms) OVER() AS Percentage_WaitTime
--,waiting_tasks_count * 100.0 / SUM(waiting_tasks_count) OVER() AS Percentage_Count
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN
(N'BROKER_EVENTHANDLER',
N'BROKER_RECEIVE_WAITFOR',
N'BROKER_TASK_STOP',
N'BROKER_TO_FLUSH',
N'BROKER_TRANSMITTER',
N'CHECKPOINT_QUEUE',
N'CHKPT',
N'CLR_AUTO_EVENT',
N'CLR_MANUAL_EVENT',
N'CLR_SEMAPHORE',
N'DBMIRROR_DBM_EVENT',
N'DBMIRROR_DBM_MUTEX',
N'DBMIRROR_EVENTS_QUEUE',
N'DBMIRROR_WORKER_QUEUE',
N'DBMIRRORING_CMD',
N'DIRTY_PAGE_POLL',
N'DISPATCHER_QUEUE_SEMAPHORE',
N'EXECSYNC',
N'FSAGENT',
N'FT_IFTS_SCHEDULER_IDLE_WAIT',
N'FT_IFTSHC_MUTEX',
N'HADR_CLUSAPI_CALL',
N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
N'HADR_LOGCAPTURE_WAIT',
N'HADR_NOTIFICATION_DEQUEUE',
N'HADR_TIMER_TASK',
N'HADR_WORK_QUEUE',
N'LAZYWRITER_SLEEP',
N'LOGMGR_QUEUE',
N'MEMORY_ALLOCATION_EXT',
N'ONDEMAND_TASK_QUEUE',
N'PREEMPTIVE_HADR_LEASE_MECHANISM',
N'PREEMPTIVE_OS_AUTHENTICATIONOPS',
N'PREEMPTIVE_OS_AUTHORIZATIONOPS',
N'PREEMPTIVE_OS_COMOPS',
N'PREEMPTIVE_OS_CREATEFILE',
N'PREEMPTIVE_OS_CRYPTOPS',
N'PREEMPTIVE_OS_DEVICEOPS',
N'PREEMPTIVE_OS_FILEOPS',
N'PREEMPTIVE_OS_GENERICOPS',
N'PREEMPTIVE_OS_LIBRARYOPS',
N'PREEMPTIVE_OS_PIPEOPS',
N'PREEMPTIVE_OS_QUERYREGISTRY',
N'PREEMPTIVE_OS_VERIFYTRUST',
N'PREEMPTIVE_OS_WAITFORSINGLEOBJECT',
N'PREEMPTIVE_OS_WRITEFILEGATHER',
N'PREEMPTIVE_SP_SERVER_DIAGNOSTICS',
N'PREEMPTIVE_XE_GETTARGETSTATE',
N'PWAIT_ALL_COMPONENTS_INITIALIZED',
N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
N'QDS_ASYNC_QUEUE',
N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
N'QDS_SHUTDOWN_QUEUE',
N'REDO_THREAD_PENDING_WORK',
N'REQUEST_FOR_DEADLOCK_SEARCH',
N'RESOURCE_QUEUE',
N'SERVER_IDLE_CHECK',
N'SLEEP_BPOOL_FLUSH',
N'SLEEP_DBSTARTUP', 
N'SLEEP_DCOMSTARTUP',
N'SLEEP_MASTERDBREADY', 
N'SLEEP_MASTERMDREADY',
N'SLEEP_MASTERUPGRADED', 
N'SLEEP_MSDBSTARTUP',
N'SLEEP_SYSTEMTASK', 
N'SLEEP_TASK',
N'SP_SERVER_DIAGNOSTICS_SLEEP',
N'SQLTRACE_BUFFER_FLUSH',
N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
N'SQLTRACE_WAIT_ENTRIES',
N'UCS_SESSION_REGISTRATION',
N'WAIT_FOR_RESULTS',
N'WAIT_XTP_CKPT_CLOSE',
N'WAIT_XTP_HOST_WAIT',
N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
N'WAIT_XTP_RECOVERY',
N'WAITFOR',
N'WAITFOR_TASKSHUTDOWN',
N'XE_TIMER_EVENT',
N'XE_DISPATCHER_WAIT'
) AND wait_time_ms >= 1
ORDER BY Wait_Time_Seconds DESC
-- ORDER BY Waiting_Tasks_Count DESC





SELECT 
	r.session_id
	,st.TEXT AS batch_text
	,SUBSTRING(st.TEXT, statement_start_offset / 2 + 1, (
			(
				CASE 
					WHEN r.statement_end_offset = - 1
						THEN (LEN(CONVERT(NVARCHAR(max), st.TEXT)) * 2)
					ELSE r.statement_end_offset
					END
				) - r.statement_start_offset
			) / 2 + 1) AS statement_text
	,qp.query_plan AS 'XML Plan'
	,r.*
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
ORDER BY cpu_time DESC

-------------------------------------
--CPU details
--------------------------


SELECT sch.cpu_id
	,sch.is_idle AS idle
	,(
		SELECT TOP 1 substring(st.TEXT, r.statement_start_offset / 2, (
					(
						CASE 
							WHEN r.statement_end_offset = - 1
								THEN (len(convert(NVARCHAR(MAX), st.TEXT)) * 2)
							ELSE r.statement_end_offset
							END
						) - r.statement_start_offset
					) / 2)
		) AS sql_statement
	,
	-- s.session_id, -- s.login_time,
	s.host_name
	,s.program_name
	,isnull(s.login_name, '') AS LOGIN
	,
	-- isnull(s.nt_domain, '') +'\'+ isnull(s.nt_user_name, ''),
	-- sch.parent_node_id,
	-- sch.scheduler_id,
	-- sch.status,
	-- sch.is_online,
	-- sch.preemptive_switches_count,
	-- sch.context_switches_count,
	-- sch.idle_switches_count,
	sch.current_tasks_count AS TaskCnt
	,
	-- sch.runnable_tasks_count,
	sch.current_workers_count AS workers
	,sch.active_workers_count AS active
	,
	--sch.work_queue_count,
	sch.pending_disk_io_count AS pendIO
	,sch.load_factor
	,
	-- sch.yield_count,
	s.STATUS
	,s.cpu_time
	,s.memory_usage
	,s.total_scheduled_time
	,s.total_elapsed_time
	,s.reads
	,s.writes
	,s.logical_reads
	,c.session_id
	,c.node_affinity
	,c.num_reads
	,c.num_writes
	,c.last_read
	,c.last_write
	,r.session_id
	,r.request_id
	,r.start_time
	,datediff(second, r.start_time, getdate()) AS diff_seconds
	,r.STATUS
	,r.blocking_session_id
	,r.wait_type
	,r.wait_time
	,r.last_wait_type
	,r.wait_resource
	,r.cpu_time
	,r.total_elapsed_time
	,r.scheduler_id
	,r.reads
	,r.writes
	,r.logical_reads
	,t.task_state
	,t.context_switches_count
	,t.pending_io_count
	,t.pending_io_byte_count
	,t.scheduler_id
	,t.session_id
	,t.exec_context_id
	,t.request_id
	,w.STATUS
	,w.is_preemptive
	,w.context_switch_count
	,w.pending_io_count
	,w.pending_io_byte_count
	,w.wait_started_ms_ticks
	,w.wait_resumed_ms_ticks
	,w.task_bound_ms_ticks
	,w.affinity
	,w.STATE
	,w.start_quantum
	,w.end_quantum
	,w.last_wait_type
	,w.quantum_used
	,w.max_quantum
	,w.boost_count
	,th.os_thread_id
	,th.STATUS
	,th.kernel_time
	,th.usermode_time
	,th.stack_bytes_committed
	,th.stack_bytes_used
	,th.affinity
	,sch.parent_node_id
	,sch.scheduler_id
	,sch.cpu_id
	,sch.STATUS
	,sch.is_online
	,sch.is_idle
	,sch.preemptive_switches_count
	,sch.context_switches_count
	,sch.idle_switches_count
	,sch.current_tasks_count
	,sch.runnable_tasks_count
	,sch.current_workers_count
	,sch.active_workers_count
	,sch.work_queue_count
	,sch.pending_disk_io_count
	,sch.load_factor
	,sch.yield_count
FROM sys.dm_os_schedulers sch
LEFT JOIN sys.dm_os_workers w ON (sch.active_worker_address = w.worker_address)
LEFT JOIN sys.dm_os_threads th ON (w.thread_address = th.thread_address)
LEFT JOIN sys.dm_os_tasks t ON (sch.active_worker_address = t.worker_address)
LEFT JOIN sys.dm_exec_requests r ON (
		t.session_id = r.session_id
		AND t.request_id = r.request_id
		)
LEFT JOIN sys.dm_exec_connections c ON (r.connection_id = c.connection_id)
LEFT JOIN sys.dm_exec_sessions s ON (c.session_id = s.session_id)
OUTER APPLY sys.dm_exec_sql_text(sql_handle) st
-- outer apply sys.dm_exec_query_plan(plan_handle) qp
CROSS JOIN sys.dm_os_sys_info si
WHERE sch.scheduler_id < 255
ORDER BY sch.cpu_id

