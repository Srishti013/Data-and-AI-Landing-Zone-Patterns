terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117, < 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }

  backend "azurerm" {
    use_oidc               = true
    use_azuread_auth       = true
    allow_no_subscriptions = true
  }
}

# azapi provider (default config). Required by azapi_update_resource for the
# Backup Vault CMK enablement.
provider "azapi" {}

# Default provider - the Data landing-zone subscription selected in the deploy
# issue. subscription_id is injected by the workflow (sed on var.subscription_id
# in variables.tfvars) so ALL data resources are created in the chosen sub.
provider "azurerm" {
  subscription_id = var.subscription_id
  # Fresh demo subscription: auto-register the RPs Terraform needs.
  resource_provider_registrations = "extended"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  use_oidc            = true
  storage_use_azuread = true
}

# Platform network subscription that hosts the shared Private DNS Zones.
# Resolved by subscription display name via the subscriptions data source, so it
# is region/env agnostic and never carries a raw GUID in tfvars.
provider "azurerm" {
  alias                           = "pvt_dns_zones_sub"
  subscription_id                 = try(local.filtered_subscriptions["pvt_dns_zones_sub"].subscription_guid, var.subscription_id)
  resource_provider_registrations = "extended"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  use_oidc            = true
  storage_use_azuread = true
}

# TEMP-DISABLED (demo 2026-07-21): the central LAW lives in mgmt sub
# mbb-plt-sub-mgmt-prd-<region>-01, which the deploy SPN has NO access to (that
# sub is not in the IAM request). law_sub was therefore filtered out of
# local.filtered_subscriptions -> "Invalid index" at plan. Re-enable this block
# once the SPN gets Log Analytics Reader on mbb-law-ops-pd-<region>-01.
# See also data.tf (workspace data source) and main.tf (App Insights + SQL).
# provider "azurerm" {
#   alias                           = "law_sub"
#   subscription_id                 = local.filtered_subscriptions["law_sub"].subscription_guid
#   resource_provider_registrations = "none"
#
#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = false
#     }
#   }
#
#   use_oidc            = true
#   storage_use_azuread = true
# }
