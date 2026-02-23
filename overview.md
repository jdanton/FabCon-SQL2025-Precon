# SQL Server 2025: The AI-Ready Enterprise Database
## Full-Day Training Outline (Co-Presented)

**Repo for all demos:** `https://github.com/microsoft/bobsql/tree/master/sql2025book`
**Supplemental demos:** `https://github.com/microsoft/bobsql/tree/master/demos/sqlserver2025`

> Note: Demos marked with 🔬 are from the `sql2025book` repo. Demos marked with 🧪 are from the `demos/sqlserver2025` folder. Adapt as needed based on your environment and available AI providers.

---

## MODULE 1: WELCOME & THE BIG PICTURE (~45 min)

---

### Slide 1: Title Slide — SQL Server 2025: The AI-Ready Enterprise Database
- Presenters, bios, social handles
- Training logistics: breaks, Q&A format, lab access
- Link to demo repo: `aka.ms/sqlserver2025demos`

### Slide 2: Data Is the Fuel That Powers AI
- The explosion of enterprise data and the need for AI integration at the data layer
- Why the database — not a separate service — is the right place for AI building blocks
- SQL Server's position: trusted engine meets modern AI workloads

### Slide 3: Introducing SQL Server 2025
- "The AI-ready enterprise database from ground to cloud"
- Five pillars: AI Built-In, Best-in-class Security & Performance, Made for Developers, Cloud Agility through Azure, Fabric Integration
- GA release: CY25H2 → now GA (update as appropriate)
- `aka.ms/sqlserver2025`

### Slide 4: Building on a Foundation of Innovation
- SQL Server 2017: Linux, Containers, Adaptive QP, Graph, ML Services
- SQL Server 2019: Data Virtualization, IQP, ADR, Data Classification
- SQL Server 2022: Cloud Connected, IQP Next Gen, Ledger, Data Lakes, T-SQL enhancements
- SQL Server 2025: AI Built-In, Developer-first, Arc-connected, Fabric-integrated

### Slide 5: Microsoft SQL – Ground to Cloud to Fabric
- Develop once, deploy anywhere: SQL Server 2025 → Azure SQL → SQL Database in Fabric
- Consistency of T-SQL, Engine, Tools, Fabric, AI, and Copilots across all platforms
- The "common bond" of the SQL family

### Slide 6: SQL Server 2025 at a Glance (Pillar Overview)
- **AI Built-In:** Vectors, embeddings, model management, RAG patterns
- **Develop Modern Data Applications:** JSON, RegEx, REST API, CES, GitHub Copilot for SQL
- **Integrate Your Data with Fabric:** Mirroring, near-real-time analytics
- **Secure by Default:** Managed Identity, Entra, Defender integration
- **Mission Critical Engine:** Optimized Locking, IQP enhancements, AG reliability
- **Connected with Arc** | **Assisted by Copilots** | **Built for All Platforms**

### Slide 7: The SQL Server 2025 Platform Architecture
- Visual walkthrough of the full architecture: SQL Server engine at center
- Outbound connections: Azure AI Foundry, Event Hub, Fabric, Entra
- Local connections: AI models (Ollama, ONNX), REST endpoints, Semantic Kernel
- Management plane: Arc, SSMS 22 with Copilot, VS Code mssql extension
- Secondary replica capabilities: Query Store, backups, tuning, diagnostics

### Slide 8: A New Wave of Tools
- **SSMS 22:** Based on VS 2022 (64-bit), Copilot integration (public preview), dark theme, Git/TFS support, new connection experience, query editor improvements, Always Encrypted assessment, Windows ARM64 support
- **VS Code mssql extension:** GitHub Copilot integration for SQL authoring
- Developer Edition: now comes in Standard and Enterprise flavors (free for dev/test)

### Slide 9: FAQ Slide
- **GA timeline:** Now generally available
- **Pricing/licensing:** No pricing or licensing changes; edition improvements (Express → 50GB, Standard → 32 cores / 256GB RAM, full Resource Governor in Standard)
- **Upgrade path:** Same methods as previous releases
- **Deprecated features:** MDS, DQS, Synapse Link, Hot Add CPU, Purview Access Policies
- **PREVIEW_FEATURES database option:** Enables features that are in preview at GA
- **BI Services:** Power BI Report Server replaces SSRS for paid licenses; SSAS improvements; SSIS still supported

---

## MODULE 2: AI BUILT-IN (~90 min including demos)

