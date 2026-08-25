# CES Demo — Configuration Guide

Everything you have to fill in after `terraform apply`, and where it goes.

There are exactly **two** things to configure:

1. **Azure metadata** — the Event Hubs / Service Bus names Terraform generated
2. **An Anthropic API key** — for the race engineer's recommendations

Plus one thing that is easy to miss: **which identity** the consumer app runs as.

---

## Before you start

Deploy the infrastructure first (see [readme.md](readme.md)), then:

```bash
cd CES/infra
terraform output
```

**Every name has a random 4-digit suffix** (`f1ces-ns-3308`, `f1cesstore3308`, …).
It is regenerated whenever Terraform state is recreated, so the values currently
committed in this repo are stale — they point at a deployment that no longer
exists. You must re-copy them after every fresh deploy.

---

## Part 1 — Azure metadata

### Where each value goes

| Terraform output | Goes into | Line | Used? |
|---|---|---|---|
| `eventhub_namespace` | `MainWindow.xaml.cs` → `EventHubNamespace` | [17](MainWindow.xaml.cs#L17) | ✅ |
| `eventhub_name` | `MainWindow.xaml.cs` → `EventHubName` | [18](MainWindow.xaml.cs#L18) | ✅ |
| `servicebus_namespace` | `MainWindow.xaml.cs` → `ServiceBusNamespace` | [21](MainWindow.xaml.cs#L21) | ✅ |
| — (`race-engineer-alerts`, fixed) | `MainWindow.xaml.cs` → `ServiceBusQueueName` | [22](MainWindow.xaml.cs#L22) | ✅ |
| `eventhub_namespace` + `/` + `eventhub_name` | `04_configure_ces.sql` → `@destination_location` | [76](04_configure_ces.sql#L76) | ✅ |
| `storage_account_url` | `MainWindow.xaml.cs` → `BlobStorageUrl` | [19](MainWindow.xaml.cs#L19) | ❌ dead |

> **Not `Program.cs`.** [Program.cs](Program.cs) is an empty stub — the app moved to
> WPF and all configuration now lives in [MainWindow.xaml.cs](MainWindow.xaml.cs).
> Older instructions pointing at `Program.cs` are wrong.

> **`BlobStorageUrl` and `BlobContainerName` are declared but never used.** The app
> uses `EventHubConsumerClient`, which reads from the current position and does not
> checkpoint. Terraform still provisions the storage account and grants it RBAC, so
> it's ready if you switch to `EventProcessorClient` later — but you do **not** need
> to set these two for the demo to run.

### Two gotchas on the SQL side

`04_configure_ces.sql` has a **hardcoded** namespace at line 76:

```sql
@destination_location = N'f1ces-ns-3308.servicebus.windows.net/f1-race-events',
```

Its header block (lines 20-24) says to replace `<YourEventHubsNamespace>` and
`<YourEventHubsInstance>` — **those placeholders do not exist in the file.** Don't
search for them; edit line 76 directly. The format is
`<namespace-fqdn>/<eventhub-name>`, no scheme, no trailing slash.

`<YourMasterKeyPassword>` on **line 35 is a real placeholder** and must be replaced
with a strong password before the script will run.

### Patch it automatically (PowerShell, on the VM)

Re-runnable — it rewrites whatever is currently in the files:

```powershell
Push-Location "$PSScriptRoot\infra"
$tf     = terraform output -json | ConvertFrom-Json
$ehNs   = $tf.eventhub_namespace.value
$ehName = $tf.eventhub_name.value
$sbNs   = $tf.servicebus_namespace.value
Pop-Location

$mw  = "$PSScriptRoot\MainWindow.xaml.cs"
$sql = "$PSScriptRoot\04_configure_ces.sql"

(Get-Content $mw -Raw) `
  -replace '(const string EventHubNamespace\s*=\s*")[^"]*(")',   "`${1}$ehNs`${2}" `
  -replace '(const string EventHubName\s*=\s*")[^"]*(")',        "`${1}$ehName`${2}" `
  -replace '(const string ServiceBusNamespace\s*=\s*")[^"]*(")', "`${1}$sbNs`${2}" `
  | Set-Content $mw -NoNewline

(Get-Content $sql -Raw) `
  -replace "(@destination_location\s*=\s*N')[^']*(')", "`${1}$ehNs/$ehName`${2}" `
  | Set-Content $sql -NoNewline

Write-Host "Event Hubs : $ehNs/$ehName"
Write-Host "Service Bus: $sbNs"
Write-Host "Remember to set <YourMasterKeyPassword> on line 35 of 04_configure_ces.sql"
```

---

## Part 2 — The Anthropic API key

The race engineer ([RaceEngineerService.cs](RaceEngineerService.cs)) calls the Claude
API directly over HTTPS to turn raw CES events into pit-wall recommendations.

### Get a key

1. Go to <https://console.anthropic.com>
2. **Settings → API keys → Create key**
3. Copy it immediately — it is shown once. Keys start with `sk-ant-`.

Billing must be set up on the account or calls return `400 credit balance is too low`.

### Set it

The app reads the environment variable **`ANTHROPIC_API_KEY`**
([RaceEngineerService.cs:62](RaceEngineerService.cs#L62)). There is no config file,
no appsettings entry, and no way to paste it into the UI.

On the SQL Server VM, in an **Administrator** PowerShell:

```powershell
# Machine-wide and persistent
[Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', 'sk-ant-...', 'Machine')
```

Or for just your user:

```powershell
setx ANTHROPIC_API_KEY "sk-ant-..."
```

> **You must restart the app after setting this.** `setx` and
> `SetEnvironmentVariable` only affect **newly created** processes. If Visual Studio
> was already open, close and reopen it — otherwise the app inherits the old, empty
> environment and throws on startup. This is the single most common setup failure.

Verify in a **new** shell before launching:

```powershell
$env:ANTHROPIC_API_KEY.Substring(0,12)   # should print sk-ant-api03
```

### Notes

- The app authenticates with the `x-api-key` header and `anthropic-version: 2023-06-01`
  ([RaceEngineerService.cs:67-68](RaceEngineerService.cs#L67-L68)). That is the correct
  shape for API-key auth.
- An `ant auth login` profile will **not** work here — that mechanism is for the
  official SDKs and CLI. This app reads the raw environment variable, so the env var
  is the only supported path as written.
- The model is pinned to `claude-haiku-4-5-20251001` at
  [RaceEngineerService.cs:227](RaceEngineerService.cs#L227). The current canonical ID
  for that model is the undated `claude-haiku-4-5`; the dated snapshot still resolves,
  so this is optional cleanup rather than a break.

---

## Part 3 — Which identity the app runs as

This is the part that silently fails.

Everything Azure-side uses `DefaultAzureCredential`
([MainWindow.xaml.cs:54](MainWindow.xaml.cs#L54)) — no connection strings, no SAS
tokens. What that resolves to depends on **where you run the app**:

| Where you run it | `DefaultAzureCredential` resolves to | Works? |
|---|---|---|
| **On the SQL Server VM** | The VM's system-assigned managed identity | ✅ Yes |
| **On your laptop** | Your `az login` user | ❌ No — no role assignments |

[infra/rbac.tf](infra/rbac.tf) grants all four data-plane roles to the **VM's managed
identity only**:

- `Azure Event Hubs Data Sender` — SQL Server CES → Event Hubs
- `Azure Event Hubs Data Receiver` — consumer app → Event Hubs
- `Storage Blob Data Contributor` — checkpoints (currently unused)
- `Azure Service Bus Data Sender` — race engineer alerts → Service Bus

Your deploying user gets **Key Vault access only**. So **run the consumer app on the
VM.** That is what the demo assumes.

If you genuinely need to run it from your laptop, grant yourself the two roles the
app actually uses:

```bash
cd CES/infra
SUB=$(az account show --query id -o tsv)
RG=$(terraform output -raw resource_group_name)
ME=$(az ad signed-in-user show --query id -o tsv)
EHNS=$(terraform output -raw eventhub_namespace | cut -d. -f1)
SBNS=$(terraform output -raw servicebus_namespace | cut -d. -f1)

az role assignment create --assignee $ME --role "Azure Event Hubs Data Receiver" \
  --scope "/subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.EventHub/namespaces/$EHNS"
az role assignment create --assignee $ME --role "Azure Service Bus Data Sender" \
  --scope "/subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.ServiceBus/namespaces/$SBNS"
```

Role assignments can take a minute or two to propagate.

---

## Verify

```bash
cd CES/infra && terraform output          # 1. infra is up
```

```powershell
$env:ANTHROPIC_API_KEY.Length             # 2. key is set in THIS shell
```

3. Run scripts `01` → `04` on the VM. Script `04` should print
   `Event stream group "F1RaceStreamGroup" created.`
4. Launch the WPF app. It should show **Connected — Listening for events** in green.
5. Run `05_simulate_race.sql` (or `05a_simulate_race_auto.sql`) and watch events land.
6. `06_verify_ces.sql` confirms CES is streaming.

---

## Troubleshooting

| Symptom | Cause |
|---|---|
| `ANTHROPIC_API_KEY environment variable is not set` | Set but app not restarted — see Part 2. Close and reopen Visual Studio. |
| `401 authentication_error` from Anthropic | Bad or revoked key. Regenerate in the Console. |
| `400 credit balance is too low` | Add billing to the Anthropic account. |
| App hangs on "Connecting to Azure Event Hubs..." | Wrong `EventHubNamespace`, or the stale `3308` value. Re-copy from `terraform output`. |
| `Unauthorized` / `AuthorizationFailed` from Event Hubs or Service Bus | Running off-VM as your own user — see Part 3. |
| Script `04` fails on `CREATE MASTER KEY` | `<YourMasterKeyPassword>` on line 35 was never replaced. |
| Script `04` succeeds but no events arrive | `@destination_location` on line 76 still points at the old namespace. |
| Events in Event Hub but app shows nothing | App connected to a *different* namespace than CES is publishing to. Confirm both match `terraform output`. |
| Seed data never appears in the stream | Expected. Scripts `01`-`03` run before CES is enabled; only changes after `04` stream. |
