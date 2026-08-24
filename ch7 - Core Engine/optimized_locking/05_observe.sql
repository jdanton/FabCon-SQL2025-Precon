/*═══════════════════════════════════════════════════════════════════════════
  OPTIONAL, WINDOW C — WHAT'S HAPPENING RIGHT NOW
  ───────────────────────────────────────────────────────────────────────────
  Run while 03_blocker.sql and 04_victim.sql are in flight to show the
  blocking chain live. Safe to run repeatedly.
═══════════════════════════════════════════════════════════════════════════*/

USE AdventureWorks;
GO
SET NOCOUNT ON;

-- 1. Who is blocking whom
SELECT r.blocking_session_id AS [Blocker SPID],
       r.session_id          AS [Blocked SPID],
       r.wait_type           AS [Wait Type],
       r.wait_time           AS [Waited ms],
       r.wait_resource       AS [Waiting On],
       SUBSTRING(t.text, 1, 80) AS [Blocked Statement]
FROM   sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE  r.blocking_session_id <> 0;

-- 2. Lock footprint per session, with the interesting rows called out
SELECT l.request_session_id AS [SPID],
       l.resource_type      AS [Resource],
       l.request_mode       AS [Mode],
       l.request_status     AS [Status],
       COUNT(*)             AS [Count],
       CASE WHEN l.resource_type = 'OBJECT' AND l.request_mode = 'X'  THEN '<-- table locked (escalation)'
            WHEN l.resource_type = 'XACT'                             THEN '<-- TID lock (optimized locking)'
            WHEN l.request_status = 'WAIT'                            THEN '<-- waiting'
            ELSE '' END     AS [Note]
FROM   sys.dm_tran_locks l
WHERE  l.resource_type <> 'DATABASE'
  AND  l.resource_database_id = DB_ID('AdventureWorks')
GROUP  BY l.request_session_id, l.resource_type, l.request_mode, l.request_status
ORDER  BY [SPID], [Count] DESC;
GO