---

### Slide 10: What Problems Are We Trying to Solve with AI?
- Smarter searching on existing text data
- Centralized vector searching across documents
- Building blocks for intelligent assistants, RAG, AI Agents
- Taking advantage of AI in a secure, scalable fashion
- Overcoming complexity by using familiar T-SQL

### Slide 11: Vector Search with Your Data
- The RAG pattern explained: Prompt → Embedding → Vector Store → Search → LLM → Response
- Key insight: "The prompt may contain words not found in your data!" — this is why semantic/vector search matters
- Hybrid search: combining vector similarity with traditional SQL filters
- Security: all access controlled through standard SQL Server security model
- Works ground and cloud

### Slide 12: Building Scalable AI Applications — Agentic RAG
- **Vector Search:** Retrieve most semantically relevant data to ground LLMs
- **Operational RAG:** Store vectors and data together for consistency
- **Structured Queries:** Allow LLMs to query structured data with rich metadata and query optimization

### Slide 13: Build Enterprise AI-Ready Applications — Ground to Cloud
- **Vector Store:** Native `vector` data type and DiskANN index (PREVIEW_FEATURES)
- **Model Management:** Declarative model definitions via `CREATE EXTERNAL MODEL`
- **Embeddings Built-In:** Text chunking and built-in multimodal embedding generation
- **Simple Semantic Searching:** `VECTOR_DISTANCE` (KNN) and `VECTOR_SEARCH` (ANN)
- **Build Agentic RAG Patterns:** Inside the engine using T-SQL
- **Framework Integration:** LangChain, Semantic Kernel, EF Core

### Slide 14: SQL Server 2025 Vector Architecture (Deep Dive)
- Step-by-step walkthrough:
  1. **Model Definition** — `CREATE EXTERNAL MODEL` pointing to Azure OpenAI, OpenAI, Ollama, ONNX Runtime, KServe, vLLM, etc.
  2. **Generate Embeddings** — T-SQL commands to generate embeddings from your data
  3. **Create a Vector Index** — DiskANN-based indexing for approximate nearest neighbor
  4. **T-SQL Prompt** — User submits a natural language prompt
  5. **Generate Prompt Embedding** — Same model generates an embedding for the prompt
  6. **Vector Search** — `VECTOR_DISTANCE` or `VECTOR_SEARCH` compares prompt to stored data
  7. **Other Filters** — Standard SQL WHERE clauses for hybrid search
- Extensibility via `sp_invoke_external_rest_endpoint` for any REST model endpoint
- You control security: SQL permissions govern model access, data access, and auditing

### Slide 15: Security, SQL, and AI
- You control all access with SQL security
- You control which AI models to use
- AI models (ground and/or cloud) are isolated from SQL Server
- Use RLS, TDE, and Dynamic Data Masking on vector data
- Track everything with SQL Server Auditing
- Ledger for chat history and feedback

### Slide 16: Vector Data Type Deep Dive
- New native `vector` data type — stores arrays of floating-point numbers
- Configurable dimensions (e.g., 1536 for OpenAI, 384 for smaller models)
- Driver support across all major SQL client libraries
- Storage optimization for efficient I/O

### Slide 17: Embedding Generation and Text Chunking
- Built-in T-SQL functions for generating embeddings
- Text chunking: breaking large text into model-appropriate segments
- Multi-modal embedding support
- Works with any REST-accessible embedding model

### Slide 18: DiskANN Index and VECTOR_SEARCH
- DiskANN: Microsoft Research technology for billion-scale ANN search
- How it differs from brute-force `VECTOR_DISTANCE` (KNN)
- `VECTOR_SEARCH` syntax and usage
- Index maintenance considerations
- Current limitations and roadmap

> **🔬 DEMO: Intelligent Search in SQL Server 2025**
> - Repo: `sql2025book` — AI / Vectors chapter demos
> - Supplemental: `demos/sqlserver2025` — AI folder (four provider integrations)
> - Walkthrough:
>   - Show existing search methods (LIKE, Full-Text) and their limitations
>   - Create an external model definition (Azure OpenAI or Ollama)
>   - Create a table with a `vector` column
>   - Generate embeddings for AdventureWorks product descriptions
>   - Run `VECTOR_DISTANCE` queries with natural language prompts
>   - Demonstrate hybrid search (vector + SQL WHERE clause)
>   - Show the four different AI provider integrations (Azure OpenAI, OpenAI, Ollama, ONNX)
> - **Talking point:** "AdventureWorks needs better searching" — show how semantic search finds products a keyword search would miss

