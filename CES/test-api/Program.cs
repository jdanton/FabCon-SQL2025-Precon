using System.Text;
using System.Text.Json;

var apiKey = Environment.GetEnvironmentVariable("ANTHROPIC_API_KEY");
Console.WriteLine($"API key set: {!string.IsNullOrEmpty(apiKey)}");
Console.WriteLine($"API key length: {apiKey?.Length ?? 0}");
Console.WriteLine($"API key prefix: {apiKey?[..Math.Min(10, apiKey.Length)]}...");

var http = new HttpClient();
http.DefaultRequestHeaders.Add("x-api-key", apiKey);
http.DefaultRequestHeaders.Add("anthropic-version", "2024-10-22");

var body = JsonSerializer.Serialize(new
{
    model = "claude-haiku-4-5-20251001",
    max_tokens = 50,
    messages = new[] { new { role = "user", content = "Say hello in 5 words." } }
});

Console.WriteLine($"\nRequest body:\n{body}\n");

var request = new HttpRequestMessage(HttpMethod.Post, "https://api.anthropic.com/v1/messages")
{
    Content = new StringContent(body, Encoding.UTF8, "application/json")
};

var response = await http.SendAsync(request);
Console.WriteLine($"Status: {(int)response.StatusCode} {response.StatusCode}");
var responseBody = await response.Content.ReadAsStringAsync();
Console.WriteLine($"Response:\n{responseBody}");
