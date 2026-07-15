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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
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

# ── Auto-generated VM administrator password ────────────────────────────────
# Used when var.admin_password is not supplied. Meets Azure Windows complexity
# rules (12-72 chars, 3 of 4 character classes).

resource "random_password" "vm_admin" {
  length           = 24
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!#$%*()-_=+"
}

locals {
  admin_password = coalesce(var.admin_password, random_password.vm_admin.result)
}
