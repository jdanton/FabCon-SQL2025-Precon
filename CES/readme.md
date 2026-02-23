# Formula 1 Race Operations — SQL Server 2025 Change Event Streaming Demo

## Overview

This demo showcases **Change Event Streaming (CES)** in SQL Server 2025 using a realistic Formula 1 race operations scenario. A team's race engineering database tracks live timing, pit stops, tire strategy, and race control incidents during a Grand Prix weekend. CES streams every data change in near real-time to Azure Event Hubs, where a consumer application reacts instantly — including an **AI-powered race engineer** that calls Claude to generate real-time strategic recommendations when unexpected events occur.

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
│   Auth: Managed Identity         │
│   CES reads transaction log ───────────┐
│   and streams CloudEvents        │     │
└──────────────────────────────────┘     │
                                         ▼
                              ┌─────────────────────┐
                              │  Azure Event Hubs    │
                              │  (f1-race-events)    │
                              │  Auth: Managed Id    │
                              └──────────┬──────────┘
                                         │
                                         ▼
                              ┌─────────────────────┐
                              │  C# Event Consumer   │
                              │  (Console App)       │
                              │  Auth: Managed Id /  │
                              │  DefaultAzureCredential
                              └──────────┬──────────┘
                                         │
                           ┌─────────────┼──────────────┐
                           ▼             ▼              ▼
                    ┌────────────┐ ┌──────────┐  ┌─────────────┐
                    │  Live Race │ │ Claude   │  │ Azure       │
                    │  Feed      │ │ AI Race  │  │ Service Bus │
                    │  (Console) │ │ Engineer │  │ (Alerts)    │
                    └────────────┘ └──────────┘  └─────────────┘
```

## Prerequisites

1. **SQL Server 2025** (CTP 2.1 or later) with a **managed identity** (system-assigned or user-assigned) — either Azure SQL, Azure VM, or Azure Arc-enabled SQL Server
2. **Azure subscription** with:
   - **Azure Event Hubs** namespace (Standard tier or higher) with an Event Hub instance (e.g., `f1-race-events`)
   - **Azure Storage Account** for consumer checkpointing
   - **Azure Service Bus** namespace with a queue named `race-engineer-alerts`
3. **Azure RBAC roles** assigned to the appropriate managed identities:
   - SQL Server's identity: **Azure Event Hubs Data Sender** on the Event Hub
   - Consumer app's identity: **Azure Event Hubs Data Receiver** on the Event Hub
   - Consumer app's identity: **Storage Blob Data Contributor** on the storage container
   - Consumer app's identity: **Azure Service Bus Data Sender** on the Service Bus namespace
4. **SSMS** or **Azure Data Studio** for running the SQL scripts
5. **.NET 8 SDK** (for the consumer application)
6. **Anthropic API key** — set as `ANTHROPIC_API_KEY` environment variable (get one at https://console.anthropic.com)

## Demo Files

| File | Purpose |
|------|---------|
| `01_create_database.sql` | Creates the `F1RaceOps` database and enables the CES preview feature |
| `02_create_tables.sql` | Creates the F1 schema: Drivers, Races, LiveTiming, PitStops, RaceControl |
| `03_seed_reference_data.sql` | Inserts the 2025 driver grid and a sample race (Monaco GP) |
| `04_configure_ces.sql` | Creates the managed identity credential, enables CES, creates the event stream group, and adds tables |
| `05_simulate_race.sql` | Simulates a live race session: position updates, pit stops, safety cars, and flag changes |
| `06_verify_ces.sql` | Queries CES diagnostic DMVs to confirm streaming is active and healthy |
| `07_cleanup.sql` | Tears down CES configuration and drops the database |
| `Program.cs` | .NET 8 console app — reads CloudEvents from Event Hubs and displays them as a live race feed |
| `RaceEngineerService.cs` | AI race engineer — detects anomalies, calls Claude for recommendations, sends alerts to Service Bus |
| `F1RaceEventConsumer.csproj` | Project file with Azure SDK and identity packages |

## Step-by-Step Demo

### Step 1: Create the Database

Open `01_create_database.sql` in SSMS. This creates the `F1RaceOps` database and enables the preview feature flag required for CES.

### Step 2: Create Tables

Run `02_create_tables.sql` to create the five core tables. These represent a simplified but realistic F1 operations data model.

### Step 3: Seed Reference Data

Run `03_seed_reference_data.sql` to populate the driver grid and set up the Monaco Grand Prix. **Important:** CES only streams changes made *after* it is enabled, so this seed data will not appear in the event stream — this is by design.

### Step 4: Configure CES

Edit `04_configure_ces.sql` and replace the placeholder values:

- `<YourMasterKeyPassword>` — a strong password for the database master key
- `<YourEventHubsNamespace>` — your Event Hubs namespace (e.g., `f1racing-ns`)
- `<YourEventHubsInstance>` — your Event Hub name (e.g., `f1-race-events`)

Authentication uses **Managed Identity** — no SAS tokens to generate or rotate. The SQL Server's identity must have the **Azure Event Hubs Data Sender** role on the Event Hub.

Then run the script. This enables CES on the database, creates the event stream group with `Table` partitioning (so pit stops and timing data land in separate partitions), and adds all five tables.

### Step 5: Start the Consumer (side-by-side)

First, update the configuration constants in `Program.cs`:

- `EventHubNamespace` — your Event Hubs FQDN (e.g., `f1racing-ns.servicebus.windows.net`)
- `EventHubName` — your Event Hub instance name
- `BlobStorageUrl` — your storage account URL (e.g., `https://f1storage.blob.core.windows.net`)
- `ServiceBusNamespace` — your Service Bus FQDN (e.g., `f1racing-sb.servicebus.windows.net`)

