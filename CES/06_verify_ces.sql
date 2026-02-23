-- ============================================================================
-- 06_verify_ces.sql
-- Queries CES diagnostic views to confirm streaming is active and healthy.
-- ============================================================================

USE F1RaceOps;
GO

-- ── Is CES enabled on this database? ────────────────────────────────────────

SELECT name AS DatabaseName, is_event_stream_enabled
FROM sys.databases
WHERE name = 'F1RaceOps';
GO

-- ── Which tables are being streamed? ────────────────────────────────────────

SELECT t.name AS TableName, t.is_replicated AS IsStreaming
FROM sys.tables t
WHERE t.is_replicated = 1
ORDER BY t.name;
GO

-- ── Stream group and table metadata ─────────────────────────────────────────

EXEC sys.sp_help_change_feed_settings;
GO

EXEC sys.sp_help_change_feed;
GO

EXEC sys.sp_help_change_feed_table_groups;
GO

-- ── Check for tables in the stream group with detailed metadata ─────────────

EXEC sys.sp_help_change_feed_table
    @source_schema = 'dbo',
    @source_name = 'LiveTiming';
GO

EXEC sys.sp_help_change_feed_table
    @source_schema = 'dbo',
    @source_name = 'PitStops';
GO

-- ── Check for delivery errors ───────────────────────────────────────────────
-- If this returns rows, there are problems delivering events to Event Hubs.

SELECT TOP 20 *
FROM sys.dm_change_feed_errors
ORDER BY entry_time DESC;
GO

-- ── Log scan session activity ───────────────────────────────────────────────
-- Shows how actively CES is scanning the transaction log.

SELECT TOP 10 *
FROM sys.dm_change_feed_log_scan_sessions
ORDER BY start_time DESC;
GO

-- ── Quick stats: how many events have we generated? ─────────────────────────

SELECT 'LiveTiming rows'  AS Metric, COUNT(*) AS Total FROM dbo.LiveTiming
UNION ALL
SELECT 'PitStop events',   COUNT(*) FROM dbo.PitStops
UNION ALL
SELECT 'RaceControl msgs', COUNT(*) FROM dbo.RaceControl;
GO
