locals {
  example_suffix = "existing"
  azure_region   = "southeastasia"
  name_prefix    = "appsvc-${local.example_suffix}"
  storage_suffix = substr(local.example_suffix, 0, 18)

  naming = {
    resource_group          = { name_unique = "rg-${local.name_prefix}" }
    app_service_plan        = { name_unique = "asp-${local.name_prefix}" }
    function_app            = { name_unique = "func-${local.name_prefix}" }
    storage_account         = { name_unique = "st${local.storage_suffix}" }
    log_analytics_workspace = { name = "law-${local.name_prefix}" }
    application_insights    = { name_unique = "appi-${local.name_prefix}" }
  }
}
resource "azurerm_resource_group" "example" {
  location = local.azure_region
  name     = local.naming.resource_group.name_unique
}

resource "azurerm_service_plan" "example" {
  # checkov:skip=CKV_AZURE_225: Not in scope for this example - zone redundancy not required for testing
  # checkov:skip=CKV_AZURE_212: Not in scope for this example - minimum instance count not required for testing
  location            = azurerm_resource_group.example.location
  name                = local.naming.app_service_plan.name_unique
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "P1v2"
  tags = {
    app = "${local.naming.function_app.name_unique}-default"
  }
}

resource "azurerm_storage_account" "example" {
  # checkov:skip=CKV2_AZURE_1: Not in scope for this example - customer-managed key encryption is not required for testing
  # checkov:skip=CKV2_AZURE_38: Not in scope for this example - soft delete configuration is not required for testing
  # checkov:skip=CKV2_AZURE_40: Not in scope for this example - Shared Key authorization not restricted for testing
  # checkov:skip=CKV2_AZURE_47: Not in scope for this example - blob anonymous access restriction not required for testing
  # checkov:skip=CKV2_AZURE_41: Not in scope for this example - SAS expiration policy not required for testing
  # checkov:skip=CKV2_AZURE_33: Not in scope for this example - private endpoint is not required for testing
  # checkov:skip=CKV_AZURE_44: Not in scope for this example - TLS version set via min_tls_version where applicable
  # checkov:skip=CKV_AZURE_43: Not in scope for this example - storage account naming follows module convention
  # checkov:skip=CKV_AZURE_35: Not in scope for this example - default deny network rule not required for testing
  # checkov:skip=CKV_AZURE_59: Not in scope for this example - public access restriction not required for testing
  # checkov:skip=CKV_AZURE_33: Not in scope for this example - Storage Queue logging not required for testing
  # checkov:skip=CKV_AZURE_206: Not in scope for this example - ZRS replication is sufficient for testing
  # checkov:skip=CKV_AZURE_190: Not in scope for this example - blob public access restriction not required for testing
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.example.location
  name                     = local.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.log_analytics_workspace.name}-existing-resources"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "example" {
  application_type    = "web"
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.application_insights.name_unique}-existing-resources"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_log_analytics_workspace" "example_staging" {
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.log_analytics_workspace.name}-existing-resources-staging"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "example_staging" {
  application_type    = "web"
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.application_insights.name_unique}-existing-resources-staging"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example_staging.id
}

module "avm_res_web_site" {
  # checkov:skip=CKV_AZURE_145: Not in scope for this example - TLS version managed at platform level
  # checkov:skip=CKV_AZURE_221: Not in scope for this example - public network access required for testing
  # checkov:skip=CKV_AZURE_214: Not in scope for this example - always on not required for testing
  # checkov:skip=CKV_AZURE_17: Not in scope for this example - client certificates not required for testing
  # checkov:skip=CKV_AZURE_65: Not in scope for this example - detailed error messages not required for testing
  # checkov:skip=CKV_AZURE_80: Not in scope for this example - .NET framework version managed at platform level
  # checkov:skip=CKV_AZURE_66: Not in scope for this example - failed request tracing not required for testing
  # checkov:skip=CKV_AZURE_78: Not in scope for this example - FTP state managed via ftps_state configuration
  # checkov:skip=CKV_AZURE_14: Not in scope for this example - HTTPS redirect managed via https_only variable
  # checkov:skip=CKV_AZURE_18: Not in scope for this example - HTTP version managed at platform level
  # checkov:skip=CKV_AZURE_15: Not in scope for this example - TLS version managed at platform level
  # checkov:skip=CKV_AZURE_222: Not in scope for this example - public network access required for testing
  # checkov:skip=CKV_AZURE_72: Not in scope for this example - remote debugging not required for testing
  # checkov:skip=CKV_AZURE_88: Not in scope for this example - Azure Files not required for testing
  # checkov:skip=CKV_AZURE_153: Not in scope for this example - HTTPS redirect managed via https_only variable
  source = "../../"

  kind                = "webapp"
  env                 = "tst"
  au                  = "00121"
  app_code            = "appsvc"
  bu                  = "it"
  owner               = "ceat"
  business_owner      = "Platform Owner"
  business_unit       = "GTD-ISD"
  criticality         = "T3"
  cost_center         = "383-80572"
  data_classification = "Business Sensitive"
  compliance          = "BNM RMIT"
  environment         = "Test"
  budget_id           = "83254"
  app_name            = "mbb-app-service"
  service             = "AppService"
  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = nonsensitive(azurerm_application_insights.example.connection_string)
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = nonsensitive(azurerm_application_insights.example.instrumentation_key)
  }
  deployment_slots = {
    slot2 = {
      name                                           = "staging"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        # Uses existing application insights
        application_insights_connection_string = nonsensitive(azurerm_application_insights.example_staging.connection_string)
        application_insights_key               = nonsensitive(azurerm_application_insights.example_staging.instrumentation_key)
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
  }
  # Uses existing application insights
  enable_application_insights = false
  enable_telemetry            = var.enable_telemetry
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # Uses an existing storage account
  storage_account_name    = azurerm_storage_account.example.name
  vnet_image_pull_enabled = true
}
