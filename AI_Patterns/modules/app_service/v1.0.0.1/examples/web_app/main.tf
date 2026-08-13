locals {
  example_suffix = "webapp"
  azure_region   = "southeastasia"
  name_prefix    = "appsvc-${local.example_suffix}"
  storage_suffix = substr(local.example_suffix, 0, 18)

  naming = {
    resource_group          = { name_unique = "rg-${local.name_prefix}" }
    app_service_plan        = { name_unique = "asp-${local.name_prefix}" }
    function_app            = { name_unique = "func-${local.name_prefix}" }
    log_analytics_workspace = { name = "law-${local.name_prefix}" }
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
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "P1v2"
  tags = {
    app = local.naming.function_app.name_unique
  }
}

resource "azurerm_log_analytics_workspace" "example_production" {
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.log_analytics_workspace.name}-production"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

module "avm_res_web_site" {
  # checkov:skip=CKV_AZURE_145: Not in scope for this example - function app TLS version is inherited from module defaults/inputs
  # checkov:skip=CKV_AZURE_221: Not in scope for this example - public network access behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_214: Not in scope for this example - always_on is controlled by example/module settings
  # checkov:skip=CKV_AZURE_17: Not in scope for this example - client certificate behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_65: Not in scope for this example - detailed errors setting is controlled by example/module settings
  # checkov:skip=CKV_AZURE_80: Not in scope for this example - .NET version behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_66: Not in scope for this example - failed request tracing behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_78: Not in scope for this example - FTP deployment behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_14: Not in scope for this example - HTTPS redirection is controlled by example/module settings
  # checkov:skip=CKV_AZURE_18: Not in scope for this example - HTTP version behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_15: Not in scope for this example - TLS minimum version is controlled by example/module settings
  # checkov:skip=CKV_AZURE_222: Not in scope for this example - public network access behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_72: Not in scope for this example - remote debugging behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_88: Not in scope for this example - Azure Files/storage mounting behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_153: Not in scope for this example - HTTPS redirection for web app slots is controlled by example/module settings
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
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  }
  auth_settings_v2 = {
    default = {
      auth_enabled     = true
      default_provider = "okta"
      custom_oidc_v2 = {
        default = {
          name                          = "example_oidc_provider"
          client_id                     = "your-client-id"
          openid_configuration_endpoint = "https://test-config-endpoint.com/.well-known/openid-configuration"
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  site_config = {

  }
  private_endpoints = {}
}
