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

#Creating a Network Security Group with a rule allowing SSH access from the executor's IP address.
resource "azurerm_network_security_group" "ssh" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "test123"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = jsondecode(data.http.public_ip.response_body).ip
    source_port_range          = "*"
  }
}

locals {
  address_space = "10.0.0.0/16"
  subnets = {
    for i in range(3) :
    "subnet${i}" => {
      name             = "example-resource${i}"
      address_prefixes = [cidrsubnet(local.address_space, 8, i)]
      network_security_group = {
        id = azurerm_network_security_group.ssh.id
      }
    }
  }
}

#Creating a virtual network with specified configurations, subnets, and associated Network Security Groups.
module "vnet" {
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

  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  subnets             = local.subnets
}

# Fetching the public IP address of the Terraform executor.
data "http" "public_ip" {
  method = "GET"
  url    = "http://api.ipify.org?format=json"
}