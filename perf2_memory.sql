SELECT [type],
memory_node_id,
pages_kb / 1024 as pages_MB,
virtual_memory_reserved_kb,
virtual_memory_committed_kb,
awe_allocated_kb
FROM sys.dm_os_memory_clerks
ORDER BY virtual_memory_reserved_kb DESC;

-- Buffer Pool Usage for instance
SELECT TOP(20) [type], SUM(pages_kb) / 1024 AS [SPA Mem, MB]
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY SUM(pages_kb) DESC;

SELECT objtype AS [CacheType]
        , count_big(*) AS [Total Plans]
        , sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [Total MBs]
        , avg(usecounts) AS [Avg Use Count]
        , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [Total MBs - USE Count 1]
        , sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs - USE Count 1] DESC
go

DBCC MEMORYSTATUS()

select top 100 * from sys.dm_exec_cached_plans
order by usecounts DESC

select COUNT(bucketid), bucketid from sys.dm_exec_cached_plans
group by bucketid
order by COUNT(bucketid) DESC

select COUNT(usecounts) from sys.dm_exec_cached_plans
WHERE usecounts = 1

select * from sys.dm_os_performance_counters where counter_name = 'Page life expectancy'

-- Memory Grants Outstanding value for default instance
SELECT cntr_value AS [Memory Grants Outstanding]                                                                                                      
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Outstanding' OPTION (RECOMPILE);

-- Memory Grants Pending value for default instance
SELECT cntr_value AS [Memory Grants Pending]                                                                                                      
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);

-- Breaks down buffers used by current database 
-- by object (table, index) in the buffer cache
SELECT OBJECT_NAME(p.[object_id]) AS [ObjectName], 
p.index_id, COUNT(*)/128 AS [Buffer size(MB)],  COUNT(*) AS [BufferCount], 
p.data_compression_desc AS [CompressionType]
FROM sys.allocation_units AS a WITH (NOLOCK)
INNER JOIN sys.dm_os_buffer_descriptors AS b WITH (NOLOCK)
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p WITH (NOLOCK)
ON a.container_id = p.hobt_id
WHERE b.database_id = CONVERT(int,DB_ID())
AND p.[object_id] > 100
GROUP BY p.[object_id], p.index_id, p.data_compression_desc
ORDER BY [BufferCount] DESC OPTION (RECOMPILE);


-- Shows the memory required by both running (non-null grant_time)
-- and waiting queries (null grant_time)
-- SQL Server 2008 version
SELECT DB_NAME(st.dbid) AS [DatabaseName] ,
mg.requested_memory_kb ,
mg.ideal_memory_kb ,
mg.request_time ,
mg.grant_time ,
mg.query_cost ,
mg.dop ,
st.[text]
FROM sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
WHERE mg.request_time < COALESCE(grant_time, '99991231')
ORDER BY mg.requested_memory_kb DESC ;


SELECT type ,
name ,
pages_kb ,
pages_in_use_kb ,
entries_count ,
entries_in_use_count
FROM sys.dm_os_memory_cache_counters
ORDER BY type,name;

SELECT latch_class ,
waiting_requests_count AS waitCount ,
wait_time_ms AS waitTime ,
max_wait_time_ms AS maxWait
FROM sys.dm_os_latch_stats
ORDER BY wait_time_ms DESC


select total_physical_memory_kb, available_physical_memory_kb, system_memory_state_desc from sys.dm_os_sys_memory

SELECT total_physical_memory_kb / 1024 AS total_physical_memory_mb ,
available_physical_memory_kb / 1024 AS available_physical_memory_mb ,
total_page_file_kb / 1024 AS total_page_file_mb ,
available_page_file_kb / 1024 AS available_page_file_mb ,
system_memory_state_desc
FROM sys.dm_os_sys_memory


SELECT physical_memory_in_use_kb /1024 as physical_memory ,
virtual_address_space_committed_kb/1024 as virtual_address_space_commited ,
virtual_address_space_available_kb/1024 as virtual_address_space_available ,
page_fault_count ,
process_physical_memory_low ,
process_virtual_memory_low
FROM sys.dm_os_process_memory


SELECT cache_address, name, [type]
FROM sys.dm_os_memory_cache_counters 
WHERE [type] LIKE 'CACHE%'



select * from sys.dm_os_memory_objects