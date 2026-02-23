# ── Storage Account (for consumer checkpointing) ────────────────────────────

resource "azurerm_storage_account" "main" {
  name                     = "${var.prefix}store${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ── Blob Container for checkpoints ──────────────────────────────────────────

resource "azurerm_storage_container" "checkpoints" {
  name                  = "f1-ces-checkpoints"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}
