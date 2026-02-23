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

-- Enable preview features (required for DiskANN index and vector functions)
EXEC sp_db_option_override_preview 'VectorF1', 'PREVIEW_FEATURES', 'ON';
GO

PRINT 'Preview features enabled on VectorF1.';
PRINT '';
PRINT '=== Database ready. Proceed to 02_create_tables.sql ===';
GO
