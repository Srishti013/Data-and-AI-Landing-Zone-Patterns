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
  # skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "dep" {
  location = "eastus"
  name     = "rg-complete-dep-example"
}

resource "azurerm_user_assigned_identity" "dep_uai" {
  location            = azurerm_resource_group.dep.location
  name                = "uai-complete-example"
  resource_group_name = azurerm_resource_group.dep.name
}

module "resource_group" {
  source = "../../"


  # MBB Naming Module Variables (Required)
  env                = "dev"
  au                 = "0233985"
  owner              = "CloudOps"
  resource_type_code = "rg"
  app_code           = "myapp"
  bu                 = "IT"

  # Mandatory Tags (Required)
  app_name            = "My Resource Group"
  app_support         = "support@company.com"
  business_unit       = "IT Operations"
  business_owner      = "John Doe"
  product_version     = "1.0.0"
  cost_center         = "CC1234"
  budget_id           = "BUD001"
  data_classification = "Internal"
  criticality         = "Medium"
  environment         = "Development"

  lock = {
    kind = "CanNotDelete"
    name = "myCustomLockName"

  }
  role_assignments = {
    "roleassignment1" = {
      principal_id               = azurerm_user_assigned_identity.dep_uai.principal_id
      role_definition_id_or_name = "Reader"
    },
    "role_assignment2" = {
      role_definition_id_or_name       = "/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1" # Storage Blob Data Reader Role Guid 
      principal_id                     = azurerm_user_assigned_identity.dep_uai.principal_id
      skip_service_principal_aad_check = false
      condition_version                = "2.0"
      condition                        = <<-EOT
(
 (
  !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'} AND NOT SubOperationMatches{'Blob.List'})
 )
 OR 
 (
  @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals 'blobs-example-container'
 )
)
EOT
    }
  }
  tags = {
    "hidden-title" = "This is visible in the resource name"
    Environment    = "Non-Prod"
    Role           = "DeploymentValidation"
  }
}

