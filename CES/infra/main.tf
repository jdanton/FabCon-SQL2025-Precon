terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ── Resource Group ──────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.prefix}-demo"
  location = var.location
}

# ── Random suffix for globally unique names ─────────────────────────────────

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

# ── Data source: look up the VM's system-assigned managed identity ──────────

data "azurerm_virtual_machine" "sql_vm" {
  name                = split("/", var.vm_resource_id)[8]
  resource_group_name = split("/", var.vm_resource_id)[4]
}
