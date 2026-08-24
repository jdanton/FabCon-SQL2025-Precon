# Optimized Locking — SQL Server 2025

**~3 minutes.** Two acts. Act 1 is one window, one F5. Act 2 is two windows.

Every script rolls back. **No data is ever modified.**

---

## Run order

| # | Script | Where | What it does |
|---|--------|-------|--------------|
| 0 | `00_restore_adventureworks.sql` | once | Restore AdventureWorks (skip if present) |
| 1 | `01_setup.sql` | once | ADR on, RCSI off, OL off. Prints a readiness grid. |
| 2 | `02_lock_footprint.sql` | **Window A** | **Act 1** — the whole before/after in one grid |
| 3 | `03_blocker.sql` | **Window A** | **Act 2** — holds 10k rows, auto-releases after 30s |
| 4 | `04_victim.sql` | **Window B** | **Act 2** — updates 1 row, prints how long it waited |
| 5 | `05_observe.sql` | Window C | Optional — live blocking chain |
| 6 | `99_reset.sql` | after | Restore settings. Also the panic button. |

Between the two halves of Act 2, flip the feature:

```sql
ALTER DATABASE [AdventureWorks] SET OPTIMIZED_LOCKING = ON WITH ROLLBACK IMMEDIATE;
```

---

## Act 1 — the lock footprint (one window)

`02_lock_footprint.sql` runs the same UPDATE four times and prints one grid.
Measured on SQL Server 2025 CU2 / AdventureWorks2022:

| Rows | OptLock | Update ms | Total Locks | Row Locks | Page Locks | Table Lock | TID Lock | Escalated? |
|------|---------|-----------|-------------|-----------|------------|------------|----------|------------|
| 4,000 | OFF | 134 | **4,180** | 4,001 | 177 | IX | no | no |
| 4,000 | ON | 123 | **3** | 0 | 0 | IX | **yes** | no |
| 10,000 | OFF | 327 | 2 | 0 | 0 | **X** | no | **YES** |
| 10,000 | ON | 342 | 3 | 0 | 0 | IX | **yes** | no |

**The two things to say:**

1. **4,180 locks become 3.** One `XACT` (TID) lock replaces 4,001 individual row locks.
   The engine stops tracking locks per row and tracks them per *transaction*.
2. **At 10,000 rows the old engine gives up and locks the whole table** (`OBJECT · X`).
   That is lock escalation. Optimized locking never escalates — still just a TID lock.

---

## Act 2 — what escalation costs you (two windows)

Window A runs `03_blocker.sql` (10,000-row update, held 30 seconds, then rolls
back on its own). While it runs, Window B runs `04_victim.sql`, which updates
**one unrelated row by clustered key** — a row the blocker never touches.

| Optimized Locking | Victim waited | Verdict |
|-------------------|---------------|---------|
| **OFF** | **22,335 ms** | Blocked by a table lock it had nothing to do with |
| **ON** | **25 ms** | Not blocked |

**~890× faster, and not one line of application code changed.** That is the
talking point: *"Developers need better concurrency and shouldn't have to
design around locking internals."*

---

## What changed in this refactor, and why

The previous version was 13 scripts with three `00_` files and two `01_` files,
no reliable run order, and no numbers anywhere. Specifically:

- **13 scripts → 7**, numbered in the order you actually run them.
- **The blocker auto-releases.** Previously you ran the first batch, switched
  windows, came back, and ran a separate `ROLLBACK TRAN` batch by hand. Miss it
  and you leave an open transaction on stage; hit F5 on the whole file and the
  update rolls back instantly and you see nothing. Now it's one F5 and it
  cleans up after itself.
- **The demo prints numbers.** Nothing in the old version measured anything.
- **Fixed a silent-failure bug.** The old victim script computed
  `MAX(SalesOrderID)` inside the session that was about to be blocked. That
  lookup is itself blocked by the table lock; if it times out the variable is
  left `NULL`, `WHERE SalesOrderID = NULL` matches zero rows, and the update
  "succeeds" instantly having proven nothing. Targets are now resolved up front
  in `01_setup.sql` and read from `dbo.OptLockDemoConfig`.
- **`Freight * .10` → `Freight * 1.0`.** The old scripts multiplied freight by
  0.1 on every run. Harmless while you roll back — destructive the one time you
  accidentally commit.
- **Dropped the two `PurchaseOrderNumber` scripts (old 08/09).** They do not
  demonstrate optimized locking. `PurchaseOrderNumber` has no index, so the
  second session scans the clustered index and hits a genuine write-write
  conflict on the locked row. Measured: **9,081 ms blocked with OL off, 9,051 ms
  with OL on.** Identical. The "two rows on the same page" framing in the
  comments was not the mechanism, and there is no improvement to show.
- **Dropped the lock-memory angle.** The deck says "show reduced lock memory
  consumption via DMVs." It does not demo: SQL Server pre-allocates lock blocks
  and `Lock Memory (KB)` reads **2,608 KB in both modes**, delta 0. Lock *count*
  is the honest metric and it is far more dramatic. Worth fixing that slide
  bullet (overview.md slide 67, demos.md Demo 7 step 4).

---

## Prerequisites and gotchas

- **ADR must be on.** Optimized locking is built on ADR's persisted version
  store and cannot be enabled without it. `01_setup.sql` handles this.
- **RCSI is ON by default in the AdventureWorks2022 backup.** Left on, readers
  never block and Act 2 is far less dramatic. `01_setup.sql` turns it off;
  `99_reset.sql` puts it back.
- **`READ_COMMITTED_SNAPSHOT` takes no `=` sign** — `SET READ_COMMITTED_SNAPSHOT OFF`.
  `ACCELERATED_DATABASE_RECOVERY` and `OPTIMIZED_LOCKING` both do take one.
- **Something wedged?** Run `99_reset.sql`. Its `WITH ROLLBACK IMMEDIATE` kills
  any transaction still open from `03_blocker.sql`.
- `04_victim.sql` sets `LOCK_TIMEOUT 60000` so a broken demo fails loudly
  instead of hanging in front of an audience.
