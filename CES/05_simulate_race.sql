-- ============================================================================
-- 05_simulate_race.sql
-- Simulates a live Monaco Grand Prix with realistic race events.
--
-- Run each section one at a time (separated by "-- ═══" banners) while
-- watching the consumer app. Pause between sections to observe the
-- CloudEvents arriving in near real-time.
-- ============================================================================

USE F1RaceOps;
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 1: LIGHTS OUT — Race Start (Formation Lap / Lap 0)
-- This generates 20 INSERT events into LiveTiming — one per driver.
-- The consumer should show a burst of INS events for dbo.LiveTiming.
-- Also updates the Race status from 'Scheduled' to 'Green'.
-- ═══════════════════════════════════════════════════════════════════════════

-- Race goes green
UPDATE dbo.Races SET RaceStatus = 'Green' WHERE RaceId = 1;

-- Race control: Lights out message
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 0, 'Flag', 'Procedural', 'LIGHTS OUT AND AWAY WE GO!');

-- Lap 0 grid positions (qualifying order) — all on their starting tires
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 0,  1, 'Soft',   0, 0),   -- LEC P1 (home hero pole)
    (1,  5, 0,  2, 'Soft',   0, 0),   -- HAM P2
    (1,  1, 0,  3, 'Medium', 0, 0),   -- VER P3 (bold strategy: start on mediums)
    (1,  3, 0,  4, 'Soft',   0, 0),   -- NOR P4
    (1,  4, 0,  5, 'Soft',   0, 0),   -- PIA P5
    (1,  7, 0,  6, 'Medium', 0, 0),   -- RUS P6
    (1,  9, 0,  7, 'Soft',   0, 0),   -- ALO P7
    (1,  8, 0,  8, 'Soft',   0, 0),   -- ANT P8
    (1, 18, 0,  9, 'Medium', 0, 0),   -- SAI P9
    (1, 15, 0, 10, 'Soft',   0, 0),   -- TSU P10
    (1, 11, 0, 11, 'Medium', 0, 0),   -- GAS P11
    (1, 10, 0, 12, 'Hard',   0, 0),   -- STR P12 (aggressive undercut strategy)
    (1, 17, 0, 13, 'Medium', 0, 0),   -- ALB P13
    (1, 13, 0, 14, 'Medium', 0, 0),   -- OCO P14
    (1, 14, 0, 15, 'Hard',   0, 0),   -- BEA P15
    (1,  2, 0, 16, 'Medium', 0, 0),   -- LAW P16
    (1, 16, 0, 17, 'Hard',   0, 0),   -- HAD P17
    (1, 12, 0, 18, 'Medium', 0, 0),   -- DOO P18
    (1, 19, 0, 19, 'Hard',   0, 0),   -- HUL P19
    (1, 20, 0, 20, 'Hard',   0, 0);   -- BOR P20
GO

PRINT '>>> SECTION 1 COMPLETE: Race started. 20 drivers on the grid.';
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 2: EARLY LAPS (Laps 1-5) — Position Updates
-- These are UPDATEs to existing timing rows and new lap INSERTs.
-- Watch for the old/new value comparison in the consumer for position swaps.
-- ═══════════════════════════════════════════════════════════════════════════

-- DRS enabled after 2 laps
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 2, 'DRSEnabled', 'Procedural', 'DRS enabled');

-- Lap 1 — Verstappen makes a move on Hamilton into Sainte Devote!
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 1,  1, 19234, 33456, 20112, 72802,     0, 'Soft',   1, 0),  -- LEC leads
    (1,  1, 1,  2, 19301, 33512, 20198, 73011,   209, 'Medium', 1, 0),  -- VER up to P2!
    (1,  5, 1,  3, 19445, 33601, 20267, 73313,   511, 'Soft',   1, 0),  -- HAM drops to P3
    (1,  3, 1,  4, 19502, 33678, 20301, 73481,   679, 'Soft',   1, 0),  -- NOR P4
    (1,  4, 1,  5, 19567, 33712, 20345, 73624,   822, 'Soft',   1, 0);  -- PIA P5

-- Lap 3 — Leclerc sets fastest lap, Verstappen within DRS
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 3,  1, 18987, 33201, 19945, 72133,     0, 'Soft',   3, 0),  -- LEC fastest lap!
    (1,  1, 3,  2, 19012, 33245, 19978, 72235,   102, 'Medium', 3, 1),  -- VER DRS active
    (1,  5, 3,  3, 19145, 33389, 20067, 72601,   468, 'Soft',   3, 0),  -- HAM P3
    (1,  3, 3,  4, 19201, 33423, 20112, 72736,   603, 'Soft',   3, 0);  -- NOR P4

-- Lap 5 — Track limits warning for Piastri
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 5, 'TrackLimits', 'Infringement', 4,
        'Car 81 (PIA) - Track limits warning at Turn 10 (2 of 3 allowed)');
GO

