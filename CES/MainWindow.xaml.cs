using Azure.Identity;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using System.Text;
using System.Text.Json;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Media;

namespace F1RaceEventConsumer;

public partial class MainWindow : Window
{
    // ═══════════════════════════════════════════════════════════════════════
    // CONFIGURATION — Update these values for your environment
    // ═══════════════════════════════════════════════════════════════════════
    const string EventHubNamespace = "f1ces-ns-3308.servicebus.windows.net";
    const string EventHubName = "f1-race-events";
    const string BlobStorageUrl = "https://f1cesstore3308.blob.core.windows.net";
    const string BlobContainerName = "f1-ces-checkpoints";
    const string ServiceBusNamespace = "f1ces-sb-3308.servicebus.windows.net";
    const string ServiceBusQueueName = "race-engineer-alerts";
    const string ConsumerGroup = EventHubConsumerClient.DefaultConsumerGroupName;

    // ═══════════════════════════════════════════════════════════════════════

    private int _eventCount;
    private RaceEngineerService _raceEngineer = null!;
    private CancellationTokenSource _cts = new();

    // Color palette (F1 dark theme)
    static readonly Brush DimGray = new SolidColorBrush(Color.FromRgb(0x80, 0x80, 0x80));
    static readonly Brush White = new SolidColorBrush(Color.FromRgb(0xFF, 0xFF, 0xFF));
    static readonly Brush Cyan = new SolidColorBrush(Color.FromRgb(0x00, 0xBF, 0xFF));
    static readonly Brush Green = new SolidColorBrush(Color.FromRgb(0x44, 0xFF, 0x44));
    static readonly Brush Red = new SolidColorBrush(Color.FromRgb(0xFF, 0x44, 0x44));
    static readonly Brush Yellow = new SolidColorBrush(Color.FromRgb(0xFF, 0xD7, 0x00));
    static readonly Brush Magenta = new SolidColorBrush(Color.FromRgb(0xFF, 0x44, 0xFF));
    static readonly Brush DarkYellow = new SolidColorBrush(Color.FromRgb(0xCC, 0x99, 0x00));
    static readonly Brush LightGray = new SolidColorBrush(Color.FromRgb(0xC0, 0xC0, 0xC0));
    static readonly Brush DarkRed = new SolidColorBrush(Color.FromRgb(0xCC, 0x00, 0x00));

    public MainWindow()
    {
        InitializeComponent();
    }

    private async void Window_Loaded(object sender, RoutedEventArgs e)
    {
        AddInfoLine("Initializing...", DimGray);

        try
        {
            var credential = new DefaultAzureCredential();
            _raceEngineer = new RaceEngineerService(ServiceBusNamespace, ServiceBusQueueName, credential);

            UpdateStatus("Connecting to Azure Event Hubs...", "#808080");

            await using var consumer = new EventHubConsumerClient(
                ConsumerGroup, EventHubNamespace, EventHubName, credential);

            UpdateStatus("Connected — Listening for events", "#44FF44");
            Dispatcher.Invoke(() =>
            {
                StatusDot.Fill = new SolidColorBrush(Color.FromRgb(0x44, 0xFF, 0x44));
                ConnectionStatus.Foreground = new SolidColorBrush(Color.FromRgb(0x44, 0xFF, 0x44));
            });

            AddInfoLine("Connected to " + EventHubNamespace, Green);
            AddInfoLine("Listening for race events... Run the SQL scripts to generate events.", DimGray);
            AddSeparator();

            await foreach (var partitionEvent in consumer.ReadEventsAsync(
                startReadingAtEarliestEvent: false,
                readOptions: new ReadEventOptions { MaximumWaitTime = TimeSpan.FromMilliseconds(100) },
                cancellationToken: _cts.Token))
            {
                if (partitionEvent.Data == null) continue;
                await ProcessEvent(partitionEvent.Data);
            }
        }
        catch (OperationCanceledException) { }
        catch (Exception ex)
        {
            UpdateStatus("Error: " + ex.Message, "#FF4444");
            AddInfoLine("ERROR: " + ex.Message, Red);
        }
    }

    private void Window_Closing(object? sender, System.ComponentModel.CancelEventArgs e)
    {
        _cts.Cancel();
    }

    // ── Event Processing ────────────────────────────────────────────────

