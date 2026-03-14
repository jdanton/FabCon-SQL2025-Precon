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

using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using System.Text;
using System.Text.Json;

namespace F1RaceEventConsumer;

class Program
{
    // ═══════════════════════════════════════════════════════════════════════
    // CONFIGURATION — Update these values for your environment
    // ═══════════════════════════════════════════════════════════════════════

    // Event Hubs namespace (e.g., "f1racing-ns.servicebus.windows.net")
    const string EventHubNamespace = "f1ces-ns-3308.servicebus.windows.net";

    // The Event Hub instance name (e.g., "f1-race-events")
    const string EventHubName = "f1-race-events";

    // Azure Blob Storage account URL (used for checkpointing)
    // The processor tracks which events have been read so it can resume after restarts.
    const string BlobStorageUrl = "https://f1cesstore3308.blob.core.windows.net";

    // Blob container name for checkpoints
    const string BlobContainerName = "f1-ces-checkpoints";

    // Azure Service Bus namespace (e.g., "f1racing-ns.servicebus.windows.net")
    // Used to send AI-generated race engineer alerts.
    const string ServiceBusNamespace = "f1ces-sb-3308.servicebus.windows.net";

    // Service Bus queue for race engineer notifications
    const string ServiceBusQueueName = "race-engineer-alerts";

    // Consumer group (use $Default for Basic tier Event Hubs)
    const string ConsumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;

    // ═══════════════════════════════════════════════════════════════════════

    static int _eventCount = 0;
    static bool _debug = false;
    static RaceEngineerService _raceEngineer = null!;

    static async Task Main(string[] args)
    {
        _debug = args.Contains("--debug");
        PrintBanner();

        // Use DefaultAzureCredential — picks up managed identity in Azure,
        // falls back to Azure CLI / Visual Studio credentials for local dev.
        var credential = new DefaultAzureCredential();

        // Initialize the AI-powered race engineer
        _raceEngineer = new RaceEngineerService(ServiceBusNamespace, ServiceBusQueueName, credential);

        // Use lightweight consumer (no blob checkpointing) for low-latency demo
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine("  Connecting to Azure Event Hubs...");
        Console.ResetColor();

        await using var consumer = new EventHubConsumerClient(
            ConsumerGroup,
            EventHubNamespace,
            EventHubName,
            credential);

        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine("  CONNECTED. Listening for race events...");
        Console.WriteLine("  Run the SQL scripts in SSMS to generate events.");
        Console.WriteLine("  Press Ctrl+C to stop.\n");
        Console.ResetColor();

        PrintSeparator();

        // Read events from latest — no checkpoint overhead
        var cts = new CancellationTokenSource();
        Console.CancelKeyPress += (_, e) => { e.Cancel = true; cts.Cancel(); };

        try
        {
            await foreach (var partitionEvent in consumer.ReadEventsAsync(
                startReadingAtEarliestEvent: false,
                readOptions: new ReadEventOptions { MaximumWaitTime = TimeSpan.FromMilliseconds(100) },
                cancellationToken: cts.Token))
            {
                if (partitionEvent.Data == null) continue;
                await ProcessEventDirect(partitionEvent.Data);
            }
        }
        catch (OperationCanceledException) { }

        Console.WriteLine($"\n  Done. Processed {_eventCount} events total.");
        await _raceEngineer.DisposeAsync();
    }

