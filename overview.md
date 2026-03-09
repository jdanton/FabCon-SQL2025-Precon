# SQL Server 2025: The AI-Ready Enterprise Database
## Full-Day Training Outline (Co-Presented) — Revised

**Repo for all demos:** `https://github.com/microsoft/bobsql/tree/master/sql2025book`
**Supplemental demos:** `https://github.com/microsoft/bobsql/tree/master/demos/sqlserver2025`

> Demos marked with 🔬 are from the `sql2025book` repo. Demos marked with 🧪 are from the `demos/sqlserver2025` folder.

---

## MODULE 1: WELCOME & THE BIG PICTURE (~45 min)

---

### Slide 1: Title Slide — SQL Server 2025: The AI-Ready Enterprise Database
- Presenters, bios, social handles
- Training logistics: breaks, Q&A format, lab access
- Link to demo repo: `aka.ms/sqlserver2025demos`

### Slide 2: Agenda — What We'll Cover Today
- Module 1: The Big Picture
- Module 2: Developers, Developers, Developers
- Module 3: AI Built-In
- Module 4: The Core Engine — Security
- Module 5: The Core Engine — Performance & Concurrency
- Module 6: The Core Engine — Availability Groups
- Module 7: Connected with Arc
- Module 8: Fabric Integration & Mirroring
- Module 9: Wrap-Up & Resources

### Slide 3: Data Is the Fuel That Powers AI
- The explosion of enterprise data and the need for AI integration at the data layer
- Why the database — not a separate service — is the right place for AI building blocks
- SQL Server's position: trusted engine meets modern AI workloads

### Slide 4: Introducing SQL Server 2025
- "The AI-ready enterprise database from ground to cloud"
- Five pillars: AI Built-In, Best-in-class Security & Performance, Made for Developers, Cloud Agility through Azure, Fabric Integration
- `aka.ms/sqlserver2025`

### Slide 5: Building on a Foundation of Innovation
- SQL Server 2017: Linux, Containers, Adaptive QP, Graph, ML Services
- SQL Server 2019: Data Virtualization, IQP, ADR, Data Classification
- SQL Server 2022: Cloud Connected, IQP Next Gen, Ledger, Data Lakes, T-SQL enhancements
- SQL Server 2025: AI Built-In, Developer-first, Arc-connected, Fabric-integrated

### Slide 6: Microsoft SQL — Ground to Cloud to Fabric
- Develop once, deploy anywhere: SQL Server 2025 → Azure SQL → SQL Database in Fabric
- Consistency of T-SQL, Engine, Tools, Fabric, AI, and Copilots across all platforms
- The "common bond" of the SQL family

### Slide 7: SQL Server 2025 — Areas of Innovation
- **AI Built-In:** Vectors, embeddings, model management, RAG patterns
- **Develop Modern Data Applications:** JSON, RegEx, REST API, CES, GitHub Copilot for SQL
- **Integrate Your Data with Fabric:** Mirroring, near-real-time analytics

### Slide 8: SQL Server 2025 — Meat and Potatoes
- **Secure by Default:** Managed Identity, Entra, Defender integration
- **Mission Critical Engine:** Optimized Locking, IQP enhancements, AG reliability
- **Connected with Arc** | **Assisted by Copilots** | **Built for All Platforms**

### Slide 9: The SQL Server 2025 Platform Architecture
- Visual walkthrough of the full architecture: SQL Server engine at center
- Outbound connections: Azure AI Foundry, Event Hub, Fabric, Entra
- Local connections: AI models (Ollama, ONNX), REST endpoints, Semantic Kernel
- Management plane: Arc, SSMS 22 with Copilot, VS Code mssql extension
- Secondary replica capabilities: Query Store, backups, tuning, diagnostics

### Slide 10: SSMS 22 — General Availability
- Based on Visual Studio 2022 (64-bit)
- Copilot integration (public preview)
- Dark theme and multiple color themes
- Git and TFS support
- New connection experience
- Windows ARM64 support

### Slide 11: SSMS 22 — Developer Productivity Features
- Query editor improvements
- JSON viewer
- Query hints recommendation
- Zooming for grid results
- Always Encrypted assessment
- VS Installer / update experience

### Slide 12: VS Code mssql Extension
- GitHub Copilot integration for SQL authoring
- Cross-platform SQL development (Windows, Mac, Linux)
- Schema-aware IntelliSense
- Modern development workflow integration

### Slide 13: Developer Edition Changes
- Choose your target production deployment: Standard or Enterprise
- Develop and test with no license costs
- Features and limits now match your target deployment edition
- Two flavors: Developer Standard Edition and Developer Enterprise Edition

