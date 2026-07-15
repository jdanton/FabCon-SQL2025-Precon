# ── Key Vault (stores the VM admin password) ────────────────────────────────

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "${var.prefix}-kv-${random_integer.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Use Azure RBAC for data-plane access (consistent with rbac.tf).
  rbac_authorization_enabled = true

  # Demo-friendly: allow the vault to be purged on `terraform destroy`.
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

# Let the principal running Terraform write/read secrets in this vault.
resource "azurerm_role_assignment" "kv_deployer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Let the VM's managed identity read secrets (e.g. retrieve its own password).
resource "azurerm_role_assignment" "kv_vm_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = local.vm_principal_id
}

# Give the deployer role assignment time to propagate to the data plane before
# writing the secret (avoids intermittent 403s on the first apply).
resource "time_sleep" "kv_rbac_propagation" {
  depends_on      = [azurerm_role_assignment.kv_deployer]
  create_duration = "30s"
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = local.admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [time_sleep.kv_rbac_propagation]
}
