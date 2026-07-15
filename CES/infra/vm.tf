# ── SQL Server 2025 Developer Edition VM ────────────────────────────────────
#
# Windows Server 2025 image with SQL Server 2025 Developer edition
# preinstalled from the Azure Marketplace:
#   publisher = MicrosoftSQLServer
#   offer     = sql2025-ws2025   (SQL Server 2025 on Windows Server 2025)
#   sku       = entdev-gen2      (Enterprise Developer edition — free dev/test)
#
# A system-assigned managed identity is enabled so SQL Server CES and the
# consumer app can authenticate to Event Hubs, Storage, and Service Bus
# without secrets (see rbac.tf).

resource "azurerm_windows_virtual_machine" "sql" {
  name                = "${var.prefix}-sqlvm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = local.admin_password

  network_interface_ids = [azurerm_network_interface.vm.id]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_type
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2025-ws2025"
    sku       = "entdev-gen2"
    version   = "latest"
  }
}

# ── SQL IaaS Agent extension registration ───────────────────────────────────
# Registers the VM as a SQL Server VM in Azure (portal management, patching)
# and configures the SQL Server connectivity mode / port.

resource "azurerm_mssql_virtual_machine" "sql" {
  virtual_machine_id = azurerm_windows_virtual_machine.sql.id
  sql_license_type   = "PAYG"

  sql_connectivity_port = var.sql_port
  sql_connectivity_type = var.sql_connectivity_type
}
