terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0, < 5.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0, < 5.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }

    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
  }
}