### Slide 14: FAQ — Timeline and Availability
- SQL Server 2025 is now Generally Available
- Upgrade methods same as previous releases
- Supported OS and SQL versions for upgrade per documentation

### Slide 15: FAQ — Pricing, Licensing, and Editions
- No pricing or licensing changes for SQL Server
- **Express:** Now supports 50GB database, many new features included
- **Standard:** Core limit increased from 24 → 32, memory from 128GB → 256GB, full Resource Governor
- **Enterprise:** All features including DiskANN vector index and all AG enhancements

### Slide 16: FAQ — Deprecated Features and Other Items
- Discontinued: MDS, DQS, Synapse Link, Hot Add CPU, Purview Access Policies
- `PREVIEW_FEATURES` database option: enables features in preview at GA
- Power BI Report Server replaces SSRS for paid licenses
- SSAS has new improvements; SSIS still supported

---

## MODULE 2: DEVELOPERS, DEVELOPERS, DEVELOPERS (~90 min including demos)

---

### Slide 17: Section Title — Developers, Developers, Developers

### Slide 18: Built for Developers — Overview
- This is the most developer-friendly SQL Server release in a decade
- Native JSON, RegEx, REST APIs, Change Event Streaming
- GitHub Copilot for SQL, Python driver, Data API Builder
- GraphQL via Data API Builder

### Slide 19: Native JSON — The Problem
- Developers have been storing JSON in `varchar`/`nvarchar` columns for years
- No validation, no specialized indexing, no binary optimization
- JSON functions worked, but storage was inefficient

### Slide 20: Native JSON — The Solution
- New `json` data type: binary storage, up to 2GB
- Automatic validation on insert/update
- Compressed storage: less I/O, fewer page reads

### Slide 21: Native JSON — Indexing
- Dedicated `json` index type
- Optimized for JSON path queries
- Replaces the workaround of computed columns + standard indexes

### Slide 22: Native JSON — New Functions
- `JSON_OBJECTAGG` — aggregate rows into a JSON object
- `JSON_ARRAYAGG` — aggregate rows into a JSON array
- `JSON_CONTAINS` — test for membership
- `JSON_QUERY WITH ARRAY WRAPPER` — wrap results as array

### Slide 23: Native JSON — Use Cases
- REST APIs and microservice payloads
- Configuration storage
- Document-style flexible schemas
- E-commerce product catalogs with variable attributes
- Log data and telemetry

> **🔬 DEMO: Native JSON**
> - Repo: `sql2025book` — Developers chapter demos
> - Supplemental: `demos/sqlserver2025/json`
> - Walkthrough:
>   - Create a table with the new `json` data type
>   - Insert JSON documents and show automatic validation
>   - Compare storage size vs. `nvarchar(max)` approach
>   - Demonstrate json indexing and query performance
>   - Use new JSON aggregate functions (`JSON_OBJECTAGG`, `JSON_ARRAYAGG`)
>   - Show `JSON_CONTAINS` for membership testing
> - **Talking point:** "Developers need to store JSON in SQL Server" — this is now a first-class citizen

### Slide 24: T-SQL Enhancements — Regular Expressions
- `REGEXP_LIKE` — test if a string matches a pattern
- `REGEXP_COUNT` — count pattern occurrences
- `REGEXP_INSTR` — find position of pattern match
- `REGEXP_REPLACE` — replace pattern matches
- `REGEXP_SUBSTR` — extract substring matching pattern
- No more CLR functions or LIKE workarounds for pattern matching

### Slide 25: T-SQL Enhancements — String and Data Functions
- `||` string concat operator (ANSI standard)
- `CURRENT_DATE` returns `DATE` type
- `SUBSTRING()` with optional length — omit to get "rest of string"
- `UNISTR()` — Unicode string construction
- `DATEADD()` now supports `bigint`

### Slide 26: T-SQL Enhancements — Aggregates and Matching
- `PRODUCT()` aggregate — multiplicative aggregate function
- Fuzzy string match functions — approximate matching for data quality
- `BASE64_ENCODE` / `BASE64_DECODE` — binary-to-text and back

> **🔬 DEMO: T-SQL Enhancements** (brief)
> - Repo: `sql2025book` — Developers chapter demos
> - Show RegEx pattern matching on AdventureWorks data (email validation, phone extraction)
> - Demonstrate `||` operator, `CURRENT_DATE`, `PRODUCT()` aggregate
> - Quick comparison: old way vs. new way for common patterns

