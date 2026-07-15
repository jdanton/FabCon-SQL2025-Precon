# ── Outputs ──────────────────────────────────────────────────────────────────
# These values map directly to the configuration placeholders in Program.cs
# and 04_configure_ces.sql.

output "eventhub_namespace" {
  description = "Event Hubs FQDN → Program.cs EventHubNamespace & 04_configure_ces.sql <YourEventHubsNamespace>"
  value       = "${azurerm_eventhub_namespace.main.name}.servicebus.windows.net"
}

output "eventhub_name" {
  description = "Event Hub instance name → Program.cs EventHubName & 04_configure_ces.sql <YourEventHubsInstance>"
  value       = azurerm_eventhub.f1_race_events.name
}

output "storage_account_url" {
  description = "Blob storage URL → Program.cs BlobStorageUrl"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "servicebus_namespace" {
  description = "Service Bus FQDN → Program.cs ServiceBusNamespace"
  value       = "${azurerm_servicebus_namespace.main.name}.servicebus.windows.net"
}

output "resource_group_name" {
  description = "Resource group containing all demo resources"
  value       = azurerm_resource_group.main.name
}

output "vm_principal_id" {
  description = "VM's managed identity principal ID (for verification)"
  value       = local.vm_principal_id
}

# ── SQL Server 2025 VM connection details ───────────────────────────────────

output "vm_name" {
  description = "Name of the SQL Server 2025 VM"
  value       = azurerm_windows_virtual_machine.sql.name
}

output "vm_public_ip" {
  description = "Public IP address of the SQL Server 2025 VM (RDP / SSMS target)"
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_admin_username" {
  description = "Local administrator username for the VM"
  value       = var.admin_username
}

output "vm_admin_password" {
  description = "Local administrator password for the VM (auto-generated unless admin_password was supplied). View with: terraform output -raw vm_admin_password"
  value       = local.admin_password
  sensitive   = true
}

output "rdp_command" {
  description = "Convenience RDP connection hint"
  value       = "mstsc /v:${azurerm_public_ip.vm.ip_address}  (user: ${var.admin_username})"
}

# ── Key Vault ────────────────────────────────────────────────────────────────

output "key_vault_name" {
  description = "Key Vault holding the VM admin password"
  value       = azurerm_key_vault.main.name
}

output "vm_admin_password_secret_name" {
  description = "Secret name for the VM admin password. Retrieve with: az keyvault secret show --vault-name <key_vault_name> --name vm-admin-password --query value -o tsv"
  value       = azurerm_key_vault_secret.vm_admin_password.name
}
