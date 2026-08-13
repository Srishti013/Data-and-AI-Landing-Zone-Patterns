terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate a secure password for PostgreSQL
resource "random_password" "postgres_password" {
  length           = 16
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  override_special = "!@#$%&*()-_=+[]{}<>:?"
  special          = true
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  location = "Central US"
  name     = "rg-postgres-backup-tst"
}

# Create a PostgreSQL Server and Database
resource "azurerm_postgresql_server" "example" {
  #checkov:skip=CKV_AZURE_130: "Infrastructure encryption not required for backup test example"
  #checkov:skip=CKV_AZURE_128: "Threat detection policy not required for backup test example"
  #checkov:skip=CKV2_AZURE_42: "Private endpoint not required for backup test example"
  location                         = azurerm_resource_group.example.location
  name                             = "psql-backup-tst"
  resource_group_name              = azurerm_resource_group.example.name
  sku_name                         = "GP_Gen5_4"
  ssl_enforcement_enabled          = true
  version                          = "11"
  administrator_login              = "psqladmin"
  administrator_login_password     = random_password.postgres_password.result
  auto_grow_enabled                = true
  backup_retention_days            = 7
  geo_redundant_backup_enabled     = true
  public_network_access_enabled    = false
  ssl_minimal_tls_version_enforced = "TLS1_2"
  storage_mb                       = 640000
}

resource "azurerm_postgresql_database" "example" {
  charset             = "UTF8"
  collation           = "English_United States.1252"
  name                = "psqldb-backup-tst"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
}

# Module Call for PostgreSQL Backup Vault and Backup Policy
module "backup_vault" {
  source = "../../"

  # Required naming and tag variables
  env            = "tst"
  au             = "0000001"
  owner          = "ITOpsTeam"
  app_code       = "bkp"
  bu             = "IT"
  app_name       = "backup-test"
  business_unit  = "IT"
  business_owner = "admin@example.com"
  service        = "backup"
  budget_id      = "BUD001"
  criticality    = "Low"
  environment    = "Testing"

  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  resource_group_name = azurerm_resource_group.example.name
  # Map-based configuration for PostgreSQL backup instances
  backup_instances = {
    postgresql = {
      type                           = "postgresql"
      name                           = "psqldb-backup-tst-instance"
      backup_policy_key              = "postgresql"
      postgresql_database_id         = azurerm_postgresql_database.example.id
      postgresql_key_vault_secret_id = azurerm_key_vault_secret.postgres_password.id
    }
  }
  # Map-based configuration for PostgreSQL backup policies
  backup_policies = {
    postgresql = {
      type                            = "postgresql"
      name                            = "psql-backup-tst-backup-policy"
      backup_repeating_time_intervals = ["R/2024-09-17T06:33:16+00:00/PT4H"]
      default_retention_duration      = "P4M"
      retention_rules = [
        {
          name     = "Daily"
          duration = "P7D"
          priority = 25
          criteria = [{ absolute_criteria = "FirstOfDay" }]
        }
      ]
    }
  }
  enable_telemetry = true
  # System-assigned identity is required for role assignments
  managed_identities = {
    system_assigned = true
  }
  role_assignments = {
    postgresql_Contributor = {
      principal_id               = "system-assigned"
      role_definition_id_or_name = "Contributor"
      scope                      = azurerm_postgresql_server.example.id
    }
    key_vault_secrets_user = {
      principal_id               = "system-assigned"
      role_definition_id_or_name = "Key Vault Secrets User"
      scope                      = azurerm_key_vault.example.id
    }
  }
}

# Create a Key Vault to store PostgreSQL credentials
resource "azurerm_key_vault" "example" {
  #checkov:skip=CKV_AZURE_189: "Public network access not required to be disabled for backup test example"
  #checkov:skip=CKV_AZURE_109: "Firewall rules not required for backup test example"
  #checkov:skip=CKV_AZURE_110: "Purge protection disabled intentionally for backup test example"
  #checkov:skip=CKV_AZURE_42: "Soft delete retention configured for backup test example"
  #checkov:skip=CKV2_AZURE_32: "Private endpoint not required for backup test example"
  location                   = azurerm_resource_group.example.location
  name                       = "kv-postgres-backup-tst"
  resource_group_name        = azurerm_resource_group.example.name
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  access_policy {
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
}

# Store PostgreSQL admin credentials in Key Vault
resource "azurerm_key_vault_secret" "postgres_password" {
  #checkov:skip=CKV_AZURE_114: "Content type not required for backup test example"
  #checkov:skip=CKV_AZURE_41: "Expiration date not required for backup test example"
  key_vault_id = azurerm_key_vault.example.id
  name         = "postgres-admin-password"
  value        = random_password.postgres_password.result
}

# Get current client config for Key Vault access policy
data "azurerm_client_config" "current" {}

