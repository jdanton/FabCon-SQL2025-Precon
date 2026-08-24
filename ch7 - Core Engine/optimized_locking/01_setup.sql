/*═══════════════════════════════════════════════════════════════════════════
  OPTIMIZED LOCKING — SETUP  (run once, before the demo)
  ───────────────────────────────────────────────────────────────────────────
  Puts the database into a known state and prints a readiness grid.

    ACCELERATED_DATABASE_RECOVERY = ON   -- REQUIRED. Optimized locking is
                                            built on ADR's persisted version
                                            store; it cannot be enabled without it.
    READ_COMMITTED_SNAPSHOT       = OFF  -- so writer/reader blocking is visible.
                                            (AdventureWorks2022 ships with RCSI ON.)
    OPTIMIZED_LOCKING             = OFF  -- demo starts in the "before" state.

  Also stores the SalesOrderIDs the demo uses in dbo.OptLockDemoConfig.
  This matters: the victim session must resolve its target row BEFORE it gets
  blocked. Computing MIN/MAX inside a blocked session makes the lookup itself
  block, and if it times out the variable is left NULL -- the UPDATE then
  matches zero rows and the demo silently "passes" while proving nothing.
═══════════════════════════════════════════════════════════════════════════*/

USE [master];
GO
ALTER DATABASE [AdventureWorks] SET ACCELERATED_DATABASE_RECOVERY = ON  WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [AdventureWorks] SET READ_COMMITTED_SNAPSHOT         OFF WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [AdventureWorks] SET OPTIMIZED_LOCKING             = OFF WITH ROLLBACK IMMEDIATE;
GO

USE AdventureWorks;
GO
SET NOCOUNT ON;

DROP TABLE IF EXISTS dbo.OptLockDemoConfig;
SELECT MIN(SalesOrderID) AS MinSalesOrderID,
       MAX(SalesOrderID) AS MaxSalesOrderID
INTO   dbo.OptLockDemoConfig
FROM   Sales.SalesOrderHeader;
GO

SELECT 'ADR (required)'        AS Setting,
       CASE WHEN is_accelerated_database_recovery_on = 1 THEN 'ON  <-- ok' ELSE 'OFF <-- FIX' END AS Value
FROM sys.databases WHERE name = 'AdventureWorks'
UNION ALL SELECT 'RCSI (want OFF)',
       CASE WHEN is_read_committed_snapshot_on = 0 THEN 'OFF <-- ok' ELSE 'ON  <-- FIX' END
FROM sys.databases WHERE name = 'AdventureWorks'
UNION ALL SELECT 'Optimized Locking',
       CASE WHEN is_optimized_locking_on = 0 THEN 'OFF <-- ok, "before" state' ELSE 'ON' END
FROM sys.databases WHERE name = 'AdventureWorks'
UNION ALL SELECT 'Demo target row (victim)', CAST(MaxSalesOrderID AS VARCHAR(20)) FROM dbo.OptLockDemoConfig
UNION ALL SELECT 'Blocker range starts at',  CAST(MinSalesOrderID AS VARCHAR(20)) FROM dbo.OptLockDemoConfig;
GO