    private async Task ProcessEvent(EventData eventData)
    {
        Interlocked.Increment(ref _eventCount);
        Dispatcher.Invoke(() => EventCountText.Text = _eventCount.ToString());

        try
        {
            var body = Encoding.UTF8.GetString(eventData.Body.ToArray());
            var cloudEvent = JsonSerializer.Deserialize<JsonElement>(body);

            var time = GetString(cloudEvent, "time");
            var dataRaw = cloudEvent.GetProperty("data");

            JsonElement data;
            if (dataRaw.ValueKind == JsonValueKind.String)
                data = JsonSerializer.Deserialize<JsonElement>(dataRaw.GetString()!);
            else
                data = dataRaw;

            var eventsource = data.GetProperty("eventsource");
            var table = GetString(eventsource, "tbl");
            var columns = BuildNamedColumns(data);
            var operation = GetString(columns, "__op");
            if (string.IsNullOrEmpty(operation)) operation = "INS";

            Dispatcher.Invoke(() => DisplayEvent(table, operation, time, columns));

            // Fire-and-forget AI evaluation
            _ = Task.Run(async () =>
            {
                try
                {
                    var recommendation = await _raceEngineer.EvaluateEventAsync(table, operation, columns);
                    if (recommendation != null)
                        Dispatcher.Invoke(() => ShowEngineerRadio(recommendation));
                }
                catch { }
            });
        }
        catch (Exception ex)
        {
            Dispatcher.Invoke(() => AddInfoLine($"[ERROR] Failed to parse: {ex.Message}", Red));
        }
    }

    // ── Display Methods ─────────────────────────────────────────────────

    private void DisplayEvent(string table, string operation, string time, JsonElement columns)
    {
        var ts = FormatTimestamp(time);
        var op = operation;

        switch (table)
        {
            case "LiveTiming":
                DisplayLiveTimingEvent(ts, op, columns);
                break;
            case "PitStops":
                DisplayPitStopEvent(ts, op, columns);
                break;
            case "RaceControl":
                DisplayRaceControlEvent(ts, op, columns);
                break;
            case "Races":
                DisplayRaceStatusEvent(ts, op, columns);
                break;
            case "Drivers":
                DisplayDriverEvent(ts, op, columns);
                break;
            default:
                DisplayGenericEvent(ts, table, op, columns);
                break;
        }
    }

    private void DisplayLiveTimingEvent(string ts, string op, JsonElement cols)
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

        var p = new Paragraph { Margin = new Thickness(0, 2, 0, 2) };
        p.Inlines.Add(Span($"  {ts} ", DimGray));

        // Position changes for UPD
        if (op == "UPD" && cols.TryGetProperty("__old_columns", out var oldCols))
        {
            var oldPos = GetInt(oldCols, "Position");
            if (oldPos > 0 && oldPos != position)
            {
                var color = position < oldPos ? Green : Red;
                p.Inlines.Add(Span($"[TIMING {op}] ", color, true));
                p.Inlines.Add(Span($"Driver #{driverId} P{oldPos} -> P{position}", color));
            }
            else
            {
                p.Inlines.Add(Span($"[TIMING {op}] ", Cyan, true));
                p.Inlines.Add(Span($"Driver #{driverId} P{position}", White));
            }
        }
        else
        {
            p.Inlines.Add(Span($"[TIMING {op}] ", Cyan, true));
            p.Inlines.Add(Span($"Driver #{driverId} P{position}", White));
        }

        if (!isActive && lap > 0)
            p.Inlines.Add(Span(" ■ DNF", Red, true));
        else if (inPit)
            p.Inlines.Add(Span(" ■ IN PIT", Yellow, true));

        var details = new List<string>();
        if (lap > 0) details.Add($"Lap {lap}");
        if (lapTimeMs > 0) details.Add(FormatLapTime(lapTimeMs));
        if (gap > 0) details.Add($"+{gap / 1000.0:F3}s");
        details.Add($"{GetTireEmoji(tire)} {tire} (Age: {tireAge})");
        if (drs) details.Add("DRS");
        p.Inlines.Add(Span($"  {string.Join(" | ", details)}", DimGray));

