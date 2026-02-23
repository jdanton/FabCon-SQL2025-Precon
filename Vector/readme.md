# Formula 1 Race Recaps — SQL Server 2025 Vector Search Demo

## Overview

This demo showcases **native vector search** in SQL Server 2025 using a collection of 50 iconic Formula 1 race recaps spanning 1976-2024. Each recap is a rich text summary of a memorable Grand Prix moment — rain chaos, championship heartbreak, miraculous crashes, underdog victories, and controversial decisions.

The demo walks through the full journey: from traditional keyword search (and its limitations) to embedding generation with Ollama, to semantic vector search that understands **meaning**, not just keywords.

### The Problem

Ask a database: *"Find races where rain completely changed the outcome."*

- `WHERE Recap LIKE '%rain%changed%'` → almost nothing. Recaps use words like "downpour", "treacherous", "soaked", "aquaplaning" — none of which match the keyword pattern.
- Vector search understands that these words are **semantically similar** and returns Brazil 2008, Canada 2011, Germany 2019, and more.

### Why F1?

Race recaps are perfect for vector search because they're written in rich, varied natural language. The same concept (e.g., "a dramatic comeback") appears across dozens of recaps using completely different vocabulary — exactly the scenario where keyword search fails and semantic search shines.

## Architecture

```
┌──────────────────────────────────┐       ┌──────────────────────┐
│   SQL Server 2025                │       │  Ollama (local)      │
│   Database: VectorF1             │       │  http://localhost:    │
│                                  │       │         11434         │
│   Tables:                        │       │                      │
│    ├─ Circuits (25 tracks)      │       │  Model:              │
│    └─ RaceRecaps (50 races)     │  ◄──► │  nomic-embed-text    │
│        └─ RecapEmbedding         │       │  (768 dimensions)    │
│           VECTOR(768)            │       │                      │
│                                  │       └──────────────────────┘
│   Index:                         │
│    └─ DiskANN vector index       │
│       (approximate NN search)    │
│                                  │
│   Functions:                     │
│    ├─ AI_GENERATE_EMBEDDINGS()   │
│    ├─ VECTOR_DISTANCE()  (KNN)   │
│    └─ VECTOR_SEARCH()    (ANN)   │
└──────────────────────────────────┘
```

Everything runs locally — no cloud services required. Ollama provides the embedding model, SQL Server stores and searches the vectors.

## Prerequisites

1. **SQL Server 2025** (CTP 2.1 or later)
2. **Ollama** installed and running locally
3. **SSMS** or **Azure Data Studio** for running the SQL scripts

### Ollama Setup