### Slide 27: GitHub Copilot for SQL — Overview
- AI-assisted T-SQL authoring in VS Code and SSMS 22
- Context-aware: understands your schema, tables, and relationships
- Generate queries from natural language descriptions
- Explain existing complex queries
- Suggest optimizations

### Slide 28: GitHub Copilot for SQL — In Action
- Inline suggestions as you type
- Chat-based query generation: "Show me top 10 customers by revenue last quarter"
- Query explanation: highlight a query, ask "What does this do?"
- Schema exploration: "What tables relate to orders?"

> **🧪 DEMO: GitHub Copilot for SQL**
> - Show Copilot generating queries from natural language in VS Code
> - Show Copilot explaining an existing complex query
> - Show Copilot suggesting optimizations
> - ~2 min demo

### Slide 29: Change Event Streaming (CES) — The Problem
- CDC and CT are pull-based — applications must poll for changes
- Modern architectures demand push-based, event-driven patterns
- Microservices, real-time analytics, and AI agents need instant notification

### Slide 30: Change Event Streaming (CES) — The Solution
- Stream data changes in near-real-time from SQL directly to Azure Event Hubs
- Push-based delivery
- "IO-less" — reads committed transactions from the transaction log
- Supports DDL changes
- Single destination per configuration

### Slide 31: CT vs. CDC vs. CES — Comparison
- **Change Tracking (CT):** Sync capture, system tables (minimal), row identifier only, pull-based, immediate availability
- **Change Data Capture (CDC):** Async from log, system tables (extra logging), row identifier + data, pull-based, near-real-time, requires SQL Agent
- **Change Event Streaming (CES):** Async from log, event stream ("IO-less"), row identifier + data + DDL, push-based, near-real-time

### Slide 32: CT vs. CDC vs. CES — When to Use What
- **CT:** Cache invalidation, sync scenarios
- **CDC:** Data warehousing, auditing, ETL pipelines
- **CES:** Event-driven architectures, microservices integration, real-time analytics, cache sync, AI Agents


### Slide 33: CES Architecture — F1 Race Operations Example

- Scenario: An F1 team's pit wall detects live race changes via CES — position swaps, pit stops, safety car deployments
- Flow: Race data changes → CES → Azure Event Hub → Azure Functions → Azure AI Foundry
- AI Agent analyzes tire degradation and gap data → recommends optimal pit stop window and compound selection
- Demonstrates real-world event-driven architecture with AI integration — where milliseconds matter

**Slide 34: CES — Event Payload and Configuration**

- Event structure: operation type (INS/UPD/DEL), row data with old and new values, schema information
- Configuration via T-SQL: `sp_enable_event_stream`, `sp_create_event_stream_group`, `sp_add_object_to_event_stream_group`
- Monitoring and diagnostics via `dm_change_feed_errors` and `dm_change_feed_log_scan_sessions`
- Error handling and retry behavior

**🏁 DEMO: Change Event Streaming**

- Repo: F1 Race Operations CES Demo
- Walkthrough:
  - Create the F1RaceOps database and race operations schema (Drivers, LiveTiming, PitStops, RaceControl)
  - Configure CES with Table partitioning — pit stops and timing data route to separate Event Hub partitions
  - Simulate a live Monaco Grand Prix: lights out, position battles, pit stops, a safety car crash, and chequered flag
  - Observe events streaming to Event Hub in the consumer app — see INSERTs for pit stops, UPDATEs with old/new positions, race control messages in near real-time
  - Examine the CloudEvent payload structure (e.g., a pit stop event with tire compound in/out, stop duration, lap number)
  - Discuss integration patterns: Azure Functions consuming pit stop events to trigger an AI Agent that models tire degradation and radios back a strategy recommendation
- Talking point: "The pit wall needs to know the instant a rival pits — not 30 seconds later when a polling job runs. CES gives us that push-based, real-time pipeline from the database to the strategy tools."


### Slide 35: REST API Connectivity
- `sp_invoke_external_rest_endpoint` — call any REST service from T-SQL
- Not limited to AI models: any REST service, webhooks, external APIs
- Enables SQL Server as an orchestration point for external services

### Slide 36: Data API Builder and GraphQL
- Data API Builder: generate REST and GraphQL APIs from SQL Server tables
- Dramatically reduces backend code for data applications
- Built-in authentication, authorization, and filtering
- Works with SQL Server 2025 on-premises and in Azure

