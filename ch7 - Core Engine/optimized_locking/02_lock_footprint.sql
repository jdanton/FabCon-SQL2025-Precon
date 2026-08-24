/*═══════════════════════════════════════════════════════════════════════════
  OPTIMIZED LOCKING — ACT 1: THE LOCK FOOTPRINT
  ───────────────────────────────────────────────────────────────────────────
  ONE WINDOW. ONE F5. No second session, no manual transaction juggling.

  Runs the SAME update four times -- two row counts x optimized locking
  OFF/ON -- and prints a single comparison grid.

  What the audience should see:
    * 4,000 rows, OL OFF -> ~4,000 individual row (KEY) locks
    * 4,000 rows, OL ON  -> 3 locks. One XACT (TID) lock replaces them all.
    * 10,000 rows, OL OFF -> escalates to a TABLE-level X lock (blocks everyone)
    * 10,000 rows, OL ON  -> still just a TID lock. No escalation.

  Every pass rolls back. No data is modified.
  Prereq: run 00_setup.sql first.
═══════════════════════════════════════════════════════════════════════════*/

USE AdventureWorks;
GO
SET NOCOUNT ON;

DECLARE @results TABLE (
    Seq          INT IDENTITY(1,1),
    RowsUpdated  VARCHAR(10),
    OptLocking   VARCHAR(3),
    UpdateMS     INT,
    TotalLocks   INT,
    RowLocks     INT,
    PageLocks    INT,
    TableLock    VARCHAR(4),
    TIDLock      VARCHAR(3),
    Escalated    VARCHAR(3)
);

DECLARE @minId INT = (SELECT MIN(SalesOrderID) FROM Sales.SalesOrderHeader);
DECLARE @nRows INT, @ol VARCHAR(3), @sql NVARCHAR(400), @t0 DATETIME2, @ms INT;
DECLARE @tot INT, @row INT, @pg INT, @tbl VARCHAR(4), @tid VARCHAR(3);

DECLARE passes CURSOR LOCAL FAST_FORWARD FOR
    SELECT n, o FROM (VALUES (4000,'OFF'),(4000,'ON'),(10000,'OFF'),(10000,'ON')) v(n,o);

OPEN passes;
FETCH NEXT FROM passes INTO @nRows, @ol;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Toggle the feature (must happen outside a transaction)
    SET @sql = N'ALTER DATABASE [AdventureWorks] SET OPTIMIZED_LOCKING = '
             + @ol + N' WITH ROLLBACK IMMEDIATE;';
    EXEC sp_executesql @sql;

    SET @t0 = SYSDATETIME();
    BEGIN TRAN;
        UPDATE Sales.SalesOrderHeader
        SET    Freight = Freight * 1.0          -- value-neutral; always rolled back
        WHERE  SalesOrderID <= @minId + @nRows;

        SET @ms = DATEDIFF(MILLISECOND, @t0, SYSDATETIME());

        -- Snapshot this session's locks while the transaction is still open
        SELECT @tot = COUNT(*),
               @row = SUM(CASE WHEN resource_type = 'KEY'  THEN 1 ELSE 0 END),
               @pg  = SUM(CASE WHEN resource_type = 'PAGE' THEN 1 ELSE 0 END)
        FROM   sys.dm_tran_locks
        WHERE  request_session_id = @@SPID AND resource_type <> 'DATABASE';

        SELECT @tbl = MAX(request_mode)
        FROM   sys.dm_tran_locks
        WHERE  request_session_id = @@SPID AND resource_type = 'OBJECT';

        SELECT @tid = CASE WHEN COUNT(*) > 0 THEN 'yes' ELSE 'no' END
        FROM   sys.dm_tran_locks
        WHERE  request_session_id = @@SPID AND resource_type = 'XACT';
    ROLLBACK TRAN;

    INSERT @results (RowsUpdated, OptLocking, UpdateMS, TotalLocks, RowLocks,
                     PageLocks, TableLock, TIDLock, Escalated)
    VALUES (FORMAT(@nRows,'#,0'), @ol, @ms, @tot, @row, @pg, @tbl, @tid,
            CASE WHEN @tbl = 'X' THEN 'YES' ELSE 'no' END);

    FETCH NEXT FROM passes INTO @nRows, @ol;
END

CLOSE passes; DEALLOCATE passes;

-- Leave the database in the "before" state so Act 2 starts clean
ALTER DATABASE [AdventureWorks] SET OPTIMIZED_LOCKING = OFF WITH ROLLBACK IMMEDIATE;

SELECT RowsUpdated AS [Rows], OptLocking AS [OptLock], UpdateMS AS [Update ms],
       TotalLocks AS [Total Locks], RowLocks AS [Row Locks], PageLocks AS [Page Locks],
       TableLock AS [Table Lock], TIDLock AS [TID Lock], Escalated AS [Escalated?]
FROM @results ORDER BY Seq;
GO
