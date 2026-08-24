/*═══════════════════════════════════════════════════════════════════════════
  ACT 2, WINDOW B — THE VICTIM  (the performance number)
  ───────────────────────────────────────────────────────────────────────────
  Press F5 while 03_blocker.sql is running in Window A.

  Updates exactly ONE row, by clustered key, that the blocker is NOT touching.
  In a world without lock escalation this should be instant.

  Prints how long it actually waited, and the verdict.

  Expected (measured on SQL Server 2025 CU2, AdventureWorks2022):
      OPTIMIZED_LOCKING = OFF  ->  ~14,000 ms   blocked until the blocker ends
      OPTIMIZED_LOCKING = ON   ->      ~60 ms   unaffected
═══════════════════════════════════════════════════════════════════════════*/

USE AdventureWorks;
GO
SET NOCOUNT ON;
SET LOCK_TIMEOUT 60000;   -- so a stuck demo fails loudly instead of hanging

-- Resolved BEFORE the blocking starts, from the tiny config table.
-- Reading Sales.SalesOrderHeader here would itself block. See 01_setup.sql.
DECLARE @targetId INT = (SELECT MaxSalesOrderID FROM dbo.OptLockDemoConfig);
DECLARE @optLock  BIT = (SELECT is_optimized_locking_on FROM sys.databases WHERE name = 'AdventureWorks');

DECLARE @t0 DATETIME2(3) = SYSDATETIME();
DECLARE @outcome VARCHAR(60) = 'Completed';

BEGIN TRY
    BEGIN TRAN;
        UPDATE Sales.SalesOrderHeader
        SET    Freight = Freight * 1.0
        WHERE  SalesOrderID = @targetId;
    ROLLBACK TRAN;                        -- leave the data untouched
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    SET @outcome = 'FAILED: ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' ' + ERROR_MESSAGE();
END CATCH

DECLARE @ms INT = DATEDIFF(MILLISECOND, @t0, SYSDATETIME());

SELECT CASE WHEN @optLock = 1 THEN 'ON' ELSE 'OFF' END AS [Optimized Locking],
       @targetId                                       AS [Row Updated],
       @outcome                                        AS [Outcome],
       @ms                                             AS [Waited ms],
       CASE WHEN @ms < 1000 THEN 'Not blocked -- no escalation, TID locking did its job.'
            ELSE 'BLOCKED for ' + CAST(@ms/1000 AS VARCHAR(10))
                 + 's by a table lock it had nothing to do with.'
       END                                             AS [Verdict];
GO
