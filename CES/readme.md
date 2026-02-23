# Formula 1 Race Operations — SQL Server 2025 Change Event Streaming Demo

## Overview

This demo showcases **Change Event Streaming (CES)** in SQL Server 2025 using a realistic Formula 1 race operations scenario. A team's race engineering database tracks live timing, pit stops, tire strategy, and race control incidents during a Grand Prix weekend. CES streams every data change in near real-time to Azure Event Hubs, where downstream consumers — live dashboards, strategy tools, broadcast overlays — can react instantly.

### Why F1?

Formula 1 is a perfect fit for CES because race operations are inherently **event-driven**:

- A pit stop INSERT triggers the strategy wall's tire-life model to recalculate.
- A race control UPDATE (safety car deployed) must reach every team's dashboard within seconds.
- Position changes from timing transponders flow continuously and feed live broadcast graphics.

Traditional CDC (polling-based) adds unacceptable latency in this kind of scenario. CES pushes changes the moment they hit the transaction log.

## Architecture

```
┌──────────────────────────────────┐
│   SQL Server 2025                │
│   Database: F1RaceOps            │
│                                  │
│   Tables:                        │
│    ├─ Drivers                    │
│    ├─ Races                      │
│    ├─ LiveTiming                 │
│    ├─ PitStops                   │
│    └─ RaceControl                │
│                                  │
│   CES reads transaction log ───────────┐
│   and streams CloudEvents        │     │
└──────────────────────────────────┘     │
                                         ▼
                              ┌─────────────────────┐
                              │  Azure Event Hubs    │
                              │  (f1-race-events)    │
                              └──────────┬──────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    ▼                    ▼                    ▼
            ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
            │  Strategy    │   │  Broadcast   │   │  Data Lake / │
            │  Dashboard   │   │  Overlay     │   │  Analytics   │
            │  (Console)   │   │  System      │   │  Pipeline    │
            └──────────────┘   └──────────────┘   └──────────────┘
```

## Prerequisites

1. **SQL Server 2025** (CTP 2.1 or later) on Windows
2. **Azure subscription** with:
   - Azure Event Hubs namespace (Standard tier or higher)
   - An Event Hub instance (e.g., `f1-race-events`)
   - A Shared Access Policy with **Send** permission and a generated SAS token
3. **SSMS** or **Azure Data Studio** for running the SQL scripts
4. **.NET 8 SDK** (for the consumer application)
5. **PowerShell** with `Az` and `Az.EventHub` modules (for SAS token generation)

## Demo Files

| File | Purpose |
|------|---------|
| `01_create_database.sql` | Creates the `F1RaceOps` database and enables the CES preview feature |
| `02_create_tables.sql` | Creates the F1 schema: Drivers, Races, LiveTiming, PitStops, RaceControl |
| `03_seed_reference_data.sql` | Inserts the 2025 driver grid and a sample race (Monaco GP) |
| `04_configure_ces.sql` | Creates the credential, enables CES, creates the event stream group, and adds tables |
| `05_simulate_race.sql` | Simulates a live race session: position updates, pit stops, safety cars, and flag changes |
| `06_verify_ces.sql` | Queries CES diagnostic DMVs to confirm streaming is active and healthy |
| `07_cleanup.sql` | Tears down CES configuration and drops the database |
| `consumer/` | .NET 8 console app that reads CloudEvents from Event Hubs and displays them |

## Step-by-Step Demo

### Step 1: Create the Database

Open `01_create_database.sql` in SSMS. This creates the `F1RaceOps` database and enables the preview feature flag required for CES.

### Step 2: Create Tables

Run `02_create_tables.sql` to create the five core tables. These represent a simplified but realistic F1 operations data model.

### Step 3: Seed Reference Data

Run `03_seed_reference_data.sql` to populate the driver grid and set up the Monaco Grand Prix. **Important:** CES only streams changes made *after* it is enabled, so this seed data will not appear in the event stream — this is by design.

### Step 4: Configure CES

Edit `04_configure_ces.sql` and replace the placeholder values:

- `<YourEventHubsNamespace>` — your Event Hubs namespace (e.g., `f1racing-ns`)
- `<YourEventHubsInstance>` — your Event Hub name (e.g., `f1-race-events`)
- `<YourSASToken>` — the full SAS token starting with `SharedAccessSignature sr=...`

Then run the script. This enables CES on the database, creates the event stream group with `Table` partitioning (so pit stops and timing data land in separate partitions), and adds all five tables.

### Step 5: Start the Consumer (side-by-side)

Open a terminal and start the consumer app:

```bash
cd consumer
dotnet run
```

Tile the console window next to SSMS so you can see events arrive as you generate them.

### Step 6: Simulate a Race

Run `05_simulate_race.sql` **one section at a time** (separated by comments). Watch the consumer window as events appear for:

- **Formation lap** — initial position INSERTs for all 20 drivers
- **Lap-by-lap updates** — UPDATEs to LiveTiming with new sector times and positions
- **Pit stops** — INSERTs into PitStops triggering tire compound changes
- **Safety car** — RaceControl INSERT, followed by position freeze UPDATEs
- **Race finish** — final classification UPDATEs

### Step 7: Verify and Observe

Run `06_verify_ces.sql` to check the CES diagnostic views and confirm healthy streaming.

### Step 8: Cleanup

Run `07_cleanup.sql` when you're done to remove CES configuration and drop the database.

## CloudEvent Payload Example

When a pit stop is inserted, the consumer receives a CloudEvent like this:

```json
{
  "specversion": "1.0",
  "id": "a1b2c3d4-...",
  "source": "sqlserver://myserver/F1RaceOps",
  "type": "Microsoft.SQL.ChangeEvent",
  "time": "2025-05-25T14:23:17.123Z",
  "data": {
    "schema": "dbo",
    "table": "PitStops",
    "operation": "INS",
    "columns": {
      "PitStopId": 42,
      "RaceId": 1,
      "DriverId": 1,
      "Lap": 22,
      "PitStopDurationMs": 2340,
      "TireCompoundIn": "Soft",
      "TireCompoundOut": "Hard",
      "StopNumber": 1,
      "PitStopTimestamp": "2025-05-25T14:23:16.000Z"
    }
  }
}
```

## Notes and Limitations

- CES is a **preview feature** in SQL Server 2025 and requires the database-scoped preview configuration flag.
- CES does **not** stream pre-existing data. Only INSERTs, UPDATEs, and DELETEs made after CES is enabled are captured.
- CES cannot coexist with CDC or transactional replication on the same database.
- The database must use the **full recovery model**.
- CES currently supports **Azure Event Hubs** as the only destination (AMQP or Kafka protocol).
- One table can belong to only one stream group.
