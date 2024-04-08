terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.97.1"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.12.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}