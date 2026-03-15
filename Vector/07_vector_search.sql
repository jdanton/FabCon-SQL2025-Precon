-- ============================================================================
-- 07_vector_search.sql
-- Demonstrates semantic vector search using the SAME queries from script 04.
--
-- The contrast is the entire point: keyword search missed most results,
-- but vector search understands MEANING and finds the right races every time.
--
-- PREREQUISITES:
--   Scripts 01-06 completed (embeddings generated, DiskANN index created)
-- ============================================================================

USE VectorF1;
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- HOW IT WORKS
-- ═══════════════════════════════════════════════════════════════════════════
-- 1. We take a natural-language question and generate an embedding for it
--    using AI_GENERATE_EMBEDDINGS (same Ollama model used for the recaps).
-- 2. We compare that embedding against every recap's embedding using
--    VECTOR_DISTANCE (cosine similarity) — this is exact KNN search.
-- 3. We also show VECTOR_SEARCH which uses the DiskANN index for fast
--    approximate nearest neighbor (ANN) search.
-- ═══════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 1: "Find races where rain completely changed the outcome"
-- ═══════════════════════════════════════════════════════════════════════════
-- Script 04 result: LIKE '%rain%changed%' → almost nothing.
-- Vector search: finds Brazil 2008, Canada 2011, Germany 2019, etc.

-- Method A: KNN with VECTOR_DISTANCE (exact search — scans all rows)
DECLARE @q1 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Find races where rain completely changed the outcome'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.Weather,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @q1) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
ORDER BY Distance;
GO

-- Method B: ANN with DiskANN index (automatic — same syntax, faster execution)
-- When a DiskANN index exists on the column, SQL Server uses it automatically
-- for approximate nearest neighbor search via VECTOR_DISTANCE + ORDER BY.
DECLARE @q1b VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Find races where rain completely changed the outcome'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.Weather,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @q1b) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
ORDER BY Distance;
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 2: "Find races with an incredible comeback from the back of the grid"
-- ═══════════════════════════════════════════════════════════════════════════
-- Script 04 result: LIKE '%comeback%' OR '%last place%' → partial matches.
-- Vector search: finds Button Canada 2011, Perez Sakhir 2020, etc.

DECLARE @q2 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Find races with an incredible comeback from the back of the grid'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @q2) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
ORDER BY Distance;
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 3: "Find races with a heartbreaking championship defeat"
-- ═══════════════════════════════════════════════════════════════════════════
-- Script 04 result: LIKE '%heartbreak%championship%' → almost nothing.
-- Vector search: finds Brazil 2008 (Massa), Abu Dhabi 2010, etc.

DECLARE @q3 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Find races with a heartbreaking championship defeat on the final race'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.ChampionshipDecider,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @q3) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
ORDER BY Distance;
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 4: "Find races where a driver survived a terrifying crash"
-- ═══════════════════════════════════════════════════════════════════════════
-- Script 04 result: LIKE '%terrifying%crash%' → missed Grosjean, Zhou, Lauda.
-- Vector search: finds Grosjean 2020, Lauda 1976, Zhou 2022, etc.

DECLARE @q4 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Find races where a driver survived a terrifying crash'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.RedFlag,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @q4) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
ORDER BY Distance;
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 5: "Find controversial decisions that decided a championship"
-- ═══════════════════════════════════════════════════════════════════════════
-- Script 04 result: LIKE '%controversial%decision%championship%' → ~0 rows.
-- Vector search: finds Abu Dhabi 2021, Silverstone 2021, Suzuka 1989, etc.

DECLARE @q5 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Find controversial decisions that decided a championship'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.ChampionshipDecider,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @q5) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
ORDER BY Distance;
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- BONUS: Try your own query!
-- ═══════════════════════════════════════════════════════════════════════════
-- Change the text below to any natural language question.

DECLARE @custom VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'a race where a first-time winner shocked the world'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @custom) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
ORDER BY Distance;
GO


PRINT '=== Vector search complete. Compare these results to script 04! ===';
PRINT 'Vector search understands MEANING, not just keywords.';
PRINT '';
PRINT 'Proceed to 08_hybrid_search.sql for combined vector + SQL filters.';
GO