### Slide 37: Microsoft Python Driver for SQL Server
- Official Microsoft Python driver
- First-class Python support for SQL Server connectivity
- Integrates with popular data science and ML frameworks
- Complements the existing ODBC, JDBC, and .NET drivers

---

*☕ BREAK (~15 min)*

---

## MODULE 3: AI BUILT-IN (~90 min including demos)

---

### Slide 38: Section Title — AI Built-In

### Slide 39: What Problems Are We Trying to Solve with AI?
- Smarter searching on existing text data
- Centralized vector searching across documents and data
- Building blocks for intelligent assistants, RAG, AI Agents
- Taking advantage of AI in a secure and scalable fashion
- Overcoming complexity by using familiar T-SQL

### Slide 40: Why AI in the Database?
- Your data is already in SQL Server — why move it?
- Security and governance already in place
- T-SQL is the language your team already knows
- Combine structured queries with semantic search (hybrid search)
- Reduce architectural complexity: fewer moving parts

### Slide 41: Vector Search — The Concept
- Traditional search: keyword matching (LIKE, Full-Text Search)
- Semantic search: meaning-based matching using embeddings
- Embeddings: numerical representations that capture meaning
- "The prompt may contain words not found in your data!" — this is why vector search matters

### Slide 42: Vector Search with Your Data — The RAG Pattern
- Prompt → Embedding Model → Vector embedding
- Vector embedding compared to stored embeddings via similarity search
- Results augment the original prompt
- Augmented prompt sent to Language Model → Generated response
- All under SQL Server security

### Slide 43: Agentic RAG — Three Patterns
- **Vector Search:** Retrieve most semantically relevant data to ground LLMs
- **Operational RAG:** Store vectors and data together for consistency
- **Structured Queries:** Allow LLMs to query structured data with rich metadata and query optimization

  #Show Davide's repo.

### Slide 44: The Vector Data Type
- New native `vector` data type
- Stores arrays of floating-point numbers
- Configurable dimensions (e.g., 1536 for OpenAI ada-002, 384 for smaller models)
- Driver support across all major SQL client libraries
- Binary storage optimized for efficient I/O

### Slide 45: Model Definitions — CREATE EXTERNAL MODEL
- Declarative model definitions using `CREATE EXTERNAL MODEL`
- Supported API types: Azure OpenAI, OpenAI, Ollama, ONNX Runtime
- Points to a REST endpoint — models run outside the engine
- System view for managing model definitions
- Ground or cloud deployment

### Slide 46: Embedding Generation
- T-SQL functions to generate embeddings from your data
- Text chunking: break large text into model-appropriate segments
- Multi-modal embedding support
- Works with any REST-accessible embedding model
- Store embeddings in `vector` columns alongside your relational data

### Slide 47: Searching with VECTOR_DISTANCE (KNN)
- Brute-force exact nearest neighbor search
- Compares prompt embedding against all stored embeddings
- Accurate but slower on large datasets
- Good for smaller datasets or when precision is critical
- Syntax and usage examples

### Slide 48: DiskANN Index and VECTOR_SEARCH (ANN)
- DiskANN: Microsoft Research technology for billion-scale approximate nearest neighbor
- Create a vector index on your `vector` column
- `VECTOR_SEARCH` uses the index for fast approximate results
- Orders of magnitude faster than brute-force on large datasets
- Index maintenance considerations
- Enabled by `PREVIEW_FEATURES`

### Slide 49: Hybrid Search — The Best of Both Worlds
- Combine `VECTOR_DISTANCE` or `VECTOR_SEARCH` with standard SQL WHERE clauses
- Example: "Find products similar to 'lightweight hiking gear' WHERE price < 100 AND category = 'Outdoor'"
- Leverages the full power of the SQL query optimizer
- This is what sets SQL Server apart from standalone vector databases

### Slide 50: SQL Server 2025 Vector Architecture — Overview
- Seven-step flow:
  1. Model Definition
  2. Generate Embeddings
  3. Create a Vector Index
  4. T-SQL Prompt
  5. Generate Prompt Embedding
  6. Vector Search
  7. Other Filters (hybrid search)

### Slide 51: Vector Architecture — Model Definition and Embeddings (Steps 1-3)
- Step 1: `CREATE EXTERNAL MODEL` pointing to Azure OpenAI, Ollama, etc.
- Step 2: T-SQL to generate embeddings from your existing data and store in `vector` column
- Step 3: Create DiskANN vector index for fast retrieval
- Models run outside the engine — you choose where

