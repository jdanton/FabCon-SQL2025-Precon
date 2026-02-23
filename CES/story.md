Here's your complete F1-themed CES demo — 11 files total. The scenario simulates a **Monaco Grand Prix** where CES streams every position change, pit stop, and race control message to Azure Event Hubs in real-time.

**The demo flow:**

1. **Scripts 01–03** set up the database, tables (Drivers, Races, LiveTiming, PitStops, RaceControl), and seed the 2025 grid
2. **Script 04** configures CES with `Table` partitioning — just fill in your Event Hubs namespace and SAS token (the PowerShell script generates one for you)
3. **Script 05** is the star — run it section by section in SSMS while watching the C# consumer side-by-side. It walks through: lights out → early laps with position battles → pit stop window → a safety car crash → restart overtake → penalties → chequered flag
4. The **consumer app** (`dotnet run` in the `consumer/` folder) formats events as a live race feed with color-coded output for pit stops, race control messages, and position changes

The data model is realistic — millisecond sector times, tire compound/age tracking, DRS status, gap-to-leader — and the race narrative (Leclerc on pole at home, Verstappen's bold medium-tire strategy, free pit stop under safety car) gives the demo a story arc that keeps an audience engaged. Each section is designed to show a different CES behavior: burst INSERTs, UPDATEs with old/new values, and the difference between high-frequency streaming tables and reference data tables.