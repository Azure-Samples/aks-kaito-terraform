terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.14.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.12.1"
    }
  }
}

provider "azurerm" {
  features {}

  storage_use_azuread = true
}

provider "azapi" {
}