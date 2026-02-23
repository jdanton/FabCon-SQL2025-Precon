# ── RBAC Role Assignments for the SQL Server VM's managed identity ────────────
#
# The VM's system-assigned identity is used by:
#   - SQL Server CES to send events to Event Hubs
#   - The consumer app (running on the VM) to read events, write checkpoints,
#     and send race engineer alerts

locals {
  vm_principal_id = data.azurerm_virtual_machine.sql_vm.identity[0].principal_id
}

# SQL Server CES → Event Hubs (send events)
resource "azurerm_role_assignment" "eventhub_sender" {
  scope                = azurerm_eventhub_namespace.main.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = local.vm_principal_id
}

# Consumer → Event Hubs (read events)
resource "azurerm_role_assignment" "eventhub_receiver" {
  scope                = azurerm_eventhub_namespace.main.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = local.vm_principal_id
}

# Consumer → Blob Storage (write checkpoints)
resource "azurerm_role_assignment" "storage_contributor" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.vm_principal_id
}

# Consumer → Service Bus (send race engineer alerts)
resource "azurerm_role_assignment" "servicebus_sender" {
  scope                = azurerm_servicebus_namespace.main.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = local.vm_principal_id
}
