using System.Net.Http;
using System.Text;
using System.Text.Json;

var apiKey = Environment.GetEnvironmentVariable("ANTHROPIC_API_KEY");
Console.WriteLine($"API key set: {!string.IsNullOrEmpty(apiKey)}");
Console.WriteLine($"API key length: {apiKey?.Length ?? 0}");
Console.WriteLine($"API key prefix: {apiKey?[..Math.Min(10, apiKey.Length)]}...");

// Try multiple models to find one that works
string[] models = [
    "claude-haiku-4-5-20251001",
    "claude-3-5-haiku-20241022",
    "claude-sonnet-4-5-20250514",
    "claude-3-5-sonnet-20241022"
];

var http = new HttpClient();
http.DefaultRequestHeaders.Add("x-api-key", apiKey);
http.DefaultRequestHeaders.Add("anthropic-version", "2023-06-01");

foreach (var model in models)
{
    Console.WriteLine($"\n--- Trying model: {model} ---");

    var body = JsonSerializer.Serialize(new
    {
        model,
        max_tokens = 50,
        messages = new[] { new { role = "user", content = "Say hello in 5 words." } }
    });

    var request = new HttpRequestMessage(HttpMethod.Post, "https://api.anthropic.com/v1/messages")
    {
        Content = new StringContent(body, Encoding.UTF8, "application/json")
    };

    var response = await http.SendAsync(request);
    var responseBody = await response.Content.ReadAsStringAsync();
    Console.WriteLine($"Status: {(int)response.StatusCode} {response.StatusCode}");
    Console.WriteLine($"Response: {responseBody}");

    if (response.IsSuccessStatusCode) break;
}
