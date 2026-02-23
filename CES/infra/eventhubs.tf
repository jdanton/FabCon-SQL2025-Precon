# ── Event Hubs Namespace ─────────────────────────────────────────────────────

resource "azurerm_eventhub_namespace" "main" {
  name                = "${var.prefix}-ns-${random_integer.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  capacity            = 1
}

# ── Event Hub Instance ───────────────────────────────────────────────────────

resource "azurerm_eventhub" "f1_race_events" {
  name              = "f1-race-events"
  namespace_id      = azurerm_eventhub_namespace.main.id
  partition_count   = 1
  message_retention = 1
}
