# SQL Server 2025: The AI-Ready Enterprise Database (Training Material)

This repository contains the overview and materials for the **FabCon SQL Server 2025 Pre-Conference Training**. This full-day session covers the new features, architecture, and capabilities of SQL Server 2025, focusing on its AI integration, developer tools, and hybrid cloud capabilities.

## 📚 Resources & Demos

The demos referenced in this training are hosted in the following Microsoft repositories:

*   **Primary Demo Repo:** [`microsoft/bobsql/tree/master/sql2025book`](https://github.com/microsoft/bobsql/tree/master/sql2025book)
    *   *Look for demos marked with 🔬 in the outline.*
*   **Supplemental Demos:** [`microsoft/bobsql/tree/master/demos/sqlserver2025`](https://github.com/microsoft/bobsql/tree/master/demos/sqlserver2025)
    *   *Look for demos marked with 🧪 in the outline.*

## 🗓️ Agenda Overview

The training is divided into several modules covering the "ground to cloud" story of SQL Server 2025.

### Module 1: Welcome & The Big Picture
*   Introduction to SQL Server 2025 as the AI-ready enterprise database.
*   Overview of the 5 pillars: AI Built-In, Security & Performance, Developer Experience, Cloud Agility, and Fabric Integration.
*   Architecture deep dive and new tooling (SSMS 22, VS Code extensions).

### Module 2: AI Built-In
*   **Vector Search:** Understanding RAG patterns, embeddings, and vector stores.
*   **Native AI Features:** `vector` data type, `VECTOR_DISTANCE`, and `CREATE EXTERNAL MODEL`.
*   Building scalable AI applications and "Agentic RAG" using T-SQL.

### Module 3: Develop Modern Data Applications
*   **REST API:** Automatic REST endpoints for stored procedures.
*   **JSON Enhancements:** Native JSON type and performance improvements.
*   **Regular Expressions:** Native regex support in T-SQL.
*   **GitHub Copilot:** AI assistance for SQL development in VS Code and SSMS.

### Module 4: Integrate Your Data with Fabric
*   **Mirroring:** Near-real-time data replication to Fabric.
*   **OneLake:** Accessing SQL Server data in OneLake.
*   **Hybrid Analytics:** Combining operational data with advanced analytics in Fabric.

### Module 5: Secure by Default & Mission Critical
*   **Security:** Microsoft Entra authentication, Ledger, and Defender for SQL.
*   **Performance:** Intelligent Query Processing (IQP) Next Gen, Optimized Locking.
*   **High Availability:** Always On availability group enhancements.

## 🛠️ Prerequisites for Demos

To run the demos associated with this training, you will typically need:
*   **SQL Server 2025** (Developer Edition or higher).
*   **SQL Server Management Studio (SSMS) 22** or **Azure Data Studio**.
*   **Visual Studio Code** with the **mssql** extension.
*   **Azure Subscription** (required for features involving Azure OpenAI, Arc, or Fabric).
*   **Python/Notebook Environment** (for some AI-related demos).

---
*Check [overview.md](./overview.md) for the detailed slide-by-slide outline.*
