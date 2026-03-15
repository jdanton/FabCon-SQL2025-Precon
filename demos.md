# SQL Server 2025 — Demo Guide

Detailed walkthrough for each demo in the full-day training session. Demos are listed in presentation order.


## DEMO TIMING SUMMARY

| # | Demo | Module | Source | Time | Machine
|---|------|--------|--------|------|----------|
| 1 | Native JSON | 2 - Developers | sql2025book | ~10 min | SQL1-Joey
| 2 | T-SQL Enhancements | 2 - Developers | sql2025book | ~5 min | SQL1-Joey
| 3 | GitHub Copilot for SQL | 2 - Developers | VS Code / SSMS 22 | ~2 min | Matt-Azure
| 4 | CES — F1 Race Operations | 2 - Developers | This repo (`CES/`) | ~15 min | SQL1-Joey
| 5 | Intelligent Search (Vectors) | 3 - AI Built-In | sql2025book + demos | ~15-20 min | Joey MacBook Pro
| 6 | Managed Identity & Security | 4 - Security | sql2025book | ~10 min |  Laptop-Azure Portal
| 7 | Optimized Locking | 5 - Performance | sql2025book + demos | ~3 min | SQL1-Joey
| 8 | Tempdb Resource Governance | 5 - Performance | sql2025book + demos | ~5 min |SQL1-Joey
| 9 | ABORT_QUERY_EXECUTION | 5 - Performance | demos | ~2 min |SQL1-oey 
| 10 | AG Reliability & Diagnostics | 6 - Availability | sql2025book | ~10 min | Matt-Azure
| 11 | AG Tuning | 6 - Availability | sql2025book | ~5 min |Matt-Azure
| 12 | Azure Arc Integration | 7 - Arc | sql2025book | ~10 min |Joey Surface
| | **Total demo time** | | | **~90-100 min** |


---

## MODULE 2: DEVELOPERS

### Demo 1: Native JSON

- **Source:** `sql2025book` — Developers chapter demos
- **Supplemental:** `demos/sqlserver2025/json`
- **Time:** ~10 min

**Walkthrough:**
1. Create a table with the new `json` data type
2. Insert JSON documents and show automatic validation (invalid JSON is rejected)
3. Compare storage size vs. `nvarchar(max)` approach
4. Demonstrate json indexing and query performance
5. Use new JSON aggregate functions (`JSON_OBJECTAGG`, `JSON_ARRAYAGG`)
6. Show `JSON_CONTAINS` for membership testing

**Talking point:** "Developers have been storing JSON in varchar columns for years — now it's a first-class citizen with validation, binary storage, and dedicated indexing."

---

### Demo 2: T-SQL Enhancements (brief)

- **Source:** `sql2025book` — Developers chapter demos
- **Time:** ~5 min

**Walkthrough:**
1. Show RegEx pattern matching on AdventureWorks data (email validation, phone extraction)
2. Demonstrate `||` operator, `CURRENT_DATE`, `PRODUCT()` aggregate
3. Quick comparison: old way vs. new way for common patterns

---

### Demo 3: GitHub Copilot for SQL

- **Source:** `demos/sqlserver2025` (VS Code / SSMS 22)
- **Time:** ~2 min

**Walkthrough:**
1. Show Copilot generating queries from natural language in VS Code
2. Show Copilot explaining an existing complex query
3. Show Copilot suggesting optimizations

---

### Demo 4: Change Event Streaming (CES) — F1 Race Operations

- **Source:** This repo — `CES/` folder
- **Time:** ~15 min

**Prerequisites:**
- Azure infrastructure deployed via `CES/infra/` Terraform
- SQL Server 2025 VM with system-assigned managed identity
- SQL IaaS Agent Extension registered (`az sql vm create`)
- `ANTHROPIC_API_KEY` environment variable set on the VM

**SQL Scripts (run in order):**
1. `01_create_database.sql` — Create F1RaceOps database, enable preview features
2. `02_create_tables.sql` — Create Drivers, Races, LiveTiming, PitStops, RaceControl tables
3. `03_seed_reference_data.sql` — Seed 20 F1 drivers and the Monaco Grand Prix race entry
4. `04_configure_ces.sql` — Create credential, enable CES, create stream group, add tables
5. `05_simulate_race.sql` — Run section by section while watching the consumer app
6. `06_verify_ces.sql` — Check CES health and diagnostics
7. `07_cleanup.sql` — Tear down CES and drop database

**Consumer App:**
- Start with `dotnet run` from the `CES/` folder on the VM
- Displays formatted race events: timing updates, pit stops, race control messages, race status changes
- AI-powered race engineer (Claude) detects anomalies (safety car, DNF, penalties, tire degradation) and generates team radio recommendations
- Recommendations sent to Azure Service Bus queue

**Demo Flow:**
1. Show the CES configuration in `04_configure_ces.sql` — credential, stream group, table partitioning
2. Start the consumer app — show it connecting to Event Hubs
3. Run `05_simulate_race.sql` section by section:
   - **Section 1:** Lights out — 20 drivers on the grid (burst of INS events)
   - **Section 2:** Early laps — position battles, DRS enabled, track limits warning
   - **Section 3:** Pit window — first stops, tire compound changes, Verstappen stays out
   - **Section 4:** Safety car — Stroll crashes, safety car deployed, free pit stop for Verstappen
   - **Section 5:** Restart — Verstappen passes Leclerc, green flag racing
   - **Section 6:** Late-race drama — penalty for Hamilton, Leclerc on fresh tires, fastest lap
   - **Section 7:** Chequered flag — Verstappen wins Monaco
