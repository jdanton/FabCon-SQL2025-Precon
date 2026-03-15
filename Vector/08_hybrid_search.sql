-- ============================================================================
-- 08_hybrid_search.sql
-- Combines vector similarity search with traditional SQL filters.
--
-- This is the killer feature: unlike standalone vector databases, SQL Server
-- lets you combine semantic search with relational queries in a SINGLE
-- statement — no separate systems, no data duplication, no glue code.
--
-- PREREQUISITES:
--   Scripts 01-06 completed (embeddings generated, DiskANN index created)
-- ============================================================================

USE VectorF1;
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- HYBRID SEARCH 1: Vector + Time Filter
-- "Rain chaos" — but only in the last decade
-- ═══════════════════════════════════════════════════════════════════════════

DECLARE @h1 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Rain chaos that completely changed the race'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.Weather,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h1) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
WHERE r.Year BETWEEN 2015 AND 2024
ORDER BY VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h1);
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- HYBRID SEARCH 2: Vector + Championship Context
-- "Championship battle" — only races that decided a title
-- ═══════════════════════════════════════════════════════════════════════════

DECLARE @h2 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'An intense championship battle decided on the final lap'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.WinnerTeam,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h2) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
WHERE r.ChampionshipDecider = 1
ORDER BY VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h2);
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- HYBRID SEARCH 3: Vector + Driver Filter
-- "Incredible comeback" — but only Hamilton's races
-- ═══════════════════════════════════════════════════════════════════════════

DECLARE @h3 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'An incredible comeback drive from the back of the grid to victory'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.WinnerTeam,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h3) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
WHERE r.Winner = 'Hamilton'
ORDER BY VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h3);
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- HYBRID SEARCH 4: Vector + Safety Events
-- "Dramatic safety car" — only races with safety car deployments
-- ═══════════════════════════════════════════════════════════════════════════

DECLARE @h4 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'A dramatic safety car that completely reshuffled the race order'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    r.SafetyCar,
    r.RedFlag,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h4) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
WHERE r.SafetyCar = 1
ORDER BY VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h4);
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- HYBRID SEARCH 5: Vector + Circuit Join
-- "Street circuit drama" — join with Circuits table for street races only
-- ═══════════════════════════════════════════════════════════════════════════

DECLARE @h5 VECTOR(768) = AI_GENERATE_EMBEDDINGS(
    N'Dramatic racing on a tight street circuit with crashes and overtakes'
    USE MODEL OllamaEmbedding
);

SELECT TOP 5
    r.Year,
    r.RaceName,
    c.CircuitName,
    c.Country,
    c.CircuitType,
    r.Winner,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h5) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
    INNER JOIN dbo.Circuits c ON r.CircuitId = c.CircuitId
WHERE c.CircuitType = 'Street'
ORDER BY VECTOR_DISTANCE('cosine', r.RecapEmbedding, @h5);
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- "MORE LIKE THIS" — Find races similar to a specific race
-- ═══════════════════════════════════════════════════════════════════════════
-- Given one race, find the 5 most similar races in the dataset.
-- This uses the EXISTING embedding of the source race — no new AI call needed.

-- Example: "Show me races most similar to Abu Dhabi 2021"
DECLARE @sourceEmbedding VECTOR(768);

SELECT @sourceEmbedding = RecapEmbedding
FROM dbo.RaceRecaps
WHERE Year = 2021 AND RaceName = 'Abu Dhabi Grand Prix';

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @sourceEmbedding) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
WHERE NOT (r.Year = 2021 AND r.RaceName = 'Abu Dhabi Grand Prix')  -- Exclude the source
ORDER BY VECTOR_DISTANCE('cosine', r.RecapEmbedding, @sourceEmbedding);
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- "MORE LIKE THIS" — Brazil 2008 edition
-- ═══════════════════════════════════════════════════════════════════════════
-- Find races similar to Massa's heartbreaking championship loss at home.

DECLARE @brazilEmbedding VECTOR(768);

SELECT @brazilEmbedding = RecapEmbedding
FROM dbo.RaceRecaps
WHERE Year = 2008 AND RaceName = 'Brazilian Grand Prix';

SELECT TOP 5
    r.Year,
    r.RaceName,
    r.Winner,
    VECTOR_DISTANCE('cosine', r.RecapEmbedding, @brazilEmbedding) AS Distance,
    LEFT(r.Recap, 150) AS RecapPreview
FROM dbo.RaceRecaps r
WHERE NOT (r.Year = 2008 AND r.RaceName = 'Brazilian Grand Prix')
ORDER BY VECTOR_DISTANCE('cosine', r.RecapEmbedding, @brazilEmbedding);
GO


PRINT '=== Hybrid search complete. ===';
PRINT '';
PRINT 'KEY TAKEAWAY: SQL Server 2025 combines vector search with the full';
PRINT 'power of the relational engine — JOINs, WHERE, GROUP BY, aggregates.';
PRINT 'No other vector database gives you this.';
PRINT '';
PRINT 'Run 09_cleanup.sql when you are finished with the demo.';
GO
