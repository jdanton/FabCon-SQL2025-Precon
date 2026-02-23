-- ============================================================================
-- 07_cleanup.sql
-- Tears down CES configuration and drops the F1RaceOps database.
-- Run this when you're done with the demo.
-- ============================================================================

USE F1RaceOps;
GO

-- ── Step 1: Remove tables from the stream group ─────────────────────────────

EXEC sys.sp_remove_object_from_event_stream_group N'F1RaceStreamGroup', N'dbo.Drivers';
EXEC sys.sp_remove_object_from_event_stream_group N'F1RaceStreamGroup', N'dbo.Races';
EXEC sys.sp_remove_object_from_event_stream_group N'F1RaceStreamGroup', N'dbo.LiveTiming';
EXEC sys.sp_remove_object_from_event_stream_group N'F1RaceStreamGroup', N'dbo.PitStops';
EXEC sys.sp_remove_object_from_event_stream_group N'F1RaceStreamGroup', N'dbo.RaceControl';
GO

PRINT 'All tables removed from the stream group.';
GO

-- ── Step 2: Drop the stream group ───────────────────────────────────────────

EXEC sys.sp_drop_event_stream_group N'F1RaceStreamGroup';
GO

PRINT 'Stream group dropped.';
GO

-- ── Step 3: Disable CES on the database ─────────────────────────────────────

EXEC sys.sp_disable_event_stream;
GO

PRINT 'Change Event Streaming disabled.';
GO

-- ── Step 4: Drop the database ───────────────────────────────────────────────

USE master;
GO

ALTER DATABASE F1RaceOps SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE F1RaceOps;
GO

PRINT 'F1RaceOps database dropped. Cleanup complete.';
GO