---

*☕ BREAK (~15 min)*

---

## MODULE 3: DEVELOPERS, DEVELOPERS, DEVELOPERS (~90 min including demos)

---

### Slide 19: Built for Developers — Develop Modern Data Applications
- Native JSON data type with indexing and new T-SQL functions
- Change Event Streaming (CES) for near-real-time event-driven architectures
- REST API connectivity via `sp_invoke_external_rest_endpoint`
- GraphQL support via Data API Builder
- Regular Expressions in T-SQL
- New T-SQL functions and enhancements
- Microsoft Python Driver for SQL Server
- GitHub Copilot for SQL (VS Code mssql extension + SSMS 22)

### Slide 20: Native JSON
- **Before 2025:** JSON stored as `varchar/nvarchar`, any standard index, various functions
- **SQL Server 2025:** New `json` data type — binary storage up to 2GB, dedicated json index, automatic validation
- New functions: `JSON_OBJECTAGG`, `JSON_ARRAYAGG`, `JSON_CONTAINS`, `JSON_QUERY WITH ARRAY WRAPPER`
- Benefits: compressed storage, less I/O, fewer page reads, built-in schema validation
- Use cases: REST APIs, configuration storage, document-style data, flexible schemas, e-commerce catalogs

> **🔬 DEMO: Native JSON**
> - Repo: `sql2025book` — Developers chapter demos
> - Supplemental: `demos/sqlserver2025/json`
> - Walkthrough:
>   - Create a table with the new `json` data type
>   - Insert JSON documents and show automatic validation
>   - Compare storage size vs. `nvarchar(max)` approach
>   - Demonstrate json indexing and query performance
>   - Use new JSON aggregate functions
>   - Show `JSON_CONTAINS` for membership testing
> - **Talking point:** "Developers need to store JSON in SQL Server" — this is no longer a workaround, it's a first-class citizen

### Slide 21: Some T-SQL Love
- **RegEx functions:** Pattern matching, extraction, replacement using regular expressions
- **BASE64 functions:** Encode/decode for binary-to-text scenarios
- **`PRODUCT()` aggregate:** Multiplicative aggregate function
- **Fuzzy string match functions:** Approximate matching for data quality
- **`||` string concat operator:** ANSI standard concatenation
- **`CURRENT_DATE`:** Returns `DATE` type (no more `CAST(GETDATE() AS DATE)`)
- **`SUBSTRING()` optional length:** Omit length to get "rest of string"
- **`DATEADD()` supports `bigint`:** Handle larger date offsets
- **`UNISTR()`:** Unicode string construction

> **🔬 DEMO: T-SQL Enhancements** (brief, can be woven into other demos)
> - Repo: `sql2025book` — Developers chapter demos
> - Show RegEx pattern matching on AdventureWorks data
> - Demonstrate `||` operator, `CURRENT_DATE`, `PRODUCT()` aggregate
> - Quick comparison: old way vs. new way for common patterns

### Slide 22: GitHub Copilot for SQL
- Copilot integration in VS Code mssql extension
- Copilot integration in SSMS 22 (public preview)
- AI-assisted T-SQL authoring, query explanation, and optimization suggestions
- Context-aware: understands your schema, tables, and relationships

> **🧪 DEMO: GitHub Copilot for SQL**
> - Show Copilot generating queries from natural language in VS Code
> - Show Copilot explaining existing complex queries
> - Show Copilot suggesting optimizations
> - ~2 min demo

### Slide 23: Change Event Streaming (CES)
- Stream data changes in near-real-time from SQL directly to Azure Event Hubs
- Enables event-driven architectures, microservices integration, real-time analytics, AI Agents
- Push-based (unlike CT/CDC which are pull-based)
- "IO-less" — reads committed transactions from the transaction log
- DDL change support

### Slide 24: Capturing Changes — CT vs CDC vs CES
- **Change Tracking (CT):** Sync capture, system tables (minimal), row identifier, pull-based, immediate
- **Change Data Capture (CDC):** Async from log, system tables (extra logging), row + data, pull-based, near-real-time, requires SQL Agent
- **Change Event Streaming (CES):** Async from log, event stream ("IO-less"), row + data + DDL, push-based, near-real-time, single destination
- Typical use cases: CT → cache invalidation/sync; CDC → data warehousing/auditing; CES → event-driven architectures, microservices, real-time analytics, AI Agents

