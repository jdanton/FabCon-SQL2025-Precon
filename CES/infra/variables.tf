variable "subscription_id" {
  description = "Azure subscription to deploy into. Defaults to the Contoso Ltd demo subscription."
  type        = string
  default     = "424d0f78-5980-4d31-98ec-624616db8e74"
}

variable "prefix" {
  description = "Naming prefix for all resources (e.g., f1ces)"
  type        = string
  default     = "f1ces"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

# ── SQL Server 2025 VM ───────────────────────────────────────────────────────

variable "vm_size" {
  description = "Azure VM size for the SQL Server 2025 VM"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "admin_username" {
  description = "Local administrator username for the VM"
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "Local administrator password for the VM. Leave null to auto-generate a strong password (surfaced via the vm_admin_password output)."
  type        = string
  default     = null
  sensitive   = true
}

variable "os_disk_storage_type" {
  description = "Managed OS disk type for the VM"
  type        = string
  default     = "Premium_LRS"
}

# ── Network exposure ─────────────────────────────────────────────────────────

variable "allowed_source_ip" {
  description = "Source IP/CIDR allowed to reach RDP (3389) and SQL (1433). Defaults to '*' (any) for demo convenience — set to your public IP (e.g. \"203.0.113.4/32\") to lock it down."
  type        = string
  default     = "*"
}

# ── SQL Server connectivity ──────────────────────────────────────────────────

variable "sql_connectivity_type" {
  description = "SQL Server connectivity mode registered via the SQL IaaS Agent extension: LOCAL, PRIVATE, or PUBLIC"
  type        = string
  default     = "PRIVATE"
}

variable "sql_port" {
  description = "TCP port SQL Server listens on"
  type        = number
  default     = 1433
}
