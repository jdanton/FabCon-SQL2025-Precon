-- ============================================================================
-- 01_create_database.sql
-- Creates the F1RaceOps database and enables the CES preview feature.
-- ============================================================================

USE master;
GO

-- Drop if exists (for repeatable demos)
IF DB_ID('F1RaceOps') IS NOT NULL
BEGIN
    ALTER DATABASE F1RaceOps SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE F1RaceOps;
END
GO

-- Create the database
CREATE DATABASE F1RaceOps;
GO

-- CES requires the full recovery model
ALTER DATABASE F1RaceOps SET RECOVERY FULL;
GO

USE F1RaceOps;
GO

-- Enable the CES preview feature (required for SQL Server 2025 on-prem)
ALTER DATABASE SCOPED CONFIGURATION SET ENABLE_PREVIEW_FEATURES = ON;
GO

PRINT 'Database F1RaceOps created with FULL recovery model and preview features enabled.';
GO
