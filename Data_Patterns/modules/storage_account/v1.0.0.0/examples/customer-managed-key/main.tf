terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "southeastasia"
  name     = "rg-storage-example"
}

resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.this.location
  name                = "vnet-storage-example"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "private" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "snet-storage-example"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.this.location
  name                = "nsg-storage-example"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.private.id
}

resource "azurerm_network_security_rule" "no_internet" {
  access                      = "Deny"
  direction                   = "Outbound"
  name                        = "nsgr-storage-example"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 100
  protocol                    = "*"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "Internet"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.private.address_prefixes[0]
  source_port_range           = "*"
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "example_identity" {
  location            = azurerm_resource_group.this.location
  name                = "uami-storage-example"
  resource_group_name = azurerm_resource_group.this.name
}

data "azurerm_role_definition" "example" {
  name = "Contributor"
}
resource "azurerm_key_vault" "example" {
  #checkov:skip=CKV_AZURE_109:Example code
  #checkov:skip=CKV_AZURE_189:Example code
  #checkov:skip=CKV2_AZURE_32:Example code - private endpoint not in scope
  location                   = azurerm_resource_group.this.location
  name                       = "kv-storage-example"
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    Dep = "IT"
  }
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_crypto" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.example_identity.principal_id
}

#Create a Customer Managed Key for a Storage Account.
resource "azurerm_key_vault_key" "example" {
  #checkov:skip=CKV_AZURE_112:Example code - HSM not required
  #checkov:skip=CKV_AZURE_40:Example code - Expiration not required
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
  key_type     = "RSA"
  key_vault_id = azurerm_key_vault.example.id
  name         = "kvk-storage-example"
  key_size     = 2048

  depends_on = [azurerm_role_assignment.kv_admin, azurerm_role_assignment.kv_crypto]
}

module "this" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
  source = "../.."

  env                  = "dev"
  au                   = "0233985"
  owner                = "Infrastructure Team"
  app_code             = "infra"
  bu                   = "IT"
  resource_type_code   = "st"
  app_name             = "Test Application"
  app_support          = "support@example.com"
  business_unit        = "Information Technology"
  business_owner       = "John Doe"
  product_version      = "1.0.0.0"
  cost_allocation_unit = "Shared"
  budget_id            = "BUD-001"
  criticality          = "High"
  environment          = "Development"

  resource_group_name      = azurerm_resource_group.this.name
  account_kind             = "StorageV2"
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  containers = {
    blob_container0 = {
      name = "blob-container-${random_string.this.result}-0"
    }
    blob_container1 = {
      name = "blob-container-${random_string.this.result}-1"
    }

  }
  customer_managed_key = {
    key_vault_resource_id  = azurerm_key_vault.example.id
    key_name               = azurerm_key_vault_key.example.name
    user_assigned_identity = { resource_id = azurerm_user_assigned_identity.example_identity.id }

  }
  infrastructure_encryption_enabled = true
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.example_identity.id]
  }
  min_tls_version = "TLS1_2"
  network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [var.bypass_ip_cidr]
    virtual_network_subnet_ids = toset([azurerm_subnet.private.id])
  }
  public_network_access_enabled = true
  queues = {
    queue0 = {
      name = "queue-${random_string.this.result}-0"
    }
    queue1 = {
      name = "queue-${random_string.this.result}-1"
    }
  }
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = data.azurerm_role_definition.example.name
      principal_id                     = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
      skip_service_principal_aad_check = false
    },
    role_assignment_2 = {
      role_definition_id_or_name       = "Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    },

  }
  shared_access_key_enabled = true
  shares = {
    share0 = {
      name  = "share-${random_string.this.result}-0"
      quota = 10
    }
    share1 = {
      name  = "share-${random_string.this.result}-1"
      quota = 10
    }
  }
  tables = {
    table0 = {
      name = "table${random_string.this.result}0"
    }
    table1 = {
      name = "table${random_string.this.result}1"
    }
  }
  tags = {
    env   = "Dev"
    owner = "John Doe"
    dept  = "IT"
  }
}
