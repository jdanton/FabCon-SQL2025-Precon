// ============================================================================
// F1 Race Event Consumer
// Reads CloudEvents from Azure Event Hubs (streamed by SQL Server 2025 CES)
// and displays them as a live race operations feed.
//
// Usage:
//   1. Update the configuration constants below
//   2. dotnet run
//   3. Run the SQL scripts in SSMS side-by-side
// ============================================================================

using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using System.Text;
using System.Text.Json;

namespace F1RaceEventConsumer;

class Program
{
    // ═══════════════════════════════════════════════════════════════════════
    // CONFIGURATION — Update these values for your environment
    // ═══════════════════════════════════════════════════════════════════════

    // Event Hubs connection string (from Azure portal > Event Hubs namespace > Shared access policies)
    const string EventHubConnectionString = "<YourEventHubsConnectionString>";

    // The Event Hub instance name (e.g., "f1-race-events")
    const string EventHubName = "<YourEventHubsInstance>";

    // Azure Blob Storage connection string (used for checkpointing)
    // The processor tracks which events have been read so it can resume after restarts.
    const string BlobStorageConnectionString = "<YourBlobStorageConnectionString>";

    // Blob container name for checkpoints
    const string BlobContainerName = "f1-ces-checkpoints";

    // Consumer group (use $Default for Basic tier Event Hubs)
    const string ConsumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;

    // ═══════════════════════════════════════════════════════════════════════

    static int _eventCount = 0;

    static async Task Main(string[] args)
    {
        PrintBanner();

        // Create the blob container client for checkpoint storage
        var storageClient = new BlobContainerClient(BlobStorageConnectionString, BlobContainerName);
        await storageClient.CreateIfNotExistsAsync();

        // Create the Event Processor
        var processor = new EventProcessorClient(
            storageClient,
            ConsumerGroup,
            EventHubConnectionString,
            EventHubName);

        // Wire up event handlers
        processor.ProcessEventAsync += ProcessEventHandler;
        processor.ProcessErrorAsync += ProcessErrorHandler;

        // Start processing
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine("  Connecting to Azure Event Hubs...");
        Console.ResetColor();

        await processor.StartProcessingAsync();

        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine("  CONNECTED. Listening for race events...");
        Console.WriteLine("  Run the SQL scripts in SSMS to generate events.");
        Console.WriteLine("  Press any key to stop.\n");
        Console.ResetColor();

        PrintSeparator();

        // Wait for user to stop
        Console.ReadKey(intercept: true);

        Console.WriteLine("\n  Stopping processor...");
        await processor.StopProcessingAsync();
        Console.WriteLine($"  Done. Processed {_eventCount} events total.");
    }

    /// <summary>
    /// Processes each event received from the Event Hub.
    /// Parses the CloudEvent payload and displays it as an F1 race feed.
    /// </summary>
    static async Task ProcessEventHandler(ProcessEventArgs args)
    {
        if (args.Data == null) return;

        Interlocked.Increment(ref _eventCount);

        try
        {
            var body = Encoding.UTF8.GetString(args.Data.Body.ToArray());
            var cloudEvent = JsonSerializer.Deserialize<JsonElement>(body);

            // Extract CloudEvent metadata
            var source = GetString(cloudEvent, "source");
            var time = GetString(cloudEvent, "time");
            var data = cloudEvent.GetProperty("data");

            // Extract CES-specific fields
            var schema = GetString(data, "schema");
            var table = GetString(data, "table");
            var operation = GetString(data, "operation");

            // Format and display based on table
            DisplayEvent(table, operation, time, data);
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"  [ERROR] Failed to parse event: {ex.Message}");
            Console.ResetColor();

            // Still display raw payload for debugging
            var raw = Encoding.UTF8.GetString(args.Data.Body.ToArray());
            Console.ForegroundColor = ConsoleColor.DarkGray;
            Console.WriteLine($"  Raw: {Truncate(raw, 200)}");
            Console.ResetColor();
        }

