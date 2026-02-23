-- ============================================================================
-- 03_seed_reference_data.sql
-- Populates the 2025 driver grid and creates the Monaco Grand Prix event.
--
-- NOTE: This data is inserted BEFORE CES is enabled. CES only streams
-- changes made after it is turned on, so this seed data will NOT appear
-- in the event stream. This is expected and by design.
-- ============================================================================

USE F1RaceOps;
GO

-- ── 2025 Driver Grid ────────────────────────────────────────────────────────

INSERT INTO dbo.Drivers (DriverId, DriverCode, FirstName, LastName, TeamName, CarNumber)
VALUES
    -- Red Bull Racing
    ( 1, 'VER', 'Max',       'Verstappen',   'Red Bull Racing',         1),
    ( 2, 'LAW', 'Liam',      'Lawson',       'Red Bull Racing',        30),
    -- McLaren
    ( 3, 'NOR', 'Lando',     'Norris',       'McLaren',                 4),
    ( 4, 'PIA', 'Oscar',     'Piastri',      'McLaren',                81),
    -- Ferrari
    ( 5, 'HAM', 'Lewis',     'Hamilton',     'Ferrari',                44),
    ( 6, 'LEC', 'Charles',   'Leclerc',      'Ferrari',                16),
    -- Mercedes
    ( 7, 'RUS', 'George',    'Russell',      'Mercedes',               63),
    ( 8, 'ANT', 'Kimi',      'Antonelli',    'Mercedes',               12),
    -- Aston Martin
    ( 9, 'ALO', 'Fernando',  'Alonso',       'Aston Martin',           14),
    (10, 'STR', 'Lance',     'Stroll',       'Aston Martin',           18),
    -- Alpine
    (11, 'GAS', 'Pierre',    'Gasly',        'Alpine',                 10),
    (12, 'DOO', 'Jack',      'Doohan',       'Alpine',                  7),
    -- Haas
    (13, 'OCO', 'Esteban',   'Ocon',         'Haas',                   31),
    (14, 'BEA', 'Oliver',    'Bearman',      'Haas',                   87),
    -- RB (Visa Cash App RB)
    (15, 'TSU', 'Yuki',      'Tsunoda',      'RB',                     22),
    (16, 'HAD', 'Isack',     'Hadjar',       'RB',                      6),
    -- Williams
    (17, 'ALB', 'Alex',      'Albon',        'Williams',               23),
    (18, 'SAI', 'Carlos',    'Sainz',        'Williams',               55),
    -- Sauber (Audi)
    (19, 'HUL', 'Nico',      'Hulkenberg',   'Sauber',                 27),
    (20, 'BOR', 'Gabriel',   'Bortoleto',    'Sauber',                  5);
GO

-- ── Monaco Grand Prix ───────────────────────────────────────────────────────

INSERT INTO dbo.Races (RaceId, RaceName, CircuitName, Country, TotalLaps, RaceDate, RaceStatus)
VALUES (1, 'Monaco Grand Prix', 'Circuit de Monaco', 'Monaco', 78, '2025-05-25', 'Scheduled');
GO

PRINT 'Reference data seeded: 20 drivers, 1 race (Monaco GP).';
PRINT 'Remember: CES has not been enabled yet. This data will NOT be streamed.';
GO