Install Ollama from [ollama.com](https://ollama.com), then pull the embedding model:

```bash
# Start Ollama (if not already running)
ollama serve

# Pull the embedding model (~275 MB download)
ollama pull nomic-embed-text
```

Verify it's working:

```bash
curl http://localhost:11434/api/tags
```

You should see `nomic-embed-text` in the model list.

## Demo Files

| # | File | Purpose |
|---|------|---------|
| 01 | `01_create_database.sql` | Creates `VectorF1` database and enables preview features |
| 02 | `02_create_tables.sql` | Creates `Circuits` and `RaceRecaps` tables with `VECTOR(768)` column |
| 03 | `03_seed_data.sql` | Inserts 25 circuits and 50 iconic F1 race recaps (1976-2024) |
| 04 | `04_traditional_search.sql` | Demonstrates keyword search limitations with 5 queries |
| 05 | `05_configure_model.sql` | Creates external model definition pointing to Ollama |
| 06 | `06_generate_embeddings.sql` | Generates embeddings for all recaps and creates DiskANN index |
| 07 | `07_vector_search.sql` | Runs the same 5 queries using vector search — dramatically better results |
| 08 | `08_hybrid_search.sql` | Combines vector search with SQL WHERE clauses and JOINs |
| 09 | `09_cleanup.sql` | Drops everything |

## Step-by-Step Demo

### Step 1: Create the Database (Script 01)

Run `01_create_database.sql` to create the `VectorF1` database and enable the preview features required for DiskANN indexing and vector functions.

### Step 2: Create Tables (Script 02)

Run `02_create_tables.sql` to create:
- **Circuits** — 25 F1 circuits with metadata (country, length, type)
- **RaceRecaps** — Main table with a `VECTOR(768)` column for storing embeddings, plus metadata columns (Year, Winner, Weather, SafetyCar, RedFlag, ChampionshipDecider) used for hybrid filtering

### Step 3: Seed Data (Script 03)

Run `03_seed_data.sql` to insert 25 circuits and 50 iconic race recaps covering:
- Rain classics (Brazil 2008, Canada 2011, Germany 2019)
- Championship deciders (Abu Dhabi 2021, Brazil 2008, Abu Dhabi 2010)
- Crashes and safety (Grosjean 2020, Lauda 1976, Senna 1994)
- Comebacks (Button Canada 2011, Perez Sakhir 2020, Raikkonen Suzuka 2005)
- Controversies (Abu Dhabi 2021, Indianapolis 2005, Suzuka 1989)
- Emotional moments (Vettel farewell 2022, Gasly Monza 2020, Leclerc Monaco 2024)

### Step 4: Traditional Search — The Problem (Script 04)

Run each query in `04_traditional_search.sql` **one at a time** and observe the results. These 5 queries use `LIKE` to search for natural language concepts:

1. *"Races where rain changed the outcome"* — misses "downpour", "soaked", "wet-weather"
2. *"Incredible comeback from last place"* — misses "recovery drive", "fought through the field"
3. *"Heartbreaking championship defeat"* — word may not appear at all
4. *"Terrifying crash where driver survived"* — misses "fireball", "inferno"
5. *"Controversial decision that decided a championship"* — too specific for exact keywords

**This is the problem vector search solves.** Keep these results in mind for Step 7.

### Step 5: Configure the Model (Script 05)

Run `05_configure_model.sql` to create an external model definition pointing to Ollama:

```sql
CREATE EXTERNAL MODEL OllamaEmbedding
    WITH (
        MODEL_TYPE = EMBEDDINGS,
        API_TYPE = OLLAMA,
        LOCATION = 'http://localhost:11434',
        MODEL = 'nomic-embed-text'
    );
```

The script verifies connectivity by generating a test embedding.

### Step 6: Generate Embeddings (Script 06)

Run `06_generate_embeddings.sql`. This calls Ollama for every recap and stores the resulting 768-dimensional vector in the `RecapEmbedding` column. **This takes 1-2 minutes** depending on your hardware.

After embeddings are generated, the script creates a **DiskANN vector index** for fast approximate nearest neighbor search.

### Step 7: Vector Search — The Solution (Script 07)

Run each query in `07_vector_search.sql` **one at a time**. These are the **exact same 5 questions** from Step 4, now answered with vector search:

1. *"Rain changed the outcome"* → finds Brazil 2008, Canada 2011, Germany 2019
2. *"Incredible comeback"* → finds Button Canada 2011, Perez Sakhir 2020
3. *"Heartbreaking championship defeat"* → finds Brazil 2008 (Massa), Abu Dhabi 2010
4. *"Terrifying crash"* → finds Grosjean 2020, Lauda 1976, Zhou Silverstone 2022
5. *"Controversial decision"* → finds Abu Dhabi 2021, Silverstone 2021

Each query shows both methods:
- **KNN** (exact): `VECTOR_DISTANCE('cosine', ...)` — scans all rows
- **ANN** (approximate): `VECTOR_SEARCH(...)` — uses the DiskANN index, much faster

### Step 8: Hybrid Search — The Killer Feature (Script 08)

Run `08_hybrid_search.sql` to see what makes SQL Server's vector search unique: combining semantic similarity with traditional SQL filters in a **single query**.

Examples:
- *"Rain chaos"* filtered to `WHERE Year BETWEEN 2015 AND 2024`
- *"Championship battle"* filtered to `WHERE ChampionshipDecider = 1`
- *"Incredible comeback"* filtered to `WHERE Winner = 'Hamilton'`
- *"Street circuit drama"* with a `JOIN` to the Circuits table
- **"More like this"**: given Abu Dhabi 2021's embedding, find the 5 most similar races

This is the key differentiator vs standalone vector databases — no separate system, no data duplication, full relational power.

### Step 9: Cleanup (Script 09)

Run `09_cleanup.sql` when finished to drop the vector index, external model, and database.

## SQL Server 2025 Features Demonstrated

| Feature | Description |
|---------|-------------|
| `VECTOR(768)` | Native vector data type for storing embeddings |
| `CREATE EXTERNAL MODEL` | Register an external AI model (Ollama) with SQL Server |
| `AI_GENERATE_EMBEDDINGS()` | Generate embeddings from text using the registered model |
| `VECTOR_DISTANCE()` | Cosine similarity for exact KNN search |
| `VECTOR_SEARCH()` | Approximate nearest neighbor search using DiskANN index |
| `CREATE VECTOR INDEX ... DISKANN` | Microsoft Research DiskANN algorithm for fast ANN search |
| `PREVIEW_FEATURES` | Database-scoped flag to enable preview functionality |
| Hybrid search | Vector similarity + SQL WHERE/JOIN in a single query |

## Notes

- The `nomic-embed-text` model produces **768-dimensional** vectors. The `VECTOR(768)` column must match.
- DiskANN is a Microsoft Research algorithm optimized for disk-based approximate nearest neighbor search — it's fast even on large datasets.
- `VECTOR_DISTANCE` supports `cosine`, `dot`, and `euclidean` metrics. This demo uses `cosine`.
- Embedding generation is the slowest step (~1-2 min for 50 recaps). In production, you'd generate embeddings at insert time.
- Preview features must be enabled per-database. This is a SQL Server 2025 preview requirement.
