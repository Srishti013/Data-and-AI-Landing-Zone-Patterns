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
    azapi = {
      source  = "Azure/azapi"
      version = "2.7"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }

  backend "azurerm" {
    use_oidc               = true
    use_azuread_auth       = true
    allow_no_subscriptions = true
  }
}

provider "azurerm" {
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "extended"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  use_oidc            = true
  storage_use_azuread = true
}

# azapi provider (default config). Required by the ms_foundry module, which
# provisions the AI Foundry account/projects/deployments via azapi_resource.
provider "azapi" {}

# Provider scoped to the management subscription that hosts the central
# Log Analytics Workspace. Used only to read the workspace (data source).
provider "azurerm" {
  alias           = "law"
  subscription_id = local.law_subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  use_oidc            = true
  storage_use_azuread = true
}

# Provider scoped to the platform network subscription that hosts the hub
# virtual network and the shared private DNS zones. Used for cross-subscription
# VNet peering (remote/reverse peering) and to read the existing private DNS
# zones that the private endpoints register into. Falls back to the deployment
# subscription when no "network_sub" entry is supplied in var.subscriptions.
provider "azurerm" {
  alias           = "network"
  subscription_id = local.network_subscription_id

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  use_oidc            = true
  storage_use_azuread = true
}
