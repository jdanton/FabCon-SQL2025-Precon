-- ============================================================================
-- 01_create_database.sql
-- Creates the F1RaceOps database and enables the CES preview feature.
-- ============================================================================

USE master;
GO

-- Drop if exists (for repeatable demos)
-- Must tear down CES before dropping the database, and USE can't go
-- inside IF/BEGIN, so we use dynamic SQL to run against F1RaceOps.
IF DB_ID('F1RaceOps') IS NOT NULL
BEGIN
    -- Disable CES if it's enabled (ignore errors if it's not)
    BEGIN TRY
        EXEC F1RaceOps.sys.sp_disable_event_stream;
    END TRY
    BEGIN CATCH
        PRINT 'CES was not enabled — skipping disable.';
    END CATCH

    ALTER DATABASE F1RaceOps SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE F1RaceOps;
    PRINT 'Existing F1RaceOps database dropped.';
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

ALTER DATABASE SCOPED CONFIGURATION
SET PREVIEW_FEATURES = ON;
GO

PRINT 'Database F1RaceOps created with FULL recovery model and preview features enabled.';
GO