PRINT '>>> SECTION 2 COMPLETE: Early laps. VER up to P2, LEC leading.';
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 3: PIT STOP WINDOW OPENS (Laps 18-25)
-- First pit stops. Watch for INSERTs into PitStops and the corresponding
-- UPDATEs to LiveTiming showing tire compound changes and InPit = 1.
-- ═══════════════════════════════════════════════════════════════════════════

-- Norris pits first (lap 18) — soft to hard
INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 3, 18, 1, 2456, 'Soft', 'Hard', 'Clean stop. Undercut attempt on HAM.');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 3, 18, 10, 19102, 33445, 28901, 81448, 12340, 'Hard', 0, 1, 0);  -- NOR in pit, drops to P10

-- Hamilton pits (lap 20) — soft to medium
INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 5, 20, 1, 2312, 'Soft', 'Medium', 'Covering Norris. Good stop by Ferrari.');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 5, 20, 8, 19067, 33401, 29112, 81580, 15670, 'Medium', 0, 1, 0);  -- HAM drops to P8

-- Leclerc pits (lap 22) — soft to hard, comes out ahead of Hamilton!
INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 6, 22, 1, 2198, 'Soft', 'Hard', 'GREAT stop! 2.1 seconds. Leclerc retains lead after stops.');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 6, 22, 1, 18945, 33112, 28456, 80513, 0, 'Hard', 0, 1, 0);  -- LEC still P1 after stop!

-- Verstappen stays out! (has not pitted — extending medium stint)
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES (1, 1, 22, 1, 18834, 33089, 19912, 71835, 0, 'Medium', 22, 0);  -- VER leads on track!

-- Race control notes Verstappen leading on track (but LEC leads on adjusted time)
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 22, 'Flag', 'Informational', 'Verstappen (VER) leads on track. Has not pitted. Leclerc (LEC) leads on adjusted strategy.');
GO

PRINT '>>> SECTION 3 COMPLETE: Pit window open. LEC leads on strategy, VER still out.';
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 4: SAFETY CAR! (Lap 30)
-- Stroll crashes at the Swimming Pool chicane. Safety Car deployed.
-- This triggers a burst of events: RaceControl INSERT, Race status UPDATE,
-- and position-freeze UPDATEs across the field.
-- ═══════════════════════════════════════════════════════════════════════════

-- Stroll crashes
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 30, 'Flag', 'Safety', 10,
        'Car 18 (STR) crashed at Swimming Pool chicane. Car in barriers. Driver OK.');

-- Safety car deployed
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 30, 'SafetyCar', 'Safety', 'SAFETY CAR DEPLOYED');

-- DRS disabled
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 30, 'DRSDisabled', 'Procedural', 'DRS disabled');

-- Update race status
UPDATE dbo.Races SET RaceStatus = 'SafetyCar' WHERE RaceId = 1;

-- Stroll retires
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, TireCompound, TireAge, IsActive)
VALUES (1, 10, 30, 20, 'Hard', 30, 0);  -- STR DNF

-- Verstappen dives into the pits under Safety Car — FREE stop!
INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 1, 30, 1, 2567, 'Medium', 'Soft', 'Pits under Safety Car. Free stop! Fresh softs for the restart.');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 1, 30, 2, 22345, 38901, 25678, 86924, 800, 'Soft', 0, 1, 0);  -- VER pits, stays P2!

-- Field bunches up behind safety car (compressed gaps)
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  6, 30,  1, 86012,    0, 'Hard',   8, 0),   -- LEC P1
    (1,  5, 30,  3, 86234, 1200, 'Medium', 10, 0),   -- HAM P3
    (1,  3, 30,  4, 86345, 1600, 'Hard',  12, 0),   -- NOR P4
    (1,  4, 30,  5, 86456, 2000, 'Hard',  12, 0),   -- PIA P5
    (1,  7, 30,  6, 86567, 2400, 'Medium', 10, 0);   -- RUS P6
GO

PRINT '>>> SECTION 4 COMPLETE: Safety Car! Stroll crashes. Verstappen gets free pit stop.';
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 5: SAFETY CAR RESTART (Lap 34) — Green Flag Racing
-- The restart is always dramatic. Verstappen on fresh softs attacks Leclerc.
-- ═══════════════════════════════════════════════════════════════════════════

-- Safety car in, green flag
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 34, 'Flag', 'Procedural', 'SAFETY CAR IN THIS LAP. GREEN FLAG.');

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 34, 'DRSEnabled', 'Procedural', 'DRS enabled');

UPDATE dbo.Races SET RaceStatus = 'Green' WHERE RaceId = 1;

-- Lap 34 restart — Verstappen PASSES Leclerc into Sainte Devote!
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  1, 34,  1, 18756, 32945, 19834, 71535,    0, 'Soft',   4, 0),  -- VER TAKES THE LEAD!
    (1,  6, 34,  2, 18912, 33089, 19978, 71979,  444, 'Hard',  12, 0),  -- LEC drops to P2
    (1,  5, 34,  3, 19023, 33201, 20045, 72269,  734, 'Medium', 14, 0),  -- HAM P3
    (1,  3, 34,  4, 19078, 33267, 20089, 72434,  899, 'Hard',  16, 0);  -- NOR P4

