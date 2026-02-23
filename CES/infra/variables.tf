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

variable "vm_resource_id" {
  description = "Full resource ID of the Azure VM running SQL Server 2025 (e.g., /subscriptions/.../resourceGroups/.../providers/Microsoft.Compute/virtualMachines/my-sql-vm)"
  type        = string
}
