## Terraform Deployment (Azure Infrastructure)

Use the Terraform config in `CES/infra` to provision the Azure resources needed by this demo:
- Resource Group
- Event Hubs namespace + Event Hub (`f1-race-events`)
- Storage account + blob container for checkpoints
- Service Bus namespace + queue (`race-engineer-alerts`)
- RBAC assignments for the SQL VM managed identity

### 1) Prerequisites for Terraform
- Terraform `>= 1.5`
- Azure CLI logged in:
  ```bash
  az login
  az account set --subscription "<your-subscription-id>"
  ```
- An existing Azure VM running SQL Server 2025 with **system-assigned managed identity enabled**

### 2) Configure variables
From repo root:

```bash
cd CES/infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set:

```hcl
prefix         = "f1ces"
location       = "eastus"
vm_resource_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/virtualMachines/<sql-vm-name>"
```

> Tip: get VM resource ID with:
> `az vm show -g <resource-group> -n <vm-name> --query id -o tsv`

### 3) Initialize and deploy

```bash
terraform init
tf plan
tf apply
```

Type `yes` when prompted.

### 4) Capture Terraform outputs
After apply, Terraform outputs values required by:
- `CES/Program.cs`
- `CES/04_configure_ces.sql`

Get outputs:

```bash
tf output
```

Key outputs:
- `eventhub_namespace`
- `eventhub_name`
- `storage_account_url`
- `servicebus_namespace`
- `resource_group_name`
- `vm_principal_id`

### 5) Map outputs into demo configuration
- In `CES/Program.cs`, set:
  - `EventHubNamespace` = `eventhub_namespace`
  - `EventHubName` = `eventhub_name`
  - `BlobStorageUrl` = `storage_account_url`
  - `ServiceBusNamespace` = `servicebus_namespace`
- In `CES/04_configure_ces.sql`, replace:
  - `<YourEventHubsNamespace>` from `eventhub_namespace` (namespace name/FQDN as required by script)
  - `<YourEventHubsInstance>` from `eventhub_name`

### 6) Destroy infrastructure (optional cleanup)

```bash
tf destroy
```