    /// <summary>
    /// Processes each event directly from the lightweight consumer.
    /// </summary>
    static async Task ProcessEventDirect(EventData eventData)
    {
        Interlocked.Increment(ref _eventCount);

        try
        {
            var body = Encoding.UTF8.GetString(eventData.Body.ToArray());
            var cloudEvent = JsonSerializer.Deserialize<JsonElement>(body);

            // Extract CloudEvent metadata
            var time = GetString(cloudEvent, "time");
            var dataRaw = cloudEvent.GetProperty("data");

            // CES may send "data" as a JSON string or as a nested object — handle both
            JsonElement data;
            if (dataRaw.ValueKind == JsonValueKind.String)
                data = JsonSerializer.Deserialize<JsonElement>(dataRaw.GetString()!);
            else
                data = dataRaw;

            // Extract CES-specific fields from actual payload structure
            var eventsource = data.GetProperty("eventsource");
            var schema = GetString(eventsource, "schema");
            var table = GetString(eventsource, "tbl");

            // Build named columns from CES eventrow + eventsource.cols mapping
            var columns = BuildNamedColumns(data);

            // DEBUG: dump first event or when --debug flag is set
            if (_debug || _eventCount == 1)
            {
                Console.ForegroundColor = ConsoleColor.DarkYellow;
                if (data.TryGetProperty("eventrow", out var debugRow))
                    Console.WriteLine($"  [DEBUG] eventrow keys: {string.Join(", ", EnumerateKeys(debugRow))}");
                Console.WriteLine($"  [DEBUG] built columns: {Truncate(columns.ToString(), 500)}");
                Console.ResetColor();
            }

            // Detect operation type from eventrow or CloudEvent type
            var operation = GetString(columns, "__op");
            if (string.IsNullOrEmpty(operation)) operation = "INS";

            // Format and display based on table
            DisplayEvent(table, operation, time, columns);

            // Evaluate for unexpected events — triggers Claude + Service Bus if anomaly detected
            var recommendation = await _raceEngineer.EvaluateEventAsync(table, operation, columns);
            if (recommendation != null)
                DisplayEngineerRadio(recommendation);
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"  [ERROR] Failed to parse event: {ex.Message}");
            Console.ResetColor();

            // Still display raw payload for debugging
            var raw = Encoding.UTF8.GetString(eventData.Body.ToArray());
            Console.ForegroundColor = ConsoleColor.DarkGray;
            Console.WriteLine($"  Raw: {Truncate(raw, 200)}");
            Console.ResetColor();
        }
    }

    /// <summary>
    /// Displays a formatted event based on its table and operation type.
    /// </summary>
    static void DisplayEvent(string table, string operation, string time, JsonElement columns)
    {
        var timestamp = FormatTimestamp(time);
        var opLabel = FormatOperation(operation);

        switch (table)
        {
            case "LiveTiming":
                DisplayLiveTimingEvent(timestamp, opLabel, operation, columns, columns);
                break;

            case "PitStops":
                DisplayPitStopEvent(timestamp, opLabel, columns);
                break;

            case "RaceControl":
                DisplayRaceControlEvent(timestamp, opLabel, columns);
                break;

            case "Races":
                DisplayRaceStatusEvent(timestamp, opLabel, operation, columns, columns);
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
        if (opCode == "UPD" && data.TryGetProperty("__old_columns", out var oldCols))
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

        if (opCode == "UPD" && data.TryGetProperty("__old_columns", out var oldCols))
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

    /// <summary>
    /// Displays a Claude-generated race engineer recommendation as a team radio block.
    /// </summary>
    static void DisplayEngineerRadio(string recommendation)
    {
        const int boxWidth = 63;
        var lines = WordWrap(recommendation, boxWidth - 6); // 6 = padding + border chars

        Console.WriteLine();
        Console.ForegroundColor = ConsoleColor.DarkYellow;
        Console.WriteLine($"  {new string('\u2550', boxWidth)}");
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"  \u2551  TEAM RADIO \u2014 Race Engineer (AI)  {new string(' ', boxWidth - 40)}\u2551");
        Console.ForegroundColor = ConsoleColor.DarkYellow;
        Console.WriteLine($"  {new string('\u2500', boxWidth)}");

        Console.ForegroundColor = ConsoleColor.White;
        foreach (var line in lines)
            Console.WriteLine($"  \u2551  {line.PadRight(boxWidth - 5)} \u2551");

        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.WriteLine($"  \u2551  {"\u25BA Sent to race-engineer-alerts queue".PadRight(boxWidth - 5)} \u2551");
        Console.ForegroundColor = ConsoleColor.DarkYellow;
        Console.WriteLine($"  {new string('\u2550', boxWidth)}");
        Console.ResetColor();
        Console.WriteLine();
    }

    static List<string> WordWrap(string text, int maxWidth)
    {
        var lines = new List<string>();
        var words = text.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        var current = "";

        foreach (var word in words)
        {
            if (current.Length + word.Length + 1 > maxWidth)
            {
                lines.Add(current);
                current = word;
            }
            else
            {
                current = current.Length == 0 ? word : $"{current} {word}";
            }
        }
        if (current.Length > 0) lines.Add(current);

        return lines;
    }

    // ── CES Payload Mapping ────────────────────────────────────────────────

    /// <summary>
    /// Transforms the CES payload (eventsource.cols + eventrow) into a flat
    /// JsonElement with named column properties that the display methods expect.
    /// </summary>
    static JsonElement BuildNamedColumns(JsonElement data)
    {
        if (!data.TryGetProperty("eventsource", out var eventsource) ||
            !data.TryGetProperty("eventrow", out var eventrow))
            return data;

        var dict = new Dictionary<string, object?>();

        // Get column definitions
        if (eventsource.TryGetProperty("cols", out var cols) && cols.ValueKind == JsonValueKind.Array)
        {
            // Try to extract values from eventrow
            // eventrow may have "newvalues"/"oldvalues" arrays, or "vals", or be an array itself
            JsonElement? newVals = null;
            JsonElement? oldVals = null;

            // CES uses "current" for new values, "old" for previous values
            if (eventrow.TryGetProperty("current", out var cur))
                newVals = cur;
            else if (eventrow.TryGetProperty("newvalues", out var nv))
                newVals = nv;
            else if (eventrow.TryGetProperty("vals", out var v))
                newVals = v;
            else if (eventrow.ValueKind == JsonValueKind.Array)
                newVals = eventrow;

            if (eventrow.TryGetProperty("old", out var old))
                oldVals = old;
            else if (eventrow.TryGetProperty("oldvalues", out var ov))
                oldVals = ov;

            if (newVals.HasValue && newVals.Value.ValueKind == JsonValueKind.Array)
            {
                foreach (var col in cols.EnumerateArray())
                {
                    var name = GetString(col, "name");
                    var idx = GetInt(col, "index");
                    if (!string.IsNullOrEmpty(name) && idx < newVals.Value.GetArrayLength())
                        dict[name] = ExtractValue(newVals.Value[idx]);
                }
            }

            // Also try reading eventrow as an object with named properties
            if (!newVals.HasValue && eventrow.ValueKind == JsonValueKind.Object)
            {
                foreach (var col in cols.EnumerateArray())
                {
                    var name = GetString(col, "name");
                    if (!string.IsNullOrEmpty(name) && eventrow.TryGetProperty(name, out var val))
                        dict[name] = ExtractValue(val);
                }
            }
        }

        // Build old_columns for UPD change detection
        if (oldVals.HasValue && oldVals.Value.ValueKind == JsonValueKind.Array)
        {
            var oldDict = new Dictionary<string, object?>();
            foreach (var col in cols.EnumerateArray())
            {
                var name = GetString(col, "name");
                var idx = GetInt(col, "index");
                if (!string.IsNullOrEmpty(name) && idx < oldVals.Value.GetArrayLength())
                    oldDict[name] = ExtractValue(oldVals.Value[idx]);
            }
            dict["__old_columns"] = oldDict;
        }

        // Carry operation type if present
        if (eventrow.TryGetProperty("op", out var op))
            dict["__op"] = op.ToString();

        // Serialize back to JsonElement for the display methods
        var json = JsonSerializer.Serialize(dict);
        return JsonSerializer.Deserialize<JsonElement>(json);
    }

    static object? ExtractValue(JsonElement el) => el.ValueKind switch
    {
        JsonValueKind.String => el.GetString(),
        JsonValueKind.Number => el.TryGetInt32(out var i) ? i : el.GetDouble(),
        JsonValueKind.True => true,
        JsonValueKind.False => false,
        JsonValueKind.Null => null,
        _ => el.ToString()
    };

    // ── Helpers ──────────────────────────────────────────────────────────────



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

    static IEnumerable<string> EnumerateKeys(JsonElement el)
    {
        if (el.ValueKind == JsonValueKind.Object)
            foreach (var prop in el.EnumerateObject())
                yield return prop.Name;
    }

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
