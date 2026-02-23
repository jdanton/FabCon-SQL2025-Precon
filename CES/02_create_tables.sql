-- ============================================================================
-- 02_create_tables.sql
-- Creates the F1 race operations schema.
--
-- Tables:
--   Drivers       - The 20-driver grid (reference data)
--   Races         - Grand Prix events (reference data)
--   LiveTiming    - Real-time position and sector times per driver per lap
--   PitStops      - Pit stop events with tire compound changes
--   RaceControl   - Race director messages (flags, safety car, penalties)
-- ============================================================================

USE F1RaceOps;
GO

-- ── Reference Tables ────────────────────────────────────────────────────────

CREATE TABLE dbo.Drivers
(
    DriverId        INT             NOT NULL PRIMARY KEY,
    DriverCode      CHAR(3)         NOT NULL,   -- e.g. VER, NOR, LEC
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    TeamName        NVARCHAR(100)   NOT NULL,
    CarNumber       INT             NOT NULL,
    CONSTRAINT UQ_Drivers_Code UNIQUE (DriverCode),
    CONSTRAINT UQ_Drivers_CarNumber UNIQUE (CarNumber)
);
GO

CREATE TABLE dbo.Races
(
    RaceId          INT             NOT NULL PRIMARY KEY,
    RaceName        NVARCHAR(100)   NOT NULL,
    CircuitName     NVARCHAR(100)   NOT NULL,
    Country         NVARCHAR(50)    NOT NULL,
    TotalLaps       INT             NOT NULL,
    RaceDate        DATE            NOT NULL,
    RaceStatus      NVARCHAR(20)    NOT NULL DEFAULT 'Scheduled'
        -- Scheduled, Formation, Green, YellowFlag, SafetyCar, VSC, RedFlag, Finished
);
GO

-- ── Streaming Tables (high-change-rate, streamed via CES) ───────────────────

CREATE TABLE dbo.LiveTiming
(
    TimingId        INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    RaceId          INT             NOT NULL REFERENCES dbo.Races(RaceId),
    DriverId        INT             NOT NULL REFERENCES dbo.Drivers(DriverId),
    Lap             INT             NOT NULL,
    Position        INT             NOT NULL,
    Sector1Ms       INT             NULL,       -- Sector 1 time in milliseconds
    Sector2Ms       INT             NULL,       -- Sector 2 time in milliseconds
    Sector3Ms       INT             NULL,       -- Sector 3 time in milliseconds
    LapTimeMs       INT             NULL,       -- Total lap time in milliseconds
    GapToLeaderMs   INT             NULL,       -- Gap to P1 in milliseconds
    TireCompound    NVARCHAR(10)    NOT NULL,   -- Soft, Medium, Hard, Intermediate, Wet
    TireAge         INT             NOT NULL DEFAULT 0,  -- Laps on current set
    DRS             BIT             NOT NULL DEFAULT 0,  -- DRS enabled
    InPit           BIT             NOT NULL DEFAULT 0,  -- Currently in pit lane
    IsActive        BIT             NOT NULL DEFAULT 1,  -- Still racing (0 = retired/DNF)
    TimingTimestamp  DATETIME2(3)   NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_LiveTiming_RaceDriverLap UNIQUE (RaceId, DriverId, Lap)
);
GO

CREATE TABLE dbo.PitStops
(
    PitStopId           INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    RaceId              INT             NOT NULL REFERENCES dbo.Races(RaceId),
    DriverId            INT             NOT NULL REFERENCES dbo.Drivers(DriverId),
    Lap                 INT             NOT NULL,
    StopNumber          INT             NOT NULL,   -- 1st stop, 2nd stop, etc.
    PitStopDurationMs   INT             NOT NULL,   -- Time stationary in ms
    TireCompoundIn      NVARCHAR(10)    NOT NULL,   -- Tire coming off
    TireCompoundOut     NVARCHAR(10)    NOT NULL,   -- Tire going on
    FrontWingChange     BIT             NOT NULL DEFAULT 0,
    Notes               NVARCHAR(200)   NULL,
    PitStopTimestamp    DATETIME2(3)    NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.RaceControl
(
    MessageId       INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    RaceId          INT             NOT NULL REFERENCES dbo.Races(RaceId),
    Lap             INT             NULL,
    MessageType     NVARCHAR(30)    NOT NULL,
    -- Flag, SafetyCar, VSC, RedFlag, Penalty, TrackLimits, BlueFlag, DRSEnabled, DRSDisabled
    Category        NVARCHAR(30)    NOT NULL DEFAULT 'Informational',
    -- Safety, Infringement, Procedural, Informational
    DriverId        INT             NULL REFERENCES dbo.Drivers(DriverId),  -- NULL = applies to all
    Description     NVARCHAR(500)   NOT NULL,
    MessageTimestamp DATETIME2(3)   NOT NULL DEFAULT SYSDATETIME()
);
GO

-- Indexes for common query patterns
CREATE NONCLUSTERED INDEX IX_LiveTiming_RaceLap ON dbo.LiveTiming (RaceId, Lap, Position);
CREATE NONCLUSTERED INDEX IX_PitStops_RaceDriver ON dbo.PitStops (RaceId, DriverId);
CREATE NONCLUSTERED INDEX IX_RaceControl_RaceLap ON dbo.RaceControl (RaceId, Lap);
GO

PRINT 'F1 race operations tables created successfully.';
GO
