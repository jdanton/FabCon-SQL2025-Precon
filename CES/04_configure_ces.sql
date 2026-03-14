-- ============================================================================
-- 04_configure_ces.sql
-- Configures Change Event Streaming to push F1 race data changes to
-- Azure Event Hubs in near real-time.
--
-- BEFORE RUNNING: Replace the placeholder values below with your own:
--   <YourMasterKeyPassword>    - A strong password for the database master key
--   <YourEventHubsNamespace>   - e.g. f1racing-ns
--   <YourEventHubsInstance>    - e.g. f1-race-events
--
-- PREREQUISITES:
--   The SQL Server's managed identity (system-assigned or user-assigned) must
--   be granted the "Azure Event Hubs Data Sender" role on the Event Hub.
-- ============================================================================

USE F1RaceOps;
GO

-- ── Step 1: Create a database master key ────────────────────────────────────

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<YourMasterKeyPassword>';
    PRINT 'Master key created.';
END
GO

-- ── Step 2: Create a database-scoped credential for Event Hubs ──────────────
-- This uses Managed Identity authentication. No secrets to manage or rotate.
-- The SQL Server's identity must have "Azure Event Hubs Data Sender" on the hub.

IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = 'F1EventHubCredential')
    DROP DATABASE SCOPED CREDENTIAL F1EventHubCredential;
GO

CREATE DATABASE SCOPED CREDENTIAL F1EventHubCredential
    WITH IDENTITY = 'Managed Identity';
GO

PRINT 'Database-scoped credential created (Managed Identity).';
GO

-- ── Step 3: Enable Change Event Streaming on the database ───────────────────

EXEC sys.sp_enable_event_stream;
GO

PRINT 'Change Event Streaming enabled on F1RaceOps.';
GO

-- ── Step 4: Create the event stream group ───────────────────────────────────
-- We use 'Table' partitioning so that events from different tables land in
-- separate Event Hubs partitions. This lets consumers filter efficiently
-- (e.g., a pit wall dashboard only reads the PitStops partition).

EXEC sys.sp_create_event_stream_group
    @stream_group_name      = N'F1RaceStreamGroup',
    @destination_type       = N'AzureEventHubsAmqp',
    @destination_location   = N'f1ces-ns-3308.servicebus.windows.net/f1-race-events',
    @destination_credential = F1EventHubCredential,
    @max_message_size_kb    = 256,
    @partition_key_scheme   = N'Table';
GO

PRINT 'Event stream group "F1RaceStreamGroup" created with Table partitioning.';
GO

-- ── Step 5: Add tables to the stream group ──────────────────────────────────
-- We stream all five tables. The high-change-rate tables (LiveTiming,
-- PitStops, RaceControl) are the most interesting for real-time consumers.
-- Drivers and Races are low-change but useful for reference data sync.

-- Reference tables (include old values so consumers can see what changed)
EXEC sys.sp_add_object_to_event_stream_group
    N'F1RaceStreamGroup', N'dbo.Drivers',
    @include_old_values = 1, @include_all_columns = 1;
GO

EXEC sys.sp_add_object_to_event_stream_group
    N'F1RaceStreamGroup', N'dbo.Races',
    @include_old_values = 1, @include_all_columns = 1;
GO

-- High-frequency operational tables
EXEC sys.sp_add_object_to_event_stream_group
    N'F1RaceStreamGroup', N'dbo.LiveTiming',
    @include_old_values = 1, @include_all_columns = 1;
GO

EXEC sys.sp_add_object_to_event_stream_group
    N'F1RaceStreamGroup', N'dbo.PitStops',
    @include_old_values = 0, @include_all_columns = 1;
    -- No old values for inserts-only table (pit stops are append-only)
GO

EXEC sys.sp_add_object_to_event_stream_group
    N'F1RaceStreamGroup', N'dbo.RaceControl',
    @include_old_values = 0, @include_all_columns = 1;
GO

PRINT 'All 5 tables added to the F1RaceStreamGroup.';
PRINT '';
PRINT '=== CES is now active. Any INSERTs, UPDATEs, or DELETEs to these ===';
PRINT '=== tables will be streamed to Azure Event Hubs in near real-time. ===';
GO