-- Blue flag for backmarker
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 36, 'BlueFlag', 'Procedural', 20,
        'Blue flag shown to Car 5 (BOR). Yield to leader.');
GO

PRINT '>>> SECTION 5 COMPLETE: Verstappen takes the lead on the restart!';
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 6: LATE-RACE DRAMA (Laps 60-70)
-- Second pit stops and a penalty for Hamilton.
-- ═══════════════════════════════════════════════════════════════════════════

-- Hamilton gets a 5-second penalty for forcing Piastri off track
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 62, 'Penalty', 'Infringement', 5,
        'Car 44 (HAM) - 5 second time penalty - Causing a collision with Car 81 (PIA) at Rascasse.');

-- Leclerc pits again (lap 65) — needs fresh tires to attack Verstappen
INSERT INTO dbo.PitStops (RaceId, DriverId, Lap, StopNumber, PitStopDurationMs, TireCompoundIn, TireCompoundOut, Notes)
VALUES (1, 6, 65, 2, 2278, 'Hard', 'Soft', 'Second stop. Going for fastest lap and the win.');

INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, InPit, DRS)
VALUES (1, 6, 65, 3, 19012, 33156, 28789, 80957, 8900, 'Soft', 0, 1, 0);  -- LEC drops to P3 after stop

-- Verstappen responds — his softs are 35 laps old now, pushing hard
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES (1, 1, 67, 1, 19123, 33345, 20234, 72702, 0, 'Soft', 37, 0);  -- VER managing tires

-- Leclerc on fresh softs is FLYING — fastest lap!
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES (1, 6, 67, 3, 18678, 32901, 19756, 71335, 6200, 'Soft', 2, 1);  -- LEC FASTEST LAP

INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, DriverId, Description)
VALUES (1, 67, 'Flag', 'Informational', 6,
        'Fastest lap: Car 16 (LEC) - 1:11.335');
GO

PRINT '>>> SECTION 6 COMPLETE: Penalty for HAM. LEC on fresh rubber closing in.';
GO


-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 7: CHEQUERED FLAG (Lap 78) — Final Classification
-- The race finishes. Final position UPDATEs for all drivers.
-- ═══════════════════════════════════════════════════════════════════════════

-- Final lap timing — Verstappen holds on!
INSERT INTO dbo.LiveTiming (RaceId, DriverId, Lap, Position, Sector1Ms, Sector2Ms, Sector3Ms, LapTimeMs, GapToLeaderMs, TireCompound, TireAge, DRS)
VALUES
    (1,  1, 78,  1, 19234, 33456, 20178, 72868,     0, 'Soft',  48, 0),  -- VER WINS!
    (1,  6, 78,  2, 19112, 33234, 19989, 72335,  1245, 'Soft',  13, 1),  -- LEC P2 (fastest lap)
    (1,  3, 78,  3, 19345, 33567, 20234, 73146,  8934, 'Hard',  60, 0),  -- NOR P3
    (1,  5, 78,  4, 19456, 33678, 20345, 73479, 14567, 'Medium', 48, 0),  -- HAM P4 (+5s penalty applied)
    (1,  4, 78,  5, 19512, 33712, 20389, 73613, 18234, 'Hard',  60, 0),  -- PIA P5
    (1,  7, 78,  6, 19567, 33789, 20423, 73779, 22456, 'Medium', 48, 0),  -- RUS P6
    (1,  9, 78,  7, 19623, 33845, 20467, 73935, 28901, 'Hard',  56, 0),  -- ALO P7
    (1,  8, 78,  8, 19678, 33901, 20512, 74091, 34567, 'Medium', 44, 0),  -- ANT P8
    (1, 18, 78,  9, 19734, 33956, 20556, 74246, 41234, 'Hard',  60, 0),  -- SAI P9
    (1, 15, 78, 10, 19789, 34012, 20601, 74402, 48901, 'Medium', 40, 0); -- TSU P10 (last points)

-- Chequered flag
INSERT INTO dbo.RaceControl (RaceId, Lap, MessageType, Category, Description)
VALUES (1, 78, 'Flag', 'Procedural', 'CHEQUERED FLAG. Verstappen wins the Monaco Grand Prix!');

-- Race finished
UPDATE dbo.Races SET RaceStatus = 'Finished' WHERE RaceId = 1;
GO

PRINT '>>> SECTION 7 COMPLETE: CHEQUERED FLAG! Verstappen wins Monaco!';
PRINT '';
PRINT 'Demo complete. Check the consumer app for the full event stream.';
PRINT 'Run 06_verify_ces.sql to check CES health and diagnostics.';
GO
