terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.

## Section to create a resource group for the virtual network
# This creates a resource group in the specified location
resource "azurerm_resource_group" "this" {
  location = "southeastasia"
  name     = "rg-example"
}

# This is the module call
# Do not specify location here as the PIN data will be used to determine the deployment region
module "virtualnetwork" {
  source = "../../"

  env             = "dev"
  au              = "0233985"
  owner           = "Infrastructure Team"
  app_code        = "infra"
  bu              = "IT"
  product_version = "1.0"
  app_name        = "Test Application"
  app_support     = "support@example.com"
  business_unit   = "Information Technology"
  business_owner  = "John Doe"
  budget_id       = "BUD-001"
  criticality     = "High"
  environment     = "Development"
  service         = "vnet"

  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  subnets = {
    # Subnet with service endpoints for all regions
    subnet_all_endpoints = {
      name           = "subnet-all-regions"
      address_prefix = "10.0.0.0/24"
      # New format: allow all regions with "*"
      service_endpoints_with_location = [
        {
          service   = "Microsoft.Storage"
          locations = ["southeastasia", "southeastasia"]
        },
        {
          service   = "Microsoft.Sql"
          locations = ["southeastasia"]
        },
        {
          service   = "Microsoft.AzureCosmosDB"
          locations = ["*"]
        },
        {
          service   = "Microsoft.KeyVault"
          locations = ["*"]
        },
        {
          service   = "Microsoft.ServiceBus"
          locations = ["*"]
        },
        {
          service   = "Microsoft.EventHub"
          locations = ["*"]
        },
        {
          service   = "Microsoft.Web"
          locations = ["*"]
        },
        {
          service   = "Microsoft.CognitiveServices"
          locations = ["*"]
        }
        # Container registry is in preview and not available in all regions
        # {
        #   service   = "Microsoft.ContainerRegistry"
        #   locations = ["*"]
        # },
      ]
    }
    subnet_storage_global = {
      name           = "subnet-storage-global"
      address_prefix = "10.0.1.0/24"
      service_endpoints_with_location = [
        {
          service   = "Microsoft.Storage.Global"
          locations = ["*"]
        },
      ]
    }
  }
}