### Slide 25: CES Architecture — Contoso Shipping Example
- Scenario: Contoso shipping uses CES to detect order changes
- Flow: Order changes → CES → Azure Event Hub → Azure Functions → Azure AI Foundry → resolve shipping issues → update estimated ship date
- Demonstrates: real-world event-driven architecture with AI agent integration

> **🔬 DEMO: Change Event Streaming**
> - Repo: `sql2025book` — Developers chapter / CES demos
> - Walkthrough:
>   - Set up CES on a table
>   - Make data changes and observe events streaming to Event Hub
>   - Show the event payload structure
>   - Discuss integration patterns with Azure Functions and AI Agents
> - **Talking point:** "Contoso needs help with shipping problems" — show how CES enables reactive, AI-powered solutions
> - ~5-6 min demo

### Slide 26: REST API Connectivity
- `sp_invoke_external_rest_endpoint` — connect to any REST interface from T-SQL
- Not limited to AI models: any REST service, GraphQL endpoint, webhook
- Enables SQL Server as an orchestration hub for external services
- Data API Builder for GraphQL support

### Slide 27: Developer Edition Changes
- Choose your target production deployment: Standard or Enterprise
- Develop and test with no license costs
- Features and limits now match your target deployment edition
- Two flavors: Developer Standard Edition and Developer Enterprise Edition

---

*🍽️ LUNCH BREAK (~60 min)*

---

## MODULE 4: THE CORE ENGINE — SECURITY (~45 min including demos)

---

### Slide 28: Secure by Default — Provide the Latest Security Capabilities
- Microsoft Entra authentication (building on SQL 2022)
- **New:** Managed Identity support — both inbound and outbound
  - Authentication using system-assigned managed identity
  - Backup to URL with managed identity
  - Managed identity support for EKM (Extensible Key Management)
  - Managed identity for AI model access
- Enabled by Azure Arc
- Microsoft Defender integration for SQL Server

### Slide 29: Security Enhancements — Full List
- Security cache improvements (better application concurrency)
- OAEP support for encryption
- PBKDF password hashing
- Entra logins with non-unique display names
- Custom password policy on Linux
- TDS 8.0 / TLS 1.3 support for tools

> **🔬 DEMO: Managed Identity and Security**
> - Repo: `sql2025book` — Security chapter demos
> - Walkthrough:
>   - Show Managed Identity configuration via Arc
>   - Demonstrate passwordless authentication for inbound connections
>   - Show outbound Managed Identity for backup to URL
>   - Demonstrate Managed Identity for AI model access (ties back to Module 2)
> - Discuss: how Managed Identity eliminates credential management and reduces attack surface

---

## MODULE 5: THE CORE ENGINE — PERFORMANCE & CONCURRENCY (~60 min including demos)

---

### Slide 30: Mission Critical Engine — Performance and Availability
- Three areas of investment: Improve Concurrency, Accelerate Performance, Increase HADR
- "Everything in this space is done to make sure you get faster with no code changes required"

### Slide 31: Optimized Locking
- Forget about lock escalation — hands-free lock management built into the engine
- Transaction ID (TID) locking replaces traditional row/page/table lock escalation
- Already proven in Azure SQL Database
- Dramatically improves concurrency for update-heavy workloads
- Reduces lock memory overhead
- No application code changes required

> **🔬 DEMO: Improving Application Concurrency with Optimized Locking**
> - Repo: `sql2025book` — Core Engine chapter demos
> - Supplemental: `demos/sqlserver2025/optimizedlocking`
> - Walkthrough:
>   - Show traditional locking behavior with concurrent updates
>   - Enable optimized locking
>   - Re-run the same workload and observe eliminated lock escalation
>   - Show reduced lock memory consumption
>   - Monitor with DMVs to see TID locking in action
> - **Talking point:** "Developers need better concurrency and don't want to worry about locking internals"
> - ~3 min demo

### Slide 32: Intelligent Query Processing (IQP) Enhancements
- CE (Cardinality Estimator) feedback for expressions
- Optional parameter plans optimization (building on PSP optimization from 2022)
- DOP (Degree of Parallelism) feedback — now ON by default
- Optimized `sp_executesql` — better plan reuse for parameterized queries
- Batch mode optimizations — improved performance for aggregate queries and large scans

