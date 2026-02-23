-- ============================================================================
-- 02_create_tables.sql
-- Creates the F1 vector search schema.
--
-- Tables:
--   Circuits    - F1 circuit reference data (name, country, type)
--   RaceRecaps  - Iconic race summaries with VECTOR(768) for embeddings
--
-- The VECTOR(768) dimension matches the nomic-embed-text Ollama model.
-- ============================================================================

USE VectorF1;
GO

-- ── Circuits (reference data) ─────────────────────────────────────────────

CREATE TABLE dbo.Circuits
(
    CircuitId       INT             NOT NULL PRIMARY KEY,
    CircuitName     NVARCHAR(100)   NOT NULL,
    Country         NVARCHAR(50)    NOT NULL,
    City            NVARCHAR(50)    NOT NULL,
    LengthKm       DECIMAL(4,2)    NOT NULL,
    CircuitType     NVARCHAR(20)    NOT NULL   -- Street, Permanent, Hybrid
);
GO

-- ── Race Recaps (with vector column) ──────────────────────────────────────

CREATE TABLE dbo.RaceRecaps
(
    RecapId             INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Year                INT             NOT NULL,
    CircuitId           INT             NOT NULL REFERENCES dbo.Circuits(CircuitId),
    RaceName            NVARCHAR(100)   NOT NULL,
    Winner              NVARCHAR(50)    NOT NULL,
    WinnerTeam          NVARCHAR(50)    NOT NULL,
    Weather             NVARCHAR(10)    NOT NULL DEFAULT 'Dry',   -- Dry, Wet, Mixed
    SafetyCar           BIT             NOT NULL DEFAULT 0,
    RedFlag             BIT             NOT NULL DEFAULT 0,
    ChampionshipDecider BIT             NOT NULL DEFAULT 0,
    Recap               NVARCHAR(MAX)   NOT NULL,

    -- Vector column for semantic search (768 dimensions = nomic-embed-text)
    RecapEmbedding      VECTOR(768)     NULL
);
GO

-- Indexes for hybrid search filtering
CREATE NONCLUSTERED INDEX IX_RaceRecaps_Year ON dbo.RaceRecaps (Year);
CREATE NONCLUSTERED INDEX IX_RaceRecaps_Circuit ON dbo.RaceRecaps (CircuitId);
CREATE NONCLUSTERED INDEX IX_RaceRecaps_Winner ON dbo.RaceRecaps (Winner);
CREATE NONCLUSTERED INDEX IX_RaceRecaps_Weather ON dbo.RaceRecaps (Weather);
GO

PRINT 'Tables created: Circuits, RaceRecaps (with VECTOR(768) column).';
PRINT '';
PRINT '=== Schema ready. Proceed to 03_seed_data.sql ===';
GO
