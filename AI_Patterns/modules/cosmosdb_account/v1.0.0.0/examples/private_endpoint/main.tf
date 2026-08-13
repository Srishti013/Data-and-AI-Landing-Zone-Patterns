terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example VNet and Subnet for Private Endpoint
resource "azurerm_virtual_network" "example" {
  name                = "vnet-cosmos-example"
  location            = "southeastasia"
  resource_group_name = "rg-data-dev"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  #checkov:skip=CKV2_AZURE_31:NSG is managed outside this example
  name                 = "snet-pe-cosmos"
  resource_group_name  = "rg-data-dev"
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Example Private DNS Zone for Cosmos DB SQL API
resource "azurerm_private_dns_zone" "cosmos_sql" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = "rg-data-dev"
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_sql" {
  name                  = "vnet-link-cosmos"
  resource_group_name   = "rg-data-dev"
  private_dns_zone_name = azurerm_private_dns_zone.cosmos_sql.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Cosmos DB with Private Endpoint
module "cosmos_with_pe" {
  source              = "../../"
  resource_group_name = "rg-data-dev"

  # Naming module inputs
  env                  = "dev"
  org                  = "mbb"
  region_code          = "sea"
  region               = "southeastasia"
  base_name            = "cosmos"
  au                   = "0233985"
  app_code             = "data"
  bu                   = "it"
  owner                = "platform"
  app_name             = "data-platform"
  app_support          = "data-platform@contoso.com"
  business_unit        = "data"
  business_owner       = "data-owner"
  product_name         = "cosmosdb_account"
  product_version      = "1.0.0.0"
  cost_center          = "CC001"
  cost_allocation_unit = "CAU001"
  budget_id            = "BUD001"
  budget_limit         = "10000"
  cost_alert_threshold = "8000"
  data_classification  = "Confidential"
  compliance_required  = "Yes"
  compliance           = "ISO27001"
  criticality          = "High"
  environment          = "dev"
  status               = "Live"
  country              = "th"

  # Cosmos DB Configuration
  kind                          = "GlobalDocumentDB" # For SQL/NoSQL API
  offer_type                    = "Standard"
  public_network_access_enabled = false # Disable public access when using private endpoints

  consistency_policy = {
    consistency_level = "Session"
  }

  geo_locations = [
    {
      location          = "southeastasia"
      failover_priority = 0
      zone_redundant    = true
    }
  ]

  # Private Endpoint Configuration
  private_endpoints = {
    pe_sql = {
      name                            = "pe-cosmos-sql"
      subnet_resource_id              = azurerm_subnet.example.id
      subresource_name                = "Sql" # For NoSQL/SQL API. Use "MongoDB", "Cassandra", "Table", or "Gremlin" for other APIs
      private_dns_zone_resource_ids   = [azurerm_private_dns_zone.cosmos_sql.id]
      private_dns_zone_group_name     = "default"
      private_service_connection_name = "psc-cosmos-sql"
      network_interface_name          = "nic-pe-cosmos-sql"

      tags = {
        Environment = "Development"
        Purpose     = "Private Endpoint"
      }
    }
  }

  # Manage DNS zone groups (set to false if using Azure Policy)
  private_endpoints_manage_dns_zone_group = true

  tags = {
    Example = "PrivateEndpoint"
  }
}

# Output Private Endpoint details
output "cosmos_private_endpoints" {
  description = "Private endpoint details"
  value       = module.cosmos_with_pe.private_endpoints
}

output "cosmos_endpoint" {
  description = "Cosmos DB endpoint"
  value       = module.cosmos_with_pe.endpoint
}
