-- ============================================================================
-- 05_configure_model.sql
-- Creates an external model definition pointing to a local Ollama instance
-- running the nomic-embed-text embedding model.
--
-- PREREQUISITES:
--   1. Ollama installed and running: http://localhost:11434
--   2. Model pulled: ollama pull nomic-embed-text
-- ============================================================================

USE VectorF1;
GO

-- ── Step 1: Create the external model definition ──────────────────────────
-- This tells SQL Server where to find the embedding model.
-- nomic-embed-text produces 768-dimensional vectors.

IF EXISTS (SELECT 1 FROM sys.external_models WHERE name = 'OllamaEmbedding')
    DROP EXTERNAL MODEL OllamaEmbedding;
GO

CREATE EXTERNAL MODEL OllamaEmbedding
    WITH (
    LOCATION = 'https://model-web:443/api/embed',
    API_FORMAT = 'Ollama',
    MODEL_TYPE = EMBEDDINGS,
    MODEL = 'nomic-embed-text'
);
GO

PRINT 'External model OllamaEmbedding created (nomic-embed-text via Ollama).';
GO

-- ── Step 2: Verify the model is accessible ────────────────────────────────
-- Generate a test embedding to confirm connectivity.

SELECT AI_GENERATE_EMBEDDINGS(N'test text' USE MODEL OllamaEmbedding) AS GeneratedEmbedding;
    AS TestEmbedding;
GO

PRINT 'Model verified — embedding generation is working.';
PRINT '';
PRINT '=== Model configured. Proceed to 06_generate_embeddings.sql ===';
GO
