terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0, < 5.0.0"
    }
  }

  # Backend is supplied by the workflow (-backend-config=...): own state key
  # aiPolicies-{env}-{region_code}.tfstate so policy lifecycle is independent
  # of the AI spoke stack.
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
