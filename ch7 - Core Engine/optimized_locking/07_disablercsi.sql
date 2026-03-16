/*
Disables Read Committed Snapshot Isolation to better demonstrate TID locking behavior. With RCSI enabled, 
readers don't acquire locks anyway, so disabling it makes the demo clearer.
*/


USE [master];
GO
ALTER DATABASE [AdventureWorks]
SET READ_COMMITTED_SNAPSHOT OFF
WITH ROLLBACK IMMEDIATE;
GO
