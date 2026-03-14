// ============================================================================
// RaceEngineerService.cs
// AI-powered race engineer that detects unexpected events, calls Claude for
// strategic recommendations, and sends notifications to Azure Service Bus.
// ============================================================================

using Azure.Identity;
using Azure.Messaging.ServiceBus;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace F1RaceEventConsumer;

/// <summary>
/// Tracks minimal per-driver state so we can detect anomalies.
/// </summary>
class DriverState
{
    public int DriverId { get; set; }
    public int Position { get; set; }
    public string TireCompound { get; set; } = "";
    public int TireAge { get; set; }
    public bool IsActive { get; set; } = true;
    public int Lap { get; set; }
}

/// <summary>
/// Describes an unexpected event detected by the race engineer.
/// </summary>
record RaceAlert(string Trigger, string Description, int? DriverId, int? Lap, JsonElement EventData);

/// <summary>
/// Detects unexpected race events, generates Claude-powered recommendations,
/// and sends notifications to Azure Service Bus.
/// </summary>
class RaceEngineerService : IAsyncDisposable
{
    // Tire life thresholds (laps) — beyond these, performance drops significantly
    static readonly Dictionary<string, int> TireLifeLimits = new()
    {
        ["Soft"] = 25,
        ["Medium"] = 35,
        ["Hard"] = 50,
        ["Intermediate"] = 40,
        ["Wet"] = 45
    };

    static readonly HttpClient _http = new();
    readonly ServiceBusSender _sender;
    readonly ServiceBusClient _serviceBusClient;

    // Race state
    readonly Dictionary<int, DriverState> _drivers = new();
    string _raceStatus = "Scheduled";
    string _raceName = "";

    public RaceEngineerService(string serviceBusNamespace, string queueName, DefaultAzureCredential credential)
    {
        // Configure HttpClient for Claude API
        var apiKey = Environment.GetEnvironmentVariable("ANTHROPIC_API_KEY")
            ?? throw new InvalidOperationException(
                "ANTHROPIC_API_KEY environment variable is not set. "
                + "Get your key from https://console.anthropic.com");

        _http.DefaultRequestHeaders.Add("x-api-key", apiKey);
        _http.DefaultRequestHeaders.Add("anthropic-version", "2023-06-01");

        _serviceBusClient = new ServiceBusClient(serviceBusNamespace, credential);
        _sender = _serviceBusClient.CreateSender(queueName);
    }

    /// <summary>
    /// Evaluates an incoming CES event for anomalies. Returns a recommendation
    /// if an unexpected event is detected, or null if the event is routine.
    /// </summary>
    public async Task<string?> EvaluateEventAsync(string table, string operation, JsonElement data)
    {
        var columns = data.TryGetProperty("columns", out var cols) ? cols : data;
        var oldColumns = data.TryGetProperty("old_columns", out var oldCols) ? oldCols : (JsonElement?)null;

        // Update internal state
        UpdateState(table, columns, oldColumns);

        // Check for unexpected events
        var alert = DetectAnomaly(table, operation, columns, oldColumns);
        if (alert == null) return null;

        // Call Claude for a recommendation
        var recommendation = await GetRecommendationAsync(alert);

        // Send to Service Bus
        await SendNotificationAsync(alert, recommendation);

        return recommendation;
    }

    void UpdateState(string table, JsonElement columns, JsonElement? oldColumns)
    {
        switch (table)
        {
            case "Races":
                var status = GetStr(columns, "RaceStatus");
                if (!string.IsNullOrEmpty(status)) _raceStatus = status;
                var name = GetStr(columns, "RaceName");
                if (!string.IsNullOrEmpty(name)) _raceName = name;
                break;

            case "LiveTiming":
                var driverId = GetInt(columns, "DriverId");
                if (driverId > 0)
                {
                    if (!_drivers.TryGetValue(driverId, out var state))
                    {
                        state = new DriverState { DriverId = driverId };
                        _drivers[driverId] = state;
                    }
                    state.Position = GetInt(columns, "Position");
                    var tire = GetStr(columns, "TireCompound");
                    if (!string.IsNullOrEmpty(tire)) state.TireCompound = tire;
                    state.TireAge = GetInt(columns, "TireAge");
                    state.Lap = GetInt(columns, "Lap");
                    if (columns.TryGetProperty("IsActive", out var activeVal))
                        state.IsActive = IsTrue(activeVal);
                }
                break;
        }
    }

