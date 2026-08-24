/*═══════════════════════════════════════════════════════════════════════════
  RESET — run after the demo (or if a session gets wedged)
  ───────────────────────────────────────────────────────────────────────────
  WITH ROLLBACK IMMEDIATE kills any transaction still open from 03_blocker.sql,
  so this doubles as the "get me out of trouble" button.
═══════════════════════════════════════════════════════════════════════════*/

USE [master];
GO
ALTER DATABASE [AdventureWorks] SET OPTIMIZED_LOCKING       = OFF WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [AdventureWorks] SET READ_COMMITTED_SNAPSHOT   ON  WITH ROLLBACK IMMEDIATE;  -- AdventureWorks2022 default
GO

USE AdventureWorks;
GO
DROP TABLE IF EXISTS dbo.OptLockDemoConfig;
GO

SELECT name AS [Database],
       is_accelerated_database_recovery_on AS [ADR],
       is_read_committed_snapshot_on       AS [RCSI],
       is_optimized_locking_on             AS [Optimized Locking]
FROM sys.databases WHERE name = 'AdventureWorks';
GO
