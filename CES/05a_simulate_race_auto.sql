-- ============================================================================
-- 05a_simulate_race_auto.sql
-- AUTO-RUNNING version of the Monaco GP simulation (~5 minutes total).
--
-- Launch this script and let it run in the background while showing
-- the GUI consumer app to the audience. WAITFOR DELAY commands space
-- the sections across roughly 5 minutes for a natural demo pace.
--
-- Usage: Just press F5 / Execute and walk away.
-- ============================================================================

USE F1RaceOps;
GO

PRINT '>>> AUTO-RUN MODE: Race simulation will take ~5 minutes.';
PRINT '>>> Switch to the consumer app to watch events arrive.';
PRINT '';
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 1: LIGHTS OUT — Race Start (0:00)
-- ═══════════════════════════════════════════════════════════════════════════

UPDATE dbo.Races SET RaceStatus = 'Green' WHERE RaceId = 1;

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 0, 'Flag', 'Procedural', 'LIGHTS OUT AND AWAY WE GO!');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 0,  1, 'Soft',   0, 0),
    (1,  5, 0,  2, 'Soft',   0, 0),
    (1,  1, 0,  3, 'Medium', 0, 0),
    (1,  3, 0,  4, 'Soft',   0, 0),
    (1,  4, 0,  5, 'Soft',   0, 0),
    (1,  7, 0,  6, 'Medium', 0, 0),
    (1,  9, 0,  7, 'Soft',   0, 0),
    (1,  8, 0,  8, 'Soft',   0, 0),
    (1, 18, 0,  9, 'Medium', 0, 0),
    (1, 15, 0, 10, 'Soft',   0, 0),
    (1, 11, 0, 11, 'Medium', 0, 0),
    (1, 10, 0, 12, 'Hard',   0, 0),
    (1, 17, 0, 13, 'Medium', 0, 0),
    (1, 13, 0, 14, 'Medium', 0, 0),
    (1, 14, 0, 15, 'Hard',   0, 0),
    (1,  2, 0, 16, 'Medium', 0, 0),
    (1, 16, 0, 17, 'Hard',   0, 0),
    (1, 12, 0, 18, 'Medium', 0, 0),
    (1, 19, 0, 19, 'Hard',   0, 0),
    (1, 20, 0, 20, 'Hard',   0, 0);
GO

PRINT '>>> [0:00] SECTION 1: Race started. 20 drivers on the grid.';
PRINT '>>> Waiting 30 seconds...';
WAITFOR DELAY '00:00:30';
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 2: EARLY LAPS (0:30)
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 2, 'DRSEnabled', 'Procedural', 'DRS enabled');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 1,  1, 19234, 33456, 20112, 72802,     0, 'Soft',   1, 0),
    (1,  1, 1,  2, 19301, 33512, 20198, 73011,   209, 'Medium', 1, 0),
    (1,  5, 1,  3, 19445, 33601, 20267, 73313,   511, 'Soft',   1, 0),
    (1,  3, 1,  4, 19502, 33678, 20301, 73481,   679, 'Soft',   1, 0),
    (1,  4, 1,  5, 19567, 33712, 20345, 73624,   822, 'Soft',   1, 0);

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 3,  1, 18987, 33201, 19945, 72133,     0, 'Soft',   3, 0),
    (1,  1, 3,  2, 19012, 33245, 19978, 72235,   102, 'Medium', 3, 1),
    (1,  5, 3,  3, 19145, 33389, 20067, 72601,   468, 'Soft',   3, 0),
    (1,  3, 3,  4, 19201, 33423, 20112, 72736,   603, 'Soft',   3, 0);

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 5, 'TrackLimits', 'Infringement', 4,
        'Car 81 (PIA) - Track limits warning at Turn 10 (2 of 3 allowed)');
GO

PRINT '>>> [0:30] SECTION 2: Early laps. VER up to P2, LEC leading.';
PRINT '>>> Waiting 45 seconds...';
WAITFOR DELAY '00:00:45';
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 3: PIT STOP WINDOW (1:15)
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 3, 18, 1, 2456, 'Soft', 'Hard', 'Clean stop. Undercut attempt on HAM.');
GO
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 3, 18, 10, 19102, 33445, 28901, 81448, 12340, 'Hard', 0, 1, 0);
GO

WAITFOR DELAY '00:00:10';

INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 5, 20, 1, 2312, 'Soft', 'Medium', 'Covering Norris. Good stop by Ferrari.');
GO
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 5, 20, 8, 19067, 33401, 29112, 81580, 15670, 'Medium', 0, 1, 0);
GO

WAITFOR DELAY '00:00:10';

INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 6, 22, 1, 2198, 'Soft', 'Hard', 'GREAT stop! 2.1 seconds. Leclerc retains lead after stops.');
GO
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 6, 22, 1, 18945, 33112, 28456, 80513, 0, 'Hard', 0, 1, 0);
GO

WAITFOR DELAY '00:00:10';

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES (1, 1, 22, 1, 18834, 33089, 19912, 71835, 0, 'Medium', 22, 0);

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 22, 'Flag', 'Informational', 'Verstappen (VER) leads on track. Has not pitted. Leclerc (LEC) leads on adjusted strategy.');
GO

PRINT '>>> [1:15] SECTION 3: Pit window. LEC leads on strategy, VER still out.';
PRINT '>>> Waiting 40 seconds...';
WAITFOR DELAY '00:00:15';
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 4: SAFETY CAR! (2:00)
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 30, 'Flag', 'Safety', 10,
        'Car 18 (STR) crashed at Swimming Pool chicane. Car in barriers. Driver OK.');
