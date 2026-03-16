-- =============================================
-- SQL Server 2025: Calling the OpenF1 REST API
-- with sp_invoke_external_rest_endpoint
--
-- OpenF1 is free, open-source, and needs no
-- API key for historical data (2023 onwards).
-- Base URL: https://api.openf1.org/v1
-- Docs:     https://openf1.org/docs
-- =============================================
-- Show advanced options first (if needed)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

-- Then enable the REST endpoint
EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE;
GO
-- =============================================
-- 1. DRIVERS — 2025 season roster from a race
-- =============================================
DECLARE @statusCode INT, @response NVARCHAR(MAX);

EXEC @statusCode = sp_invoke_external_rest_endpoint
    @url     = N'https://api.openf1.org/v1/drivers?session_key=latest',
    @method  = N'GET',
    @headers = N'{"Accept":"application/json"}',
    @timeout = 30,
    @response = @response OUTPUT;

SELECT
    j.driver_number,
    j.full_name,
    j.name_acronym,
    j.team_name,
    j.team_colour
FROM OPENJSON(@response, '$.result')
WITH (
    driver_number   INT            '$.driver_number',
    full_name       NVARCHAR(200)  '$.full_name',
    name_acronym    NVARCHAR(10)   '$.name_acronym',
    team_name       NVARCHAR(200)  '$.team_name',
    team_colour     NVARCHAR(10)   '$.team_colour'
) AS j
ORDER BY j.team_name, j.full_name;
GO

-- =============================================
-- 2. MEETINGS — 2025 race calendar
-- =============================================
DECLARE @statusCode INT, @response NVARCHAR(MAX);

EXEC @statusCode = sp_invoke_external_rest_endpoint
    @url     = N'https://api.openf1.org/v1/meetings?year=2025',
    @method  = N'GET',
    @headers = N'{"Accept":"application/json"}',
    @timeout = 30,
    @response = @response OUTPUT;

SELECT
    j.meeting_key,
    j.meeting_name,
    j.country_name,
    j.location,
    j.circuit_short_name,
    j.date_start,
    j.date_end
FROM OPENJSON(@response, '$.result')
WITH (
    meeting_key         INT            '$.meeting_key',
    meeting_name        NVARCHAR(400)  '$.meeting_name',
    country_name        NVARCHAR(200)  '$.country_name',
    location            NVARCHAR(200)  '$.location',
    circuit_short_name  NVARCHAR(200)  '$.circuit_short_name',
    date_start          NVARCHAR(50)   '$.date_start',
    date_end            NVARCHAR(50)   '$.date_end'
) AS j
ORDER BY j.date_start;
GO

-- =============================================
-- 3. LAPS — Norris (#4) first 5 laps from
--    the 2025 Abu Dhabi GP (session_key 9839)
-- =============================================
DECLARE @statusCode INT, @response NVARCHAR(MAX);

EXEC @statusCode = sp_invoke_external_rest_endpoint
    @url     = N'https://api.openf1.org/v1/laps?session_key=9839&driver_number=4&lap_number<=5',
    @method  = N'GET',
    @headers = N'{"Accept":"application/json"}',
    @timeout = 30,
    @response = @response OUTPUT;

SELECT
    j.lap_number,
    j.lap_duration,
    j.duration_sector_1,
    j.duration_sector_2,
    j.duration_sector_3,
    j.i1_speed,
    j.i2_speed,
    j.st_speed,
    j.is_pit_out_lap
FROM OPENJSON(@response, '$.result')
WITH (
    lap_number         INT            '$.lap_number',
    lap_duration       FLOAT          '$.lap_duration',
    duration_sector_1  FLOAT          '$.duration_sector_1',