Set your Anthropic API key:

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

Then start the consumer:

```bash
dotnet run
```

Tile the console window next to SSMS so you can see events arrive as you generate them.

### Step 6: Simulate a Race

Run `05_simulate_race.sql` **one section at a time** (separated by comments). Watch the consumer window as events appear for:

- **Formation lap** — initial position INSERTs for all 20 drivers
- **Lap-by-lap updates** — UPDATEs to LiveTiming with new sector times and positions
- **Pit stops** — INSERTs into PitStops triggering tire compound changes
- **Safety car** — RaceControl INSERT, followed by position freeze UPDATEs — **triggers the AI race engineer** with a strategic recommendation
- **Penalty** — Hamilton's 5-second penalty — **triggers the AI race engineer**
- **Tire degradation** — Verstappen on 37-lap-old softs — **triggers the AI race engineer**
- **Race finish** — final classification UPDATEs

When the race engineer triggers, you'll see a boxed **TEAM RADIO** message in the console with Claude's real-time recommendation, and a notification is sent to the `race-engineer-alerts` Service Bus queue.

### Step 7: Verify and Observe

Run `06_verify_ces.sql` to check the CES diagnostic views and confirm healthy streaming.

Check Azure Portal > Service Bus > `race-engineer-alerts` queue to see the AI-generated notifications.

### Step 8: Cleanup

Run `07_cleanup.sql` when you're done to remove CES configuration and drop the database.

## AI Race Engineer — Detection Triggers

The consumer monitors every incoming event and triggers the AI race engineer when it detects:

| Trigger | Detection Rule | Example |
|---------|---------------|---------|
| Safety Car / Red Flag / VSC | Race status changes to `SafetyCar`, `RedFlag`, or `VSC` | Stroll crashes at Swimming Pool chicane (Lap 30) |
| Driver DNF | LiveTiming event with `IsActive = 0` | Stroll retires from the race |
| Penalty | RaceControl message with `MessageType = 'Penalty'` | Hamilton 5-second penalty for collision |
| Tire Degradation | Tire age exceeds compound limit (Soft >25, Medium >35, Hard >50 laps) | Verstappen on 37-lap-old softs |

When triggered, the service:
1. Sends race context to **Claude Haiku** (optimized for low-latency responses)
2. Displays the recommendation as a **TEAM RADIO** message in the console
3. Sends a JSON notification to **Azure Service Bus** for downstream consumers

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

## Authentication

This demo uses **Managed Identity** throughout — no connection strings or SAS tokens to manage:

| Component | Auth Method | Required Role |
|-----------|-------------|---------------|
| SQL Server CES → Event Hubs | Managed Identity (database-scoped credential) | Azure Event Hubs Data Sender |
| Consumer → Event Hubs | DefaultAzureCredential | Azure Event Hubs Data Receiver |
| Consumer → Blob Storage | DefaultAzureCredential | Storage Blob Data Contributor |
| Consumer → Service Bus | DefaultAzureCredential | Azure Service Bus Data Sender |
| Consumer → Claude API | API key (`ANTHROPIC_API_KEY` env var) | N/A |

For local development, `DefaultAzureCredential` falls back to Azure CLI (`az login`) or Visual Studio credentials.

## Notes and Limitations

- CES is a **preview feature** in SQL Server 2025 and requires the database-scoped preview configuration flag.
- CES does **not** stream pre-existing data. Only INSERTs, UPDATEs, and DELETEs made after CES is enabled are captured.
- CES cannot coexist with CDC or transactional replication on the same database.
- The database must use the **full recovery model**.
- CES currently supports **Azure Event Hubs** as the only destination (AMQP or Kafka protocol).
- One table can belong to only one stream group.
- The AI race engineer uses Claude Haiku for low-latency responses (~1-2 seconds). Each triggered event costs approximately 200 input + 200 output tokens.