### Slide 33: Query Store Enhancements
- Query Store on readable secondary replicas — persist stats on secondaries
- Better insight into read workload performance on AG replicas
- Enhanced diagnostics for query performance regression

### Slide 34: Columnstore Index Improvements
- Better ordered columnstore indexing
- Columnstore index maintenance improvements
- Performance enhancements for columnstore queries

### Slide 35: Other Performance Enhancements
- `ABORT_QUERY_EXECUTION` query hint — forcefully terminate long-running queries
- Tempdb space resource governance via Resource Governor workload groups
- ADR (Accelerated Database Recovery) in tempdb
- `tmpfs` support for tempdb on Linux
- Remove In-Memory OLTP from a database (finally!)
- Persisted statistics for readable secondaries
- Change tracking cleanup improvements

> **🔬 DEMO: Tempdb Resource Governance**
> - Repo: `sql2025book` — Core Engine chapter demos
> - Supplemental: `demos/sqlserver2025/tempdb_rg`
> - Walkthrough:
>   - Configure Resource Governor workload groups with tempdb space limits
>   - Run a query that attempts to consume excessive tempdb
>   - Show the query being terminated when it exceeds its allocation
>   - Discuss use cases: multi-tenant environments, runaway query protection, shared BI environments
> - Note: Full Resource Governor is now available in Standard Edition!

> **🧪 DEMO: ABORT_QUERY_EXECUTION Hint**
> - Repo: `demos/sqlserver2025/ABORT_QUERY_EXECUTION`
> - Show how to use the hint to kill a long-running query after a threshold
> - Practical for BI/reporting environments with unpredictable query patterns

### Slide 36: Batch Mode Processing — How It Works
- Batch vs. Row mode processing
- Array of column values (~900 rows per batch, ~64KB memory pages)
- Contiguous column data enables vectorized execution leveraging AVX instructions
- Works for both columnstore AND rowstore (batch mode on rowstore)
- SQL Server 2025 batch mode optimizations further improve this pipeline

---

*☕ BREAK (~15 min)*

---

## MODULE 6: THE CORE ENGINE — AVAILABILITY GROUPS (~60 min including demos)

---

### Slide 37: Availability Group Enhancements Overview
- "Customers love Always On Availability Groups but there are situations where they get stuck in a not synchronizing state"
- SQL Server 2025 enhances AG algorithms for reliable failover

### Slide 38: Reliable Failover and Health Diagnostics
- Fast failover for persistent AG health events
- Improved health diagnostics — better visibility into AG state
- Communication control flow tuning
- Switching to resolving state improvements

### Slide 39: AG Tuning and Configuration
- AG group commit waiting tuning — optimize for throughput vs. latency
- Async page request dispatching
- Remove listener IP address (simplify configurations)
- `NONE` routing option for routing lists
- Contained AG support for Distributed Availability Groups (DAG)
- DAG sync improvements

### Slide 40: Backup Enhancements
- Backups on secondary replicas — offload backup workload
- **ZSTD backup compression** — significantly faster and better compression ratios than legacy algorithm
- Backup to Azure immutable storage — compliance and ransomware protection
- Backup to URL with Managed Identity — passwordless backup to Azure

> **🔬 DEMO: Availability Group Reliability and Diagnostics**
> - Repo: `sql2025book` — Availability chapter demos
> - Walkthrough:
>   - Set up or use a pre-configured AG environment
>   - Demonstrate the improved health diagnostics DMVs
>   - Simulate a scenario that previously caused "not synchronizing" state
>   - Show how SQL 2025 handles it with reliable failover
>   - Demonstrate ZSTD backup compression: compare backup sizes and speeds vs. legacy compression
>   - Show backup to secondary replica

> **🔬 DEMO: AG Tuning**
> - Repo: `sql2025book` — Availability chapter demos
> - Show group commit waiting tuning parameters
> - Demonstrate contained AG with DAG configuration
> - Walk through the new diagnostics views

---

## MODULE 7: CONNECTED WITH ARC (~45 min including demos)

---

### Slide 41: Azure Arc for SQL Server — The Management Plane
- Arc enables cloud management for on-premises and multi-cloud SQL Server
- Foundation for: Managed Identity, Entra authentication, Microsoft Defender, Azure policies
- Enables mirroring to Fabric, backup to Azure, and AI model security

### Slide 42: What Arc Enables for SQL Server 2025
- **Security:** Managed Identity (inbound + outbound), Entra authentication, Defender
- **Management:** Azure Portal visibility, Azure Policy for SQL, inventory and governance
- **AI:** Secure model access via Arc-managed credentials
- **Fabric:** Mirroring configuration and management
- **Backup:** Backup to URL with Managed Identity, immutable storage

