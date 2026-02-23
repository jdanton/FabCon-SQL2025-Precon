-- ============================================================================
-- 06_generate_embeddings.sql
-- Generates embeddings for all race recaps using the Ollama model, stores
-- them in the VECTOR(768) column, and creates a DiskANN vector index.
--
-- This script may take 1-2 minutes depending on your hardware (Ollama
-- processes each recap through the nomic-embed-text model).
-- ============================================================================

USE VectorF1;
GO

-- ── Step 1: Generate embeddings for all race recaps ───────────────────────
-- Uses AI_GENERATE_EMBEDDINGS to call Ollama for each recap text.

PRINT 'Generating embeddings for all race recaps...';
PRINT 'This calls Ollama for each row — may take 1-2 minutes.';
GO

UPDATE dbo.RaceRecaps
SET RecapEmbedding = AI_GENERATE_EMBEDDINGS(Recap, 'OllamaEmbedding')
WHERE RecapEmbedding IS NULL;
GO

-- Verify
SELECT
    COUNT(*) AS TotalRecaps,
    COUNT(RecapEmbedding) AS WithEmbeddings,
    COUNT(*) - COUNT(RecapEmbedding) AS MissingEmbeddings
FROM dbo.RaceRecaps;
GO

PRINT 'Embeddings generated for all recaps.';
GO

-- ── Step 2: Create a DiskANN vector index ─────────────────────────────────
-- This enables fast approximate nearest neighbor (ANN) search.
-- Without it, VECTOR_DISTANCE scans every row (exact KNN — slower).
-- With it, VECTOR_SEARCH uses the index for sub-second results.

CREATE VECTOR INDEX IX_RaceRecaps_Vector
ON dbo.RaceRecaps(RecapEmbedding)
WITH (METRIC = 'cosine', TYPE = DISKANN);
GO

PRINT 'DiskANN vector index created on RecapEmbedding.';
PRINT '';
PRINT '=== Embeddings and index ready. Proceed to 07_vector_search.sql ===';
GO
