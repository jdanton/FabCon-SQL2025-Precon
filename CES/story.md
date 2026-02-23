Here's your complete F1-themed CES demo — 10 files total. The scenario simulates a **Monaco Grand Prix** where CES streams every position change, pit stop, and race control message to Azure Event Hubs in real-time, with an **AI-powered race engineer** that reacts to critical moments.

**The demo flow:**

1. **Scripts 01–03** set up the database, tables (Drivers, Races, LiveTiming, PitStops, RaceControl), and seed the 2025 grid
2. **Script 04** configures CES with `Table` partitioning using **Managed Identity** — no SAS tokens to manage or rotate
3. **Script 05** is the star — run it section by section in SSMS while watching the C# consumer side-by-side. It walks through: lights out → early laps with position battles → pit stop window → a safety car crash → restart overtake → penalties → chequered flag
4. The **consumer app** (`dotnet run`) formats events as a live race feed with color-coded output for pit stops, race control messages, and position changes
5. When critical events occur (safety car, crash, penalty, tire degradation), the **AI race engineer** kicks in — calling Claude to generate a real-time team radio recommendation and sending an alert to Azure Service Bus

**What makes this demo compelling:**

- **Managed Identity everywhere** — SQL Server authenticates to Event Hubs via managed identity, and the consumer uses `DefaultAzureCredential` for Event Hubs, Blob Storage, and Service Bus. Zero secrets in code.
- **AI-augmented event processing** — The race engineer demonstrates how CES events can feed into an AI pipeline for real-time decision support. Claude generates responses in the style of actual F1 team radio, making the demo visually engaging.
- **External notifications** — Service Bus messages represent a real notification pipeline where downstream systems (strategy dashboards, driver communications) could consume the AI recommendations.

The data model is realistic — millisecond sector times, tire compound/age tracking, DRS status, gap-to-leader — and the race narrative (Leclerc on pole at home, Verstappen's bold medium-tire strategy, free pit stop under safety car) gives the demo a story arc that keeps an audience engaged. Each section is designed to show a different CES behavior: burst INSERTs, UPDATEs with old/new values, and the difference between high-frequency streaming tables and reference data tables. The AI race engineer adds a "wow" moment when the safety car triggers a strategic recommendation mid-demo.
