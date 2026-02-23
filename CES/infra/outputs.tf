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
