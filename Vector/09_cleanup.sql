-- ============================================================================
-- 09_cleanup.sql
-- Tears down the vector search demo: drops the index, model, and database.
-- ============================================================================

USE VectorF1;
GO

-- Drop vector index if it exists
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_RaceRecaps_Vector' AND object_id = OBJECT_ID('dbo.RaceRecaps'))
BEGIN
    DROP INDEX IX_RaceRecaps_Vector ON dbo.RaceRecaps;
    PRINT 'Vector index dropped.';
END
GO

-- Drop external model if it exists
IF EXISTS (SELECT 1 FROM sys.external_models WHERE name = 'OllamaEmbedding')
BEGIN
    DROP EXTERNAL MODEL OllamaEmbedding;
    PRINT 'External model dropped.';
END
GO

USE master;
GO

-- Drop the database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'VectorF1')
BEGIN
    ALTER DATABASE VectorF1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE VectorF1;
    PRINT 'Database VectorF1 dropped.';
END
GO

PRINT 'Cleanup complete.';
GO