    RaceAlert? DetectAnomaly(string table, string operation, JsonElement columns, JsonElement? oldColumns)
    {
        switch (table)
        {
            // Safety Car, Red Flag, or VSC — major strategic moments
            case "Races" when operation == "UPD" && oldColumns.HasValue:
            {
                var newStatus = GetStr(columns, "RaceStatus");
                var oldStatus = GetStr(oldColumns.Value, "RaceStatus");
                if (newStatus is "SafetyCar" or "RedFlag" or "VSC" && oldStatus != newStatus)
                {
                    return new RaceAlert(
                        "SAFETY_EVENT",
                        $"Race status changed from {oldStatus} to {newStatus}",
                        null, null, columns);
                }
                break;
            }

            // Driver DNF / retirement
            case "LiveTiming":
            {
                var driverId = GetInt(columns, "DriverId");
                bool isActive = !columns.TryGetProperty("IsActive", out var av) || IsTrue(av);

                if (!isActive && driverId > 0)
                {
                    return new RaceAlert(
                        "DRIVER_DNF",
                        $"Driver #{driverId} has retired from the race",
                        driverId, GetInt(columns, "Lap"), columns);
                }

                // Extreme tire degradation
                var tireAge = GetInt(columns, "TireAge");
                var compound = GetStr(columns, "TireCompound");
                if (tireAge > 0 && TireLifeLimits.TryGetValue(compound, out var limit) && tireAge > limit)
                {
                    return new RaceAlert(
                        "TIRE_DEGRADATION",
                        $"Driver #{driverId} on {compound} tires at {tireAge} laps (limit: {limit})",
                        driverId, GetInt(columns, "Lap"), columns);
                }
                break;
            }

            // Penalty
            case "RaceControl" when operation == "INS":
            {
                var msgType = GetStr(columns, "MessageType");
                if (msgType == "Penalty")
                {
                    var driverId = GetInt(columns, "DriverId");
                    var desc = GetStr(columns, "Description");
                    return new RaceAlert(
                        "PENALTY",
                        desc,
                        driverId, GetInt(columns, "Lap"), columns);
                }
                break;
            }
        }

        return null;
    }

    async Task<string> GetRecommendationAsync(RaceAlert alert)
    {
        // Build context about the current race state
        var driverSummary = string.Join("\n", _drivers.Values
            .Where(d => d.IsActive)
            .OrderBy(d => d.Position)
            .Take(6)
            .Select(d => $"  P{d.Position}: Driver #{d.DriverId} | {d.TireCompound} (age {d.TireAge}) | Lap {d.Lap}"));

        var userPrompt = $"""
            RACE SITUATION:
            Race: {_raceName}
            Status: {_raceStatus}

            EVENT DETECTED — {alert.Trigger}:
            {alert.Description}

            CURRENT TOP POSITIONS:
            {driverSummary}

            Based on this event, provide an urgent team radio message with a strategic
            recommendation. Be specific about what action to take (pit now, stay out,
            change tire compound, adjust pace, defend position, etc.).
            2-3 sentences, in the style of real F1 team radio.
            """;

        try
        {
            var requestBody = JsonSerializer.Serialize(new
            {
                model = "claude-haiku-4-5-20251001",
                max_tokens = 200,
                system = "You are an F1 race engineer speaking to your driver over team radio. "
                       + "Be concise, urgent, and strategic. Use real F1 terminology. "
                       + "Address the driver directly.",
                messages = new[]
                {
                    new { role = "user", content = userPrompt }
                }
            });

            var request = new HttpRequestMessage(HttpMethod.Post, "https://api.anthropic.com/v1/messages")
            {
                Content = new StringContent(requestBody, Encoding.UTF8, "application/json")
            };

            var response = await _http.SendAsync(request);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            var doc = JsonDocument.Parse(json);
            var content = doc.RootElement.GetProperty("content");
            return content[0].GetProperty("text").GetString() ?? "Unable to generate recommendation.";
        }
        catch (Exception ex)
        {
            return $"[Engineer offline — {ex.Message}]";
        }
    }

    async Task SendNotificationAsync(RaceAlert alert, string recommendation)
    {
        var notification = new
        {
            timestamp = DateTime.UtcNow,
            trigger = alert.Trigger,
            description = alert.Description,
            driverId = alert.DriverId,
            lap = alert.Lap,
            raceStatus = _raceStatus,
            recommendation
        };

        try
        {
            var message = new ServiceBusMessage(JsonSerializer.Serialize(notification))
            {
                ContentType = "application/json",
                Subject = alert.Trigger
            };
            await _sender.SendMessageAsync(message);
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.DarkRed;
            Console.WriteLine($"  [SB ERROR] {ex.Message}");
            Console.ResetColor();
        }
    }

    // ── JSON helpers ─────────────────────────────────────────────────────

    static string GetStr(JsonElement el, string prop)
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

    static bool IsTrue(JsonElement val)
    {
        if (val.ValueKind == JsonValueKind.True) return true;
        if (val.ValueKind == JsonValueKind.False) return false;
        if (val.ValueKind == JsonValueKind.Number) return val.GetInt32() != 0;
        if (val.ValueKind == JsonValueKind.String)
        {
            var s = val.GetString();
            return s == "1" || string.Equals(s, "true", StringComparison.OrdinalIgnoreCase);
        }
        return false;
    }

    public async ValueTask DisposeAsync()
    {
        await _sender.DisposeAsync();
        await _serviceBusClient.DisposeAsync();
    }
}
