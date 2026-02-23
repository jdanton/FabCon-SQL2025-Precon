# ── Service Bus Namespace (for AI race engineer alerts) ──────────────────────

resource "azurerm_servicebus_namespace" "main" {
  name                = "${var.prefix}-sb-${random_integer.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
}

# ── Service Bus Queue ────────────────────────────────────────────────────────

resource "azurerm_servicebus_queue" "race_engineer_alerts" {
  name         = "race-engineer-alerts"
  namespace_id = azurerm_servicebus_namespace.main.id
}