### Slide 52: Vector Architecture — Search and Retrieval (Steps 4-7)
- Step 4: User submits a natural language prompt
- Step 5: Same model generates an embedding for the prompt
- Step 6: `VECTOR_DISTANCE` or `VECTOR_SEARCH` compares prompt to stored data
- Step 7: Standard SQL WHERE clauses for hybrid filtering
- Extensibility via `sp_invoke_external_rest_endpoint` for any REST model endpoint

### Slide 53: Security, SQL, and AI
- You control all access with SQL security
- You control which AI models to use
- AI models (ground and/or cloud) are isolated from SQL Server
- Use RLS, TDE, and Dynamic Data Masking on vector data
- Track everything with SQL Server Auditing


### Slide 54: AI Provider Flexibility
- Azure OpenAI — cloud hosted, enterprise grade
- OpenAI — direct API access
- Ollama — locally hosted open-source models (Llama, Mistral, etc.)
- ONNX Runtime — local inference engine (PREVIEW_FEATURES)
- KServe, vLLM, NVIDIA Triton — network hosted
- Hugging Face models via compatible serving layers
- `sp_invoke_external_rest_endpoint` for anything else

### Slide 55: Framework Integration
- LangChain — popular AI/LLM orchestration framework
- Semantic Kernel — Microsoft's AI orchestration SDK
- Entity Framework Core — .NET ORM with vector support
- Build agents and multi-step AI workflows that leverage SQL Server as the data backbone

> **🔬 DEMO: Intelligent Search in SQL Server 2025**
> - Repo: `sql2025book` — AI / Vectors chapter demos
> - Supplemental: `demos/sqlserver2025/ai` (four provider integrations)
> - **Part 1 — The Problem:**
>   - Show existing search methods (LIKE, Full-Text) against AdventureWorks products
>   - Search for "lightweight gear for summer hiking" — poor results with keyword search
> - **Part 2 — Model Definition and Embeddings:**
>   - Create an external model definition (Azure OpenAI or Ollama)
>   - Create a table with a `vector` column
>   - Generate embeddings for product descriptions
> - **Part 3 — Vector Search:**
>   - Run `VECTOR_DISTANCE` with the same natural language prompt
>   - Show dramatically better results
>   - Demonstrate hybrid search: vector + price/category filters
> - **Part 4 — Multiple Providers (time permitting):**
>   - Show the four different provider integrations from the demos repo
> - **Talking point:** "AdventureWorks needs better searching"

---

*🍽️ LUNCH BREAK (~60 min)*

---

## MODULE 4: THE CORE ENGINE — SECURITY (~45 min including demos)

---

### Slide 56: Section Title — The Core Engine: Secure by Default

### Slide 57: Security Vision for SQL Server 2025
- Microsoft Entra authentication (building on SQL 2022)
- Managed Identity support — the big new story
- Microsoft Defender integration
- Passwordless everywhere

### Slide 58: Managed Identity — Inbound Connections
- System-assigned managed identity for SQL Server
- Passwordless authentication for applications connecting to SQL
- Eliminates credential management overhead
- Reduces attack surface — no passwords to rotate or leak
- Enabled by Azure Arc

### Slide 59: Managed Identity — Outbound Connections
- Backup to URL with managed identity
- Managed identity support for EKM (Extensible Key Management)
- Managed identity for AI model access
- No more storing secrets in SQL Server for external service calls

### Slide 60: Microsoft Entra Enhancements
- Entra logins with non-unique display names
- Broader Entra integration scenarios
- Custom password policy on Linux