4. Pause between sections to observe events arriving in near real-time
5. Point out: INSERTs for new data, old/new values for position changes, race control messages
6. Show the AI race engineer triggering on safety car deployment and driver DNF

**Talking point:** "The pit wall needs to know the instant a rival pits — not 30 seconds later when a polling job runs. CES gives us that push-based, real-time pipeline from the database to the strategy tools."

**Cleanup:** Run `07_cleanup.sql` to tear down CES and drop the database.

---

## MODULE 3: AI BUILT-IN

### Demo 5: Intelligent Search in SQL Server 2025

- **Source:** `sql2025book` — AI / Vectors chapter demos
- **Supplemental:** `demos/sqlserver2025/ai` (four provider integrations)
- **Time:** ~15-20 min

**Part 1 — The Problem:**
1. Show existing search methods (LIKE, Full-Text) against AdventureWorks products
2. Search for "lightweight gear for summer hiking" — poor results with keyword search

**Part 2 — Model Definition and Embeddings:**
1. Create an external model definition (Azure OpenAI or Ollama)
2. Create a table with a `vector` column
3. Generate embeddings for product descriptions

**Part 3 — Vector Search:**
1. Run `VECTOR_DISTANCE` with the same natural language prompt
2. Show dramatically better results
3. Demonstrate hybrid search: vector + price/category filters

**Part 4 — Multiple Providers (time permitting):**
1. Show the four different provider integrations from the demos repo (Azure OpenAI, OpenAI, Ollama, ONNX)

**Talking point:** "AdventureWorks needs better searching — the prompt may contain words not found in your data. That's why vector search matters."

---

## MODULE 4: SECURITY

### Demo 6: Managed Identity and Security

- **Source:** `sql2025book` — Security chapter demos
- **Time:** ~10 min

**Walkthrough:**

1. Managed Identity Demo in Azure Portal
2. Show outbound Managed Identity for backup to URL

**Talking point:** Managed Identity eliminates credential management and reduces attack surface — no passwords to rotate or leak.

---

## MODULE 5: PERFORMANCE & CONCURRENCY

### Demo 7: Optimized Locking

- **Source:** `sql2025book` — Core Engine chapter demos
- **Supplemental:** `demos/sqlserver2025/optimizedlocking`
- **Time:** ~3 min

**Walkthrough:**
1. Show traditional locking behavior with concurrent updates
2. Enable optimized locking
3. Re-run the same workload — observe eliminated lock escalation
4. Show reduced lock memory consumption via DMVs
5. Monitor TID locking in action

**Talking point:** "Developers need better concurrency and don't want to worry about locking internals."

---

### Demo 8: Tempdb Resource Governance

- **Source:** `sql2025book` — Core Engine chapter demos
- **Supplemental:** `demos/sqlserver2025/tempdb_rg`
- **Time:** ~5 min

**Walkthrough:**
1. Configure Resource Governor workload groups with tempdb space limits
2. Run a query that attempts to consume excessive tempdb
3. Show the query being terminated when it exceeds its allocation
4. Discuss use cases: multi-tenant, runaway query protection, shared BI environments

---

### Demo 9: ABORT_QUERY_EXECUTION

- **Source:** `demos/sqlserver2025/ABORT_QUERY_EXECUTION`
- **Time:** ~2 min

**Walkthrough:**
1. Show the hint in action — set a timeout, run a long query, observe termination

---

## MODULE 6: AVAILABILITY GROUPS

### Demo 10: AG Reliability and Diagnostics

- **Source:** `sql2025book` — Availability chapter demos
- **Time:** ~10 min

**Walkthrough:**
1. Set up or use a pre-configured AG environment
2. Walk through the improved health diagnostics DMVs
3. Simulate a scenario that previously caused "not synchronizing" state
4. Show how SQL 2025 handles it with reliable failover
5. Demonstrate ZSTD backup compression: compare backup sizes and speeds vs. legacy
6. Show backup to secondary replica configuration

---

### Demo 11: AG Tuning

- **Source:** `sql2025book` — Availability chapter demos
- **Time:** ~5 min

**Walkthrough:**
1. Show group commit waiting tuning parameters
2. Demonstrate contained AG with DAG configuration
3. Walk through the new diagnostics views

---

## MODULE 7: CONNECTED WITH ARC

### Demo 12: Azure Arc Integration

- **Source:** `sql2025book` — Arc chapter demos
- **Time:** ~10 min

**Walkthrough:**
1. Show an Arc-connected SQL Server 2025 instance in the Azure Portal
2. Walk through Managed Identity configuration
3. Demonstrate Entra authentication flow enabled by Arc
4. Show Azure Policy enforcement on the SQL instance
5. Demonstrate how Arc enables secure AI model access (connect back to Module 3)
6. Show Defender for SQL alerts and recommendations

---