GO

WAITFOR DELAY '00:00:03';

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 30, 'SafetyCar', 'Safety', 'SAFETY CAR DEPLOYED');

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 30, 'DRSDisabled', 'Procedural', 'DRS disabled');

UPDATE dbo.Races SET RaceStatus = 'SafetyCar' WHERE RaceId = 1;
GO

WAITFOR DELAY '00:00:05';

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, TireCompound, TireAge, IsActive)
VALUES (1, 10, 30, 20, 'Hard', 30, 0);
GO

WAITFOR DELAY '00:00:05';

INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 1, 30, 1, 2567, 'Medium', 'Soft', 'Pits under Safety Car. Free stop! Fresh softs for the restart.');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 1, 30, 2, 22345, 38901, 25678, 86924, 800, 'Soft', 0, 1, 0);

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 30,  1, 86012,    0, 'Hard',   8, 0),
    (1,  5, 30,  3, 86234, 1200, 'Medium', 10, 0),
    (1,  3, 30,  4, 86345, 1600, 'Hard',  12, 0),
    (1,  4, 30,  5, 86456, 2000, 'Hard',  12, 0),
    (1,  7, 30,  6, 86567, 2400, 'Medium', 10, 0);
GO

PRINT '>>> [2:00] SECTION 4: Safety Car! Stroll crashes. VER gets free pit stop.';
PRINT '>>> Waiting 40 seconds...';
WAITFOR DELAY '00:00:27';
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 5: SAFETY CAR RESTART (2:40)
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 34, 'Flag', 'Procedural', 'SAFETY CAR IN THIS LAP. GREEN FLAG.');

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 34, 'DRSEnabled', 'Procedural', 'DRS enabled');

UPDATE dbo.Races SET RaceStatus = 'Green' WHERE RaceId = 1;
GO

WAITFOR DELAY '00:00:05';

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  1, 34,  1, 18756, 32945, 19834, 71535,    0, 'Soft',   4, 0),
    (1,  6, 34,  2, 18912, 33089, 19978, 71979,  444, 'Hard',  12, 0),
    (1,  5, 34,  3, 19023, 33201, 20045, 72269,  734, 'Medium', 14, 0),
    (1,  3, 34,  4, 19078, 33267, 20089, 72434,  899, 'Hard',  16, 0);

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 36, 'BlueFlag', 'Procedural', 20,
        'Blue flag shown to Car 5 (BOR). Yield to leader.');
GO

PRINT '>>> [2:40] SECTION 5: Verstappen takes the lead on the restart!';
PRINT '>>> Waiting 50 seconds...';
WAITFOR DELAY '00:00:40';
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 6: LATE-RACE DRAMA (3:30)
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 62, 'Penalty', 'Infringement', 5,
        'Car 44 (HAM) - 5 second time penalty - Causing a collision with Car 81 (PIA) at Rascasse.');
GO

WAITFOR DELAY '00:00:10';

INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 6, 65, 2, 2278, 'Hard', 'Soft', 'Second stop. Going for fastest lap and the win.');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 6, 65, 3, 19012, 33156, 28789, 80957, 8900, 'Soft', 0, 1, 0);
GO

WAITFOR DELAY '00:00:10';

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES (1, 1, 67, 1, 19123, 33345, 20234, 72702, 0, 'Soft', 37, 0);
GO

WAITFOR DELAY '00:00:10';

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES (1, 6, 67, 3, 18678, 32901, 19756, 71335, 6200, 'Soft', 2, 1);

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 67, 'Flag', 'Informational', 6,
        'Fastest lap: Car 16 (LEC) - 1:11.335');
GO

PRINT '>>> [3:30] SECTION 6: Penalty for HAM. LEC closing on fresh rubber.';
PRINT '>>> Waiting 50 seconds...';
WAITFOR DELAY '00:00:20';
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 7: CHEQUERED FLAG (4:20)
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  1, 78,  1, 19234, 33456, 20178, 72868,     0, 'Soft',  48, 0),
    (1,  6, 78,  2, 19112, 33234, 19989, 72335,  1245, 'Soft',  13, 1),
    (1,  3, 78,  3, 19345, 33567, 20234, 73146,  8934, 'Hard',  60, 0),
    (1,  5, 78,  4, 19456, 33678, 20345, 73479, 14567, 'Medium', 48, 0),
    (1,  4, 78,  5, 19512, 33712, 20389, 73613, 18234, 'Hard',  60, 0),
    (1,  7, 78,  6, 19567, 33789, 20423, 73779, 22456, 'Medium', 48, 0),
    (1,  9, 78,  7, 19623, 33845, 20467, 73935, 28901, 'Hard',  56, 0),
    (1,  8, 78,  8, 19678, 33901, 20512, 74091, 34567, 'Medium', 44, 0),
    (1, 18, 78,  9, 19734, 33956, 20556, 74246, 41234, 'Hard',  60, 0),
    (1, 15, 78, 10, 19789, 34012, 20601, 74402, 48901, 'Medium', 40, 0);
GO

WAITFOR DELAY '00:00:05';

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 78, 'Flag', 'Procedural', 'CHEQUERED FLAG. Verstappen wins the Monaco Grand Prix!');

UPDATE dbo.Races SET RaceStatus = 'Finished' WHERE RaceId = 1;
GO

PRINT '';
PRINT '>>> [~5:00] RACE COMPLETE! Verstappen wins Monaco!';
PRINT '>>> Check the consumer app for the full event stream.';
GO
