-- ============================================================================
-- 01_create_database.sql
-- Creates the VectorF1 database and enables the preview features required
-- for DiskANN vector indexing and vector functions.
-- ============================================================================

-- Create the database
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'VectorF1')
BEGIN
    CREATE DATABASE VectorF1;
    PRINT 'Database VectorF1 created.';
END
ELSE
    PRINT 'Database VectorF1 already exists.';
GO

USE VectorF1;
GO

ALTER DATABASE SCOPED CONFIGURATION
SET PREVIEW_FEATURES = ON;
GO

PRINT 'Preview features enabled on VectorF1.';
PRINT '';
PRINT '=== Database ready. Proceed to 02_create_tables.sql ===';
GO
