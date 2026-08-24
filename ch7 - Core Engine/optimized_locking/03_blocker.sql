/*═══════════════════════════════════════════════════════════════════════════
  ACT 2, WINDOW A — THE BLOCKER
  ───────────────────────────────────────────────────────────────────────────
  Press F5 ONCE. Walk away. It cleans up after itself.

  Updates 10,000 rows inside an open transaction and holds it for 30 seconds,
  then rolls back automatically. There is no second batch to remember, and no
  transaction left open on stage if you get interrupted.

  With OPTIMIZED_LOCKING = OFF this escalates to a TABLE-level X lock.
  With OPTIMIZED_LOCKING = ON  it holds one TID lock and an intent (IX) lock.

  Run 04_victim.sql in a second window while this is running.
═══════════════════════════════════════════════════════════════════════════*/

USE AdventureWorks;
GO
SET NOCOUNT ON;

DECLARE @minId INT = (SELECT MinSalesOrderID FROM dbo.OptLockDemoConfig);
DECLARE @holdSeconds CHAR(8) = '00:00:30';

PRINT 'Blocker starting on SPID ' + CAST(@@SPID AS VARCHAR(10))
    + ' -- holding for ' + @holdSeconds + ', then rolling back.';

BEGIN TRAN;

    UPDATE Sales.SalesOrderHeader
    SET    Freight = Freight * 1.0        -- value-neutral; always rolled back
    WHERE  SalesOrderID <= @minId + 10000;

    -- What this transaction is actually holding, right now:
    SELECT resource_type      AS [Resource],
           request_mode       AS [Mode],
           COUNT(*)           AS [Count],
           CASE WHEN resource_type = 'OBJECT' AND request_mode = 'X'
                THEN '<-- ESCALATED to a table lock. Everyone else waits.'
                WHEN resource_type = 'XACT'
                THEN '<-- TID lock. This is optimized locking working.'
                ELSE '' END  AS [Note]
    FROM   sys.dm_tran_locks
    WHERE  request_session_id = @@SPID AND resource_type <> 'DATABASE'
    GROUP  BY resource_type, request_mode
    ORDER  BY [Count] DESC;

    WAITFOR DELAY @holdSeconds;

ROLLBACK TRAN;

PRINT 'Blocker released. Transaction rolled back -- no data changed.';
GO
