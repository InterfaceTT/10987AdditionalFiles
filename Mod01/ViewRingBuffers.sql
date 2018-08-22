SELECT  -- DISTINCT ring_buffer_type
	*, CAST(XML, record) XMLData
FROM sys.dm_os_ring_buffers;


SELECT * 
	-- ms_ticks   -- Number of Milliseconds since the computer started.
FROM sys.dm_os_sys_info