        AppendParagraph(p);
    }

    private void DisplayPitStopEvent(string ts, string op, JsonElement cols)
    {
        var driverId = GetInt(cols, "DriverId");
        var lap = GetInt(cols, "Lap");
        var duration = GetInt(cols, "PitStopDurationMs");
        var tireIn = GetString(cols, "TireCompoundIn");
        var tireOut = GetString(cols, "TireCompoundOut");
        var stopNum = GetInt(cols, "StopNumber");
        var notes = GetString(cols, "Notes");

        var p = new Paragraph { Margin = new Thickness(0, 2, 0, 2) };
        p.Inlines.Add(Span($"  {ts} ", DimGray));
        p.Inlines.Add(Span($"[PIT STOP {op}] ", Yellow, true));
        p.Inlines.Add(Span($"Driver #{driverId} Stop #{stopNum} on Lap {lap}", White));
        p.Inlines.Add(Span($"  {duration / 1000.0:F3}s | {GetTireEmoji(tireIn)} {tireIn} -> {GetTireEmoji(tireOut)} {tireOut}", DimGray));

        if (!string.IsNullOrEmpty(notes))
            p.Inlines.Add(Span($"  \"{notes}\"", DarkYellow));

        AppendParagraph(p);
    }

    private void DisplayRaceControlEvent(string ts, string op, JsonElement cols)
    {
        var msgType = GetString(cols, "MessageType");
        var category = GetString(cols, "Category");
        var description = GetString(cols, "Description");
        var lap = GetInt(cols, "Lap");

        var catColor = category switch
        {
            "Safety" => Red,
            "Infringement" => Magenta,
            _ => White
        };

        var p = new Paragraph { Margin = new Thickness(0, 2, 0, 2) };
        p.Inlines.Add(Span($"  {ts} ", DimGray));
        p.Inlines.Add(Span($"[RACE CTRL {op}] ", catColor, true));
        if (lap > 0) p.Inlines.Add(Span($"Lap {lap}: ", White));
        p.Inlines.Add(Span(description, White));

        AppendParagraph(p);
    }

    private void DisplayRaceStatusEvent(string ts, string op, JsonElement cols)
    {
        var status = GetString(cols, "RaceStatus");
        var raceName = GetString(cols, "RaceName");

        var statusColor = status switch
        {
            "Green" => Green,
            "SafetyCar" or "VSC" => Yellow,
            "RedFlag" => Red,
            "Finished" => White,
            _ => Cyan
        };

        var p = new Paragraph { Margin = new Thickness(0, 2, 0, 2) };
        p.Inlines.Add(Span($"  {ts} ", DimGray));

        if (op == "UPD" && cols.TryGetProperty("__old_columns", out var oldCols))
        {
            var oldStatus = GetString(oldCols, "RaceStatus");
            p.Inlines.Add(Span("[RACE STATUS] ", statusColor, true));
            p.Inlines.Add(Span($"{oldStatus} -> {status}", statusColor));
            if (!string.IsNullOrEmpty(raceName))
                p.Inlines.Add(Span($"  ({raceName})", DimGray));
        }
        else
        {
            p.Inlines.Add(Span($"[RACE {op}] ", Cyan, true));
            p.Inlines.Add(Span($"{raceName} - {status}", White));
        }

        // Update status bar
        RaceStatusText.Text = status;
        RaceStatusText.Foreground = statusColor;

        AppendParagraph(p);
    }

    private void DisplayDriverEvent(string ts, string op, JsonElement cols)
    {
        var code = GetString(cols, "DriverCode");
        var name = $"{GetString(cols, "FirstName")} {GetString(cols, "LastName")}";
        var team = GetString(cols, "TeamName");

        var p = new Paragraph { Margin = new Thickness(0, 2, 0, 2) };
        p.Inlines.Add(Span($"  {ts} ", DimGray));
        p.Inlines.Add(Span($"[DRIVER {op}] ", Cyan, true));
        p.Inlines.Add(Span($"{code} - {name} ({team})", White));

        AppendParagraph(p);
    }

    private void DisplayGenericEvent(string ts, string table, string op, JsonElement cols)
    {
        var text = cols.ToString();
        if (text.Length > 120) text = text[..120] + "...";

        var p = new Paragraph { Margin = new Thickness(0, 2, 0, 2) };
        p.Inlines.Add(Span($"  {ts} ", DimGray));
        p.Inlines.Add(Span($"[{table.ToUpper()} {op}] ", LightGray, true));
        p.Inlines.Add(Span(text, LightGray));

        AppendParagraph(p);
    }

    // ── Race Engineer Radio ─────────────────────────────────────────────

    private void ShowEngineerRadio(string recommendation)
    {
        RadioMessage.Text = recommendation;
        RadioPanel.Visibility = Visibility.Visible;

        // Also add to the event feed for the scrolling record
        var p = new Paragraph { Margin = new Thickness(0, 8, 0, 8) };
        p.Inlines.Add(Span("  ══ ", DarkYellow));
        p.Inlines.Add(Span("TEAM RADIO — Race Engineer (AI)", Yellow, true));
        p.Inlines.Add(Span(" ══", DarkYellow));
        AppendParagraph(p);

        var msg = new Paragraph { Margin = new Thickness(0, 0, 0, 4) };
        msg.Inlines.Add(Span($"  {recommendation}", White));
        AppendParagraph(msg);

        var footer = new Paragraph { Margin = new Thickness(0, 0, 0, 8) };
        footer.Inlines.Add(Span("  ► Sent to race-engineer-alerts queue", DimGray));
        AppendParagraph(footer);
    }

    // ── UI Helpers ──────────────────────────────────────────────────────

    private void AppendParagraph(Paragraph p)
    {
        EventDocument.Blocks.Add(p);
        EventFeed.ScrollToEnd();
    }

    private void AddInfoLine(string text, Brush color)
    {
        Dispatcher.Invoke(() =>
        {
            var p = new Paragraph { Margin = new Thickness(0, 2, 0, 2) };
            p.Inlines.Add(Span($"  {text}", color));
            AppendParagraph(p);
        });
    }

    private void AddSeparator()
    {
        Dispatcher.Invoke(() =>
        {
            var p = new Paragraph { Margin = new Thickness(0, 4, 0, 4) };
            p.Inlines.Add(Span("  " + new string('\u2500', 65), DimGray));
            AppendParagraph(p);
        });
    }

    private void UpdateStatus(string text, string hexColor)
    {
        Dispatcher.Invoke(() =>
        {
            ConnectionStatus.Text = text;
            var color = (Color)ColorConverter.ConvertFromString(hexColor);
            ConnectionStatus.Foreground = new SolidColorBrush(color);
        });
    }

    private static Run Span(string text, Brush foreground, bool bold = false)
    {
        var run = new Run(text) { Foreground = foreground };
        if (bold) run.FontWeight = FontWeights.Bold;
        return run;
    }

    // ── CES Payload Mapping ─────────────────────────────────────────────

    static JsonElement BuildNamedColumns(JsonElement data)
    {
        if (!data.TryGetProperty("eventsource", out var eventsource) ||
            !data.TryGetProperty("eventrow", out var eventrow))
            return data;

        var dict = new Dictionary<string, object?>();

        if (!eventsource.TryGetProperty("cols", out var cols) || cols.ValueKind != JsonValueKind.Array)
            return data;

        JsonElement? newVals = null;
        JsonElement? oldVals = null;

        if (eventrow.TryGetProperty("current", out var cur))
            newVals = cur;
        else if (eventrow.TryGetProperty("newvalues", out var nv))
            newVals = nv;
        else if (eventrow.ValueKind == JsonValueKind.Array)
            newVals = eventrow;

        if (eventrow.TryGetProperty("old", out var old))
            oldVals = old;

        if (newVals.HasValue)
        {
            var val = newVals.Value;
            if (val.ValueKind == JsonValueKind.String)
                val = JsonSerializer.Deserialize<JsonElement>(val.GetString()!);

            if (val.ValueKind == JsonValueKind.Array)
            {
                foreach (var col in cols.EnumerateArray())
                {
                    var name = GetString(col, "name");
                    var idx = GetInt(col, "index");
                    if (!string.IsNullOrEmpty(name) && idx < val.GetArrayLength())
                        dict[name] = ExtractValue(val[idx]);
                }
            }
            else if (val.ValueKind == JsonValueKind.Object)
            {
                foreach (var prop in val.EnumerateObject())
                    dict[prop.Name] = ExtractValue(prop.Value);
            }
        }

        if (oldVals.HasValue)
        {
            var oldVal = oldVals.Value;
            if (oldVal.ValueKind == JsonValueKind.String)
                oldVal = JsonSerializer.Deserialize<JsonElement>(oldVal.GetString()!);

            var oldDict = new Dictionary<string, object?>();
            if (oldVal.ValueKind == JsonValueKind.Array)
            {
                foreach (var col in cols.EnumerateArray())
                {
                    var name = GetString(col, "name");
                    var idx = GetInt(col, "index");
                    if (!string.IsNullOrEmpty(name) && idx < oldVal.GetArrayLength())
                        oldDict[name] = ExtractValue(oldVal[idx]);
                }
            }
            else if (oldVal.ValueKind == JsonValueKind.Object)
            {
                foreach (var prop in oldVal.EnumerateObject())
                    oldDict[prop.Name] = ExtractValue(prop.Value);
            }
            if (oldDict.Count > 0)
                dict["__old_columns"] = oldDict;
        }

        if (eventrow.TryGetProperty("op", out var op))
            dict["__op"] = op.ToString();

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

    // ── JSON Helpers ────────────────────────────────────────────────────

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
            if (val.ValueKind == JsonValueKind.String)
            {
                var s = val.GetString();
                return s == "1" || string.Equals(s, "true", StringComparison.OrdinalIgnoreCase);
            }
        }
        return false;
    }

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
}