### Slide 43: Arc Architecture and Setup
- Arc agent installation and onboarding
- Connecting SQL Server instances to Azure Arc
- Azure resource representation of on-premises SQL instances
- RBAC and governance through Azure

> **🔬 DEMO: Azure Arc Integration**
> - Repo: `sql2025book` — Arc chapter demos
> - Walkthrough:
>   - Show an Arc-connected SQL Server 2025 instance in the Azure Portal
>   - Walk through Managed Identity configuration
>   - Demonstrate Entra authentication flow enabled by Arc
>   - Show Azure Policy enforcement on the SQL instance
>   - Demonstrate how Arc enables secure AI model access (connect back to Module 2)
>   - Show Defender for SQL alerts and recommendations

---

## MODULE 8: FABRIC INTEGRATION & MIRRORING (~30 min)

---

### Slide 44: Integrate Your Data with Microsoft Fabric
- Database mirroring to Fabric: near-real-time replication
- Uses "change feed" to read committed transaction log changes
- Pushes data to Microsoft Fabric OneLake in Delta Parquet format
- Unlocks: unified analytics, data exploration, Power BI, Copilot experiences
- `aka.ms/sqlmirroring`

### Slide 45: Mirroring Architecture
- SQL Server 2025 → Change Feed → OneLake (Delta Parquet)
- SQL Analytics Endpoint in Fabric for querying
- Lakehouse and warehouse integration
- Near-real-time latency
- No ETL pipeline required

### Slide 46: Use Cases for Fabric Mirroring
- Offload read/analytics workloads from production SQL Server
- Enable Power BI real-time dashboards on operational data
- Cross-platform analytics: combine SQL Server data with other Fabric sources
- AI/ML training data pipelines

> Note: Mirroring demos require Azure Fabric access. Consider a pre-recorded walkthrough or Azure portal demonstration if live Fabric isn't available.

---

## MODULE 9: WRAP-UP & CALL TO ACTION (~15 min)

---

### Slide 47: Customer Experiences
- Highlight real customer quotes and use cases:
  - Performance benefits of optimized locking and ZSTD backup compression
  - Enhanced AG reliability
  - Semantic search and RAG capabilities for GenAI solutions
  - CES and Fabric Mirroring for bridging operational data to analytics

### Slide 48: Edition Highlights Recap
- **Express:** Now supports 50GB database, many new features included
- **Standard:** Core limit increased from 24 → 32, memory from 128GB → 256GB, full Resource Governor
- **Enterprise:** All features, DiskANN vector index, all AG enhancements
- **Developer:** Free for dev/test, now in Standard and Enterprise flavors

### Slide 49: Resources & Call to Action
- Read the blogs: `aka.ms/sqlserver2025`
- Read the docs: `aka.ms/sqlserver2025docs`
- Get the demos: `aka.ms/sqlserver2025demos`
- Get the book: `aka.ms/sql2025book` — *SQL Server 2025 Unveiled* by Bob Ward (Apress)
- Download: `aka.ms/getsqlserver2025`

### Slide 50: Q&A / Open Discussion
- Open floor for questions
- Discuss attendees' upgrade/migration plans
- Share experiences and scenarios

---

## APPENDIX: DEMO INVENTORY FROM BOBSQL REPO

### From `sql2025book` (organized by book chapter):
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

## TIMING SUMMARY

| Module | Topic | Time |
|---|---|---|
| 1 | Welcome & Big Picture | 45 min |
| 2 | AI Built-In | 90 min |
| — | *Break* | 15 min |
| 3 | Developers | 90 min |
| — | *Lunch* | 60 min |
| 4 | Core Engine — Security | 45 min |
| 5 | Core Engine — Performance & Concurrency | 60 min |
| — | *Break* | 15 min |
| 6 | Core Engine — Availability Groups | 60 min |
| 7 | Connected with Arc | 45 min |
| 8 | Fabric Integration & Mirroring | 30 min |
| 9 | Wrap-Up & Q&A | 15 min |
| | **Total** | **~8.5 hours** |

> Adjust timing based on audience engagement, demo complexity, and Q&A. The AI and Developer modules can be trimmed if running long; the Arc and Fabric modules can be expanded with live Azure Portal walkthroughs if time permits.