### Slide 61: Encryption and Protocol Enhancements
- OAEP support for encryption (replacing legacy PKCS#1 v1.5)
- PBKDF password hashing — modern key derivation
- TDS 8.0 / TLS 1.3 support for tools
- Security cache improvements — better application concurrency under security operations

### Slide 62: Microsoft Defender for SQL
- Threat detection for SQL Server on-premises via Arc
- Vulnerability assessment and recommendations
- Alerting on suspicious database activities
- Unified security posture management in Azure Portal

> **🔬 DEMO: Managed Identity and Security**
> - Repo: `sql2025book` — Security chapter demos
> - Walkthrough:
>   - Show Managed Identity configuration via Arc
>   - Demonstrate passwordless authentication for inbound connections
>   - Show outbound Managed Identity for backup to URL
>   - Demonstrate Managed Identity for AI model access (ties back to Module 3)
> - Discuss how Managed Identity eliminates credential management and reduces attack surface

---

## MODULE 5: THE CORE ENGINE — PERFORMANCE & CONCURRENCY (~60 min including demos)

---

### Slide 63: Section Title — The Core Engine: Mission Critical Performance

### Slide 64: Mission Critical Engine — Three Investment Areas
- **Improve Concurrency:** Optimized Locking, tempdb governance
- **Accelerate Performance:** IQP enhancements, batch mode, columnstore
- **Increase HADR:** (covered in Module 6)
- Design principle: "Get faster with no code changes required"

### Slide 65: Optimized Locking — The Problem
- Traditional lock escalation: row → page → table
- Causes blocking, deadlocks, and unpredictable concurrency
- Applications forced to design around locking internals
- Lock memory consumption grows with concurrent workloads

### Slide 66: Optimized Locking — The Solution
- Transaction ID (TID) locking replaces traditional escalation
- Hands-free lock management built into the engine
- Already proven in Azure SQL Database
- No application code changes required

### Slide 67: Optimized Locking — Benefits
- Dramatically improved concurrency for update-heavy workloads
- Reduced lock memory overhead
- Eliminated lock escalation blocking scenarios
- Simpler troubleshooting — fewer locking-related issues

> **🔬 DEMO: Improving Application Concurrency with Optimized Locking**
> - Repo: `sql2025book` — Core Engine chapter demos
> - Supplemental: `demos/sqlserver2025/optimizedlocking`
> - Walkthrough:
>   - Show traditional locking behavior with concurrent updates
>   - Enable optimized locking
>   - Re-run the same workload — observe eliminated lock escalation
>   - Show reduced lock memory consumption via DMVs
>   - Monitor TID locking in action
> - **Talking point:** "Developers need better concurrency and don't want to worry about locking internals"
> - ~3 min demo

### Slide 68: Intelligent Query Processing — What's New
- CE (Cardinality Estimator) feedback for expressions
- Optional parameter plans optimization (building on PSP from 2022)
- DOP (Degree of Parallelism) feedback — now ON by default
- Key theme: the optimizer learns and adapts, fewer code changes needed

### Slide 69: Optimized sp_executesql
- Better plan reuse for parameterized queries
- Reduces compilation overhead
- Significant impact for ORM-generated workloads (Entity Framework, Hibernate, etc.)
- No application changes required

### Slide 70: Batch Mode Optimizations
- Batch mode: processes ~900 rows at a time in columnar arrays (~64KB pages)
- Leverages vectorized CPU execution (SIMD/AVX instructions)
- Works for both columnstore AND rowstore
- SQL Server 2025 further optimizes this pipeline
- Especially benefits aggregate queries and large scans

### Slide 71: Columnstore Index Improvements
- Better ordered columnstore indexing
- Columnstore index maintenance improvements
- Performance enhancements for columnstore queries
- Segment elimination improvements

### Slide 72: Query Store Enhancements
- Query Store on readable secondary replicas
- Persist statistics on secondaries
- Better insight into read workload performance on AG replicas
- Enhanced diagnostics for query performance regression

### Slide 73: Tempdb Resource Governance
- Control tempdb space consumption using Resource Governor workload groups
- Prevent runaway queries from exhausting tempdb
- Per-group tempdb space limits
- Full Resource Governor now available in Standard Edition!

> **🔬 DEMO: Tempdb Resource Governance**
> - Repo: `sql2025book` — Core Engine chapter demos
> - Supplemental: `demos/sqlserver2025/tempdb_rg`
> - Walkthrough:
>   - Configure Resource Governor workload groups with tempdb space limits
>   - Run a query that attempts to consume excessive tempdb
>   - Show the query being terminated when it exceeds its allocation
>   - Discuss use cases: multi-tenant, runaway query protection, shared BI environments

### Slide 74: ABORT_QUERY_EXECUTION Hint
- New query hint to forcefully terminate long-running queries after a threshold
- Practical for BI/reporting environments with unpredictable query patterns
- Complements Query Governor and Resource Governor

> **🧪 DEMO: ABORT_QUERY_EXECUTION**
> - Repo: `demos/sqlserver2025/ABORT_QUERY_EXECUTION`
> - Show the hint in action — set a timeout, run a long query, observe termination

### Slide 75: Other Performance Enhancements
- ADR (Accelerated Database Recovery) in tempdb
- `tmpfs` support for tempdb on Linux
- Remove In-Memory OLTP from a database (finally!)
- Persisted statistics for readable secondaries
- Change tracking cleanup improvements

---

*☕ BREAK (~15 min)*

---

## MODULE 6: THE CORE ENGINE — AVAILABILITY GROUPS (~60 min including demos)

---

### Slide 76: Section Title — The Core Engine: Availability Groups

### Slide 77: AG Enhancements — The Big Theme
- "Customers love Always On Availability Groups but there are situations where they get stuck in a not synchronizing state"
- SQL Server 2025 enhances AG algorithms for reliable failover
- Better diagnostics, better tuning, better backups

### Slide 78: Reliable Failover
- Fast failover for persistent AG health events
- Enhanced algorithms to prevent "stuck in not synchronizing" state
- Switching to resolving state improvements
- Reduced manual intervention during failover scenarios

### Slide 79: Improved Health Diagnostics
- Better visibility into AG state and health
- Enhanced DMVs and diagnostic views
- Easier root cause analysis for AG issues
- Proactive detection of health degradation

### Slide 80: Communication and Tuning
- Communication control flow tuning
- AG group commit waiting tuning — optimize for throughput vs. latency
- Async page request dispatching
- Fine-grained control over AG behavior

### Slide 81: AG Configuration Enhancements
- Remove listener IP address — simplify configurations
- `NONE` routing option for routing lists
- Contained AG support for Distributed Availability Groups (DAG)
- DAG sync improvements

### Slide 82: Backup Enhancements — ZSTD Compression
- ZSTD backup compression algorithm
- Significantly faster and better compression ratios than legacy algorithm
- Reduced backup windows and storage costs
- Easy to enable — just specify the new compression option

### Slide 83: Backup Enhancements — Azure and Secondary
- Backups on secondary replicas — offload backup workload from primary
- Backup to Azure immutable storage — compliance and ransomware protection
- Backup to URL with Managed Identity — passwordless backup to Azure
- Combines with Arc for seamless configuration

> **🔬 DEMO: Availability Group Reliability and Diagnostics**
> - Repo: `sql2025book` — Availability chapter demos
> - Walkthrough:
>   - Set up or use a pre-configured AG environment
>   - Walk through the improved health diagnostics DMVs
>   - Simulate a scenario that previously caused "not synchronizing" state
>   - Show how SQL 2025 handles it with reliable failover
>   - Demonstrate ZSTD backup compression: compare backup sizes and speeds vs. legacy
>   - Show backup to secondary replica configuration

> **🔬 DEMO: AG Tuning**
> - Repo: `sql2025book` — Availability chapter demos
> - Show group commit waiting tuning parameters
> - Demonstrate contained AG with DAG configuration
> - Walk through the new diagnostics views

---

## MODULE 7: CONNECTED WITH ARC (~25 min including demos)

---

### Slide 84: Section Title — Connected with Azure Arc

### Slide 85: Azure Arc for SQL Server — Why It Matters
- Arc enables cloud management for on-premises and multi-cloud SQL Server
- Foundation for Managed Identity, Entra authentication, Defender, Azure policies
- The bridge between on-premises SQL and Azure services

### Slide 86: What Arc Enables — Security
- Managed Identity (inbound + outbound)
- Entra authentication for on-premises SQL Server
- Microsoft Defender for SQL threat detection
- Unified security posture in Azure Portal

### Slide 87: What Arc Enables — Management
- Azure Portal visibility for all SQL instances
- Azure Policy enforcement for SQL Server
- Inventory and governance across your estate
- RBAC through Azure

### Slide 88: What Arc Enables — AI and Fabric
- Secure AI model access via Arc-managed credentials
- Fabric mirroring configuration and management
- Backup to URL with Managed Identity
- Backup to Azure immutable storage

### Slide 89: Arc Architecture and Onboarding
- Arc agent installation and registration
- Connecting SQL Server instances to Azure Arc
- Azure resource representation of on-premises SQL instances
- Network requirements and connectivity options

> **🔬 DEMO: Azure Arc Integration**
> - Repo: `sql2025book` — Arc chapter demos
> - Walkthrough:
>   - Show an Arc-connected SQL Server 2025 instance in the Azure Portal
>   - Walk through Managed Identity configuration
>   - Demonstrate Entra authentication flow enabled by Arc
>   - Show Azure Policy enforcement on the SQL instance
>   - Demonstrate how Arc enables secure AI model access (connect back to Module 3)
>   - Show Defender for SQL alerts and recommendations

---

## MODULE 8: FABRIC INTEGRATION & MIRRORING (~45 min)

---

### Slide 90: Section Title — Integrate Your Data with Microsoft Fabric

### Slide 91: Why Fabric Mirroring?
- Offload read/analytics workloads from production SQL Server
- No ETL pipeline required
- Near-real-time data availability in Fabric
- Unlock Power BI, Copilot, and AI/ML capabilities on operational data

### Slide 92: Mirroring Architecture
- SQL Server 2025 → Change Feed → OneLake (Delta Parquet format)
- Reads committed transaction log changes
- Pushes automatically to Microsoft Fabric OneLake
- SQL Analytics Endpoint in Fabric for querying

### Slide 93: Mirroring — What It Unlocks
- Unified analytics: combine SQL Server data with other Fabric data sources
- Power BI real-time dashboards on operational data
- Lakehouse and warehouse integration
- AI/ML training data pipelines
- Cross-platform data exploration

### Slide 94: Mirroring — Configuration and Management
- Configuration via Arc and Azure Portal
- Monitoring latency and sync status
- Table selection and filtering
- Security and access control

> Note: Mirroring demos require Azure Fabric access. Consider a pre-recorded walkthrough or Azure Portal demonstration if live Fabric isn't available.

---

## MODULE 9: WRAP-UP & CALL TO ACTION (~15 min)

---

### Slide 95: Customer Experiences
- Performance: optimized locking and ZSTD backup compression benefits
- Availability: enhanced AG reliability
- AI: semantic search and RAG capabilities for GenAI solutions
- Integration: CES and Fabric Mirroring bridging operational data to analytics

### Slide 96: Edition Highlights Recap
- **Express:** 50GB database, many new features
- **Standard:** 32 cores, 256GB RAM, full Resource Governor
- **Enterprise:** All features, DiskANN vector index, all AG enhancements
- **Developer:** Free for dev/test, Standard and Enterprise flavors

### Slide 97: Resources
- Blogs: `aka.ms/sqlserver2025`
- Docs: `aka.ms/sqlserver2025docs`
- Demos: `aka.ms/sqlserver2025demos`
- Book: `aka.ms/sql2025book` — *SQL Server 2025 Unveiled* by Bob Ward (Apress)
- Download: `aka.ms/getsqlserver2025`

### Slide 98: Thank You and Q&A
- Open floor for questions
- Discuss attendees' upgrade/migration plans
- Share experiences and scenarios
- Presenter contact info and social handles

---

## APPENDIX A: DEMO INVENTORY

### From `sql2025book` (by book chapter):
| Focus Area | Demo Topics | Approx. Time |
|---|---|---|
| **AI / Vectors** | Model definitions, embedding generation, vector search, VECTOR_DISTANCE, DiskANN, hybrid search, multiple AI providers (Azure OpenAI, OpenAI, Ollama, ONNX) | 15-20 min |
| **Developers** | JSON data type, JSON indexing, JSON aggregates, RegEx, T-SQL enhancements, CES | 15-20 min |
| **Core Engine** | Optimized locking, tempdb resource governance, batch mode, ABORT_QUERY_EXECUTION | 10-15 min |
| **Security** | Managed Identity configuration, Entra authentication, Defender integration | 10-15 min |
| **Availability** | AG reliable failover, health diagnostics, ZSTD compression, backup enhancements, AG tuning | 15-20 min |
| **Arc** | Arc onboarding, Azure Portal management, policy enforcement, Managed Identity via Arc | 10-15 min |

### From `demos/sqlserver2025`:
| Folder | Description |
|---|---|
| `ABORT_QUERY_EXECUTION/` | ABORT_QUERY_EXECUTION query hint demo |
| `ai/` | Comprehensive AI demos — four AI provider integrations, vector search, embeddings, semantic similarity |
| `json/` | Native JSON data type with validation, performance, and indexing |
| `optimizedlocking/` | Optimized locking concurrency improvements |
| `REST/` | REST endpoint integration — healthcare solution example |
| `tempdb_rg/` | Tempdb space resource governance with Resource Governor |

---

## APPENDIX B: TIMING SUMMARY

| Module | Topic | Slides | Time |
|---|---|---|---|
| 1 | Welcome & Big Picture | 1–16 | 45 min |
| 2 | Developers | 17–37 | 90 min |
| — | *Break* | — | 15 min |
| 3 | AI Built-In | 38–55 | 90 min |
| — | *Lunch* | — | 60 min |
| 4 | Security | 56–62 | 45 min |
| 5 | Performance & Concurrency | 63–75 | 60 min |
| — | *Break* | — | 15 min |
| 6 | Availability Groups | 76–83 | 60 min |
| 7 | Connected with Arc | 84–89 | 45 min |
| 8 | Fabric & Mirroring | 90–94 | 30 min |
| 9 | Wrap-Up & Q&A | 95–98 | 15 min |
| | **Total** | **98 slides** | **~8.5 hours** |