        // Checkpoint so we don't reprocess on restart
        await args.UpdateCheckpointAsync();
    }

    /// <summary>
    /// Displays a formatted event based on its table and operation type.
    /// </summary>
    static void DisplayEvent(string table, string operation, string time, JsonElement data)
    {
        var timestamp = FormatTimestamp(time);
        var opLabel = FormatOperation(operation);
        var columns = data.TryGetProperty("columns", out var cols) ? cols : data;

        switch (table)
        {
            case "LiveTiming":
                DisplayLiveTimingEvent(timestamp, opLabel, operation, columns, data);
                break;

            case "PitStops":
                DisplayPitStopEvent(timestamp, opLabel, columns);
                break;

            case "RaceControl":
                DisplayRaceControlEvent(timestamp, opLabel, columns);
                break;

            case "Races":
                DisplayRaceStatusEvent(timestamp, opLabel, operation, columns, data);
                break;

            case "Drivers":
                DisplayDriverEvent(timestamp, opLabel, columns);
                break;

            default:
                DisplayGenericEvent(timestamp, table, opLabel, columns);
                break;
        }
    }

    static void DisplayLiveTimingEvent(string ts, string op, string opCode, JsonElement cols, JsonElement data)
    {
        var driverId = GetInt(cols, "DriverId");
        var lap = GetInt(cols, "Lap");
        var position = GetInt(cols, "Position");
        var tire = GetString(cols, "TireCompound");
        var tireAge = GetInt(cols, "TireAge");
        var gap = GetInt(cols, "GapToLeaderMs");
        var inPit = GetBool(cols, "InPit");
        var isActive = GetBool(cols, "IsActive");
        var lapTimeMs = GetInt(cols, "LapTimeMs");
        var drs = GetBool(cols, "DRS");

        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write($"  {ts} ");

        // Show position changes for UPD events
        if (opCode == "UPD" && data.TryGetProperty("old_columns", out var oldCols))
        {
            var oldPos = GetInt(oldCols, "Position");
            if (oldPos > 0 && oldPos != position)
            {
                Console.ForegroundColor = position < oldPos ? ConsoleColor.Green : ConsoleColor.Red;
                Console.Write($"[TIMING {op}] ");
                Console.Write($"Driver #{driverId} P{oldPos} → P{position}");
            }
            else
            {
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.Write($"[TIMING {op}] ");
                Console.Write($"Driver #{driverId} P{position}");
            }
        }
        else
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.Write($"[TIMING {op}] ");
            Console.Write($"Driver #{driverId} P{position}");
        }

        if (!isActive)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Write(" ■ DNF");
        }
        else if (inPit)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.Write(" ■ IN PIT");
        }

        Console.ForegroundColor = ConsoleColor.DarkGray;
        var details = new List<string>();

        if (lap > 0) details.Add($"Lap {lap}");
        if (lapTimeMs > 0) details.Add($"{FormatLapTime(lapTimeMs)}");
        if (gap > 0) details.Add($"+{gap / 1000.0:F3}s");
        details.Add($"{GetTireEmoji(tire)} {tire} (Age: {tireAge})");
        if (drs) details.Add("DRS");

        Console.Write($"  {string.Join(" | ", details)}");
        Console.ResetColor();
        Console.WriteLine();
    }

    static void DisplayPitStopEvent(string ts, string op, JsonElement cols)
    {
        var driverId = GetInt(cols, "DriverId");
        var lap = GetInt(cols, "Lap");
        var duration = GetInt(cols, "PitStopDurationMs");
        var tireIn = GetString(cols, "TireCompoundIn");
        var tireOut = GetString(cols, "TireCompoundOut");
        var stopNum = GetInt(cols, "StopNumber");
        var notes = GetString(cols, "Notes");

        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write($"  {ts} ");
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.Write($"[PIT STOP {op}] ");
        Console.ForegroundColor = ConsoleColor.White;
        Console.Write($"Driver #{driverId} Stop #{stopNum} on Lap {lap}");
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write($"  {duration / 1000.0:F3}s | {GetTireEmoji(tireIn)} {tireIn} → {GetTireEmoji(tireOut)} {tireOut}");

        if (!string.IsNullOrEmpty(notes))
        {
            Console.ForegroundColor = ConsoleColor.DarkYellow;
            Console.Write($"  \"{notes}\"");
        }

        Console.ResetColor();
        Console.WriteLine();
    }

    static void DisplayRaceControlEvent(string ts, string op, JsonElement cols)
    {
        var msgType = GetString(cols, "MessageType");
        var category = GetString(cols, "Category");
        var description = GetString(cols, "Description");
        var driverId = GetInt(cols, "DriverId");
        var lap = GetInt(cols, "Lap");

        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write($"  {ts} ");

        // Color based on category
        Console.ForegroundColor = category switch
        {
            "Safety" => ConsoleColor.Red,
            "Infringement" => ConsoleColor.Magenta,
            _ => ConsoleColor.White
        };

        Console.Write($"[RACE CTRL {op}] ");
        Console.ForegroundColor = ConsoleColor.White;

        if (lap > 0) Console.Write($"Lap {lap}: ");
        Console.Write(description);

        Console.ResetColor();
        Console.WriteLine();
    }

    static void DisplayRaceStatusEvent(string ts, string op, string opCode, JsonElement cols, JsonElement data)
    {
        var status = GetString(cols, "RaceStatus");
        var raceName = GetString(cols, "RaceName");

        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write($"  {ts} ");

        if (opCode == "UPD" && data.TryGetProperty("old_columns", out var oldCols))
        {
            var oldStatus = GetString(oldCols, "RaceStatus");

            Console.ForegroundColor = status switch
            {
                "Green" => ConsoleColor.Green,
                "SafetyCar" or "VSC" => ConsoleColor.Yellow,
                "RedFlag" => ConsoleColor.Red,
                "Finished" => ConsoleColor.White,
                _ => ConsoleColor.Cyan
            };

            Console.Write($"[RACE STATUS] ");
            Console.Write($"{oldStatus} → {status}");

            if (!string.IsNullOrEmpty(raceName))
                Console.Write($"  ({raceName})");
        }
        else
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.Write($"[RACE {op}] {raceName} - {status}");
        }

        Console.ResetColor();
        Console.WriteLine();
    }

    static void DisplayDriverEvent(string ts, string op, JsonElement cols)
    {
        var code = GetString(cols, "DriverCode");
        var name = $"{GetString(cols, "FirstName")} {GetString(cols, "LastName")}";
        var team = GetString(cols, "TeamName");

        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write($"  {ts} ");
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write($"[DRIVER {op}] ");
        Console.ForegroundColor = ConsoleColor.White;
        Console.Write($"{code} - {name} ({team})");
        Console.ResetColor();
        Console.WriteLine();
    }

    static void DisplayGenericEvent(string ts, string table, string op, JsonElement cols)
    {
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write($"  {ts} ");
        Console.ForegroundColor = ConsoleColor.Gray;
        Console.Write($"[{table.ToUpper()} {op}] ");
        Console.Write(cols.ToString()[..Math.Min(cols.ToString().Length, 120)]);
        Console.ResetColor();
        Console.WriteLine();
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    static Task ProcessErrorHandler(ProcessErrorEventArgs args)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine($"\n  [ERROR] Partition: {args.PartitionId} | {args.Exception.Message}");
        Console.ResetColor();
        return Task.CompletedTask;
    }

    static string GetString(JsonElement el, string prop)
    {
        if (el.TryGetProperty(prop, out var val) && val.ValueKind == JsonValueKind.String)
            return val.GetString() ?? "";
        return "";
    }

    static int GetInt(JsonElement el, string prop)
    {
        if (el.TryGetProperty(prop, out var val))
        {
            if (val.ValueKind == JsonValueKind.Number) return val.GetInt32();
            if (val.ValueKind == JsonValueKind.String && int.TryParse(val.GetString(), out var n)) return n;
        }
        return 0;
    }

    static bool GetBool(JsonElement el, string prop)
    {
        if (el.TryGetProperty(prop, out var val))
        {
            if (val.ValueKind == JsonValueKind.True) return true;
            if (val.ValueKind == JsonValueKind.False) return false;
            if (val.ValueKind == JsonValueKind.Number) return val.GetInt32() != 0;
        }
        return false;
    }

    static string FormatOperation(string op) => op switch
    {
        "INS" => "INS",
        "UPD" => "UPD",
        "DEL" => "DEL",
        _ => op
    };

    static string FormatTimestamp(string time)
    {
        if (DateTime.TryParse(time, out var dt))
            return dt.ToLocalTime().ToString("HH:mm:ss.fff");
        return time.Length > 12 ? time[..12] : time;
    }

    static string FormatLapTime(int ms)
    {
        var ts = TimeSpan.FromMilliseconds(ms);
        return ts.TotalMinutes >= 1
            ? $"{(int)ts.TotalMinutes}:{ts.Seconds:D2}.{ts.Milliseconds:D3}"
            : $"{ts.Seconds}.{ts.Milliseconds:D3}";
    }

    static string GetTireEmoji(string compound) => compound switch
    {
        "Soft" => "[S]",
        "Medium" => "[M]",
        "Hard" => "[H]",
        "Intermediate" => "[I]",
        "Wet" => "[W]",
        _ => "[?]"
    };

    static string Truncate(string s, int max) =>
        s.Length <= max ? s : s[..max] + "...";

    static void PrintBanner()
    {
        Console.Clear();
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine(@"
  ╔═══════════════════════════════════════════════════════════════════╗
  ║         F1 RACE EVENT CONSUMER — SQL Server 2025 CES Demo       ║
  ║                  Change Event Streaming in Action                ║
  ╚═══════════════════════════════════════════════════════════════════╝
");
        Console.ResetColor();
    }

    static void PrintSeparator()
    {
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.WriteLine("  ─────────────────────────────────────────────────────────────────\n");
        Console.ResetColor();
    }
}
