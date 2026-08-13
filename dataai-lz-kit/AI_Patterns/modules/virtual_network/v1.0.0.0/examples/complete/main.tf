terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
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

# This allows us to randomize the region for the resource group.
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "southeastasia"
  name     = "rg-example"
}

#Creating a Route Table with a unique name in the specified location.
resource "azurerm_route_table" "this" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name
}

# Creating a DDoS Protection Plan in the specified location.
resource "azurerm_network_ddos_protection_plan" "this" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name
}

# Creating a NAT Gateway in the specified location.
resource "azurerm_nat_gateway" "this" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name
}

# Fetching the public IP address of the Terraform executor used for NSG
data "http" "public_ip" {
  method = "GET"
  url    = "http://api.ipify.org?format=json"
}

resource "azurerm_network_security_group" "https" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPS"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = jsondecode(data.http.public_ip.response_body).ip
    source_port_range          = "*"
  }
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_storage_account" "this" {
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version not in scope
  #checkov:skip=CKV_AZURE_206:Example code - replication not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - shared key auth not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - SAS expiration policy not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - blob anonymous access not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft-delete not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  #checkov:skip=CKV_AZURE_43:Example code - naming rules not in scope
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = "example-resource"
  resource_group_name      = azurerm_resource_group.this.name
}

resource "azurerm_subnet_service_endpoint_storage_policy" "this" {
  location            = azurerm_resource_group.this.location
  name                = "sep-example-seed"
  resource_group_name = azurerm_resource_group.this.name

  definition {
    name = "name1"
    service_resources = [
      azurerm_resource_group.this.id,
      azurerm_storage_account.this.id
    ]
    description = "definition1"
    service     = "Microsoft.Storage"
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name
}

#Defining the first virtual network (vnet-1) with its subnets and settings.
module "vnet1" {
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

  address_space       = ["192.168.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  ddos_protection_plan = {
    id = azurerm_network_ddos_protection_plan.this.id
    # due to resource cost
    enable = false
  }
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                           = "sendToLogAnalytics"
      workspace_resource_id          = azurerm_log_analytics_workspace.this.id
      log_analytics_destination_type = "Dedicated"
    }
  }
  dns_servers = {
    dns_servers = ["8.8.8.8"]
  }
  enable_vm_protection = true
  encryption = {
    enabled = true
    #enforcement = "DropUnencrypted"  # NOTE: This preview feature requires approval, leaving off in example: Microsoft.Network/AllowDropUnecryptedVnet
    enforcement = "AllowUnencrypted"
  }
  flow_timeout_in_minutes = 30
  role_assignments = {
    role1 = {
      principal_id               = azurerm_user_assigned_identity.this.principal_id
      role_definition_id_or_name = "Contributor"
    }
  }
  subnets = {
    subnet0 = {
      name                            = "example-resource0"
      default_outbound_access_enabled = false
      #sharing_scope                   = "Tenant"  #NOTE: This preview feature requires approval, leaving off in example: Microsoft.Network/EnableSharedVNet
      address_prefixes = ["192.168.0.0/24", "192.168.2.0/24"]
    }
    subnet1 = {
      name                            = "example-resource1"
      address_prefixes                = ["192.168.1.0/24"]
      default_outbound_access_enabled = false
      delegations = [{
        name = "Microsoft.Web.serverFarms"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
      nat_gateway = {
        id = azurerm_nat_gateway.this.id
      }
      network_security_group = {
        id = azurerm_network_security_group.https.id
      }
      route_table = {
        id = azurerm_route_table.this.id
      }
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      service_endpoint_policies = {
        policy1 = {
          id = azurerm_subnet_service_endpoint_storage_policy.this.id
        }
      }
      role_assignments = {
        role1 = {
          principal_id               = azurerm_user_assigned_identity.this.principal_id
          role_definition_id_or_name = "Contributor"
        }
      }
    }
  }
}

module "vnet2" {
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

  address_space       = ["10.0.0.0/27"]
  resource_group_name = azurerm_resource_group.this.name
  encryption = {
    enabled     = true
    enforcement = "AllowUnencrypted"
  }
  peerings = {
    peertovnet1 = {
      name                                  = "example-resource-vnet2-to-vnet1"
      remote_virtual_network_resource_id    = module.vnet1.resource_id
      allow_forwarded_traffic               = true
      allow_gateway_transit                 = true
      allow_virtual_network_access          = true
      do_not_verify_remote_gateways         = false
      enable_only_ipv6_peering              = false
      use_remote_gateways                   = false
      create_reverse_peering                = true
      reverse_name                          = "example-resource-vnet1-to-vnet2"
      reverse_allow_forwarded_traffic       = false
      reverse_allow_gateway_transit         = false
      reverse_allow_virtual_network_access  = true
      reverse_do_not_verify_remote_gateways = false
      reverse_enable_only_ipv6_peering      = false
      reverse_use_remote_gateways           = false
    }
  }
}
