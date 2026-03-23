-- ============================================================================
-- 04_configure_ces.sql
-- Configures Change Event Streaming (CES) on the F1RaceOps database.
--
-- This script is IDEMPOTENT -- safe to re-run without errors.
--
-- This script:
--   1. Creates a database master key (if not exists)
--   2. Creates a managed identity credential for Event Hubs authentication
--   3. Enables CES on the database (if not already enabled)
--   4. Creates an event stream group targeting the Event Hub (if not exists)
--   5. Adds all five tables to the stream group (skips if already added)
--
-- PREREQUISITES:
--   - Scripts 01-03 completed (database, tables, and seed data created)
--   - Azure Event Hubs namespace deployed (via Terraform or manually)
--   - SQL Server VM has a system-assigned managed identity enabled
--   - VM identity has "Azure Event Hubs Data Sender" role on the namespace
--
-- REPLACE BEFORE RUNNING:
--   <YourMasterKeyPassword>    -> a strong password for the database master key
--   <YourEventHubsNamespace>   -> Event Hubs namespace FQDN
--                                (e.g., f1ces-ns-3308.servicebus.windows.net)
--   <YourEventHubsInstance>    -> Event Hub name (e.g., f1-race-events)
-- ============================================================================

USE F1RaceOps;
GO

-- == Step 1: Create the database master key ================================
-- Required for creating database-scoped credentials.

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<YourMasterKeyPassword>';
    PRINT 'Database master key created.';
END
ELSE
    PRINT 'Database master key already exists -- skipping.';
GO

-- == Step 2: Create the managed identity credential ========================
-- CU3+ supports IDENTITY = 'Managed Identity' -- no SAS tokens needed.
-- The SQL Server VM's system-assigned identity authenticates to Event Hubs.

IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = 'EventHubCredential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL EventHubCredential
        WITH IDENTITY = 'Managed Identity';
    PRINT 'Managed identity credential created.';
END
ELSE
    PRINT 'EventHubCredential already exists -- skipping.';
GO

-- == Step 3: Enable Change Event Streaming on the database =================

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = DB_NAME() AND is_event_stream_enabled = 1)
BEGIN
    EXEC sys.sp_enable_event_stream;
    PRINT 'Change Event Streaming enabled on F1RaceOps.';
END
ELSE
    PRINT 'Change Event Streaming already enabled -- skipping.';
GO

-- == Step 4: Create the event stream group =================================
-- Targets the Event Hub via AMQP with Table partitioning so each table gets
-- its own partition -- pit stops, timing data, and race control stay separate.
-- TRY/CATCH handles the case where the group already exists (error 23625).

    BEGIN TRY
        EXEC sys.sp_create_event_stream_group
            @stream_group_name      = N'F1RaceStreamGroup',
            @destination_type       = N'AzureEventHubsAmqp',
            @destination_location   = N'f1ces-ns-3308.servicebus.windows.net/f1-race-events',
            @destination_credential = EventHubCredential,
            @partition_key_scheme   = N'Table';
        PRINT 'Event stream group "F1RaceStreamGroup" created.';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (23625, 23626)
            PRINT 'F1RaceStreamGroup already exists -- skipping.';
        ELSE
            THROW;  -- Re-raise unexpected errors
    END CATCH
    GO

-- == Step 5: Add tables to the stream group ================================
-- All five tables are streamed. Reference tables (Drivers, Races) capture
-- metadata changes; streaming tables (LiveTiming, PitStops, RaceControl)
-- capture the high-frequency race data.
--
-- NOTE: Seed data from script 03 was inserted BEFORE CES was enabled,
-- so it won't appear in the event stream. Only new changes are streamed.
-- Tables with is_replicated = 1 are already in a stream group.
-- sp_add_object_to_event_stream_group uses positional parameters.

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Drivers' AND is_replicated = 1)
    EXEC sys.sp_add_object_to_event_stream_group N'F1RaceStreamGroup', N'dbo.Drivers';

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Races' AND is_replicated = 1)
    EXEC sys.sp_add_object_to_event_stream_group N'F1RaceStreamGroup', N'dbo.Races';

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LiveTiming' AND is_replicated = 1)
    EXEC sys.sp_add_object_to_event_stream_group N'F1RaceStreamGroup', N'dbo.LiveTiming';

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PitStops' AND is_replicated = 1)
    EXEC sys.sp_add_object_to_event_stream_group N'F1RaceStreamGroup', N'dbo.PitStops';

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RaceControl' AND is_replicated = 1)
    EXEC sys.sp_add_object_to_event_stream_group N'F1RaceStreamGroup', N'dbo.RaceControl';
GO

PRINT 'All 5 tables added to F1RaceStreamGroup.';
PRINT '';
PRINT '=== CES configured. ===';
PRINT 'Run 06_verify_ces.sql to confirm streaming is active.';
PRINT 'Start the consumer app (dotnet run) and then run 05_simulate_race.sql.';
GO
