locals {
  example_suffix = "autohealenabled"
  azure_region   = "southeastasia"
  name_prefix    = "appsvc-${local.example_suffix}"
  storage_suffix = substr(local.example_suffix, 0, 18)

  naming = {
    resource_group          = { name_unique = "rg-${local.name_prefix}" }
    app_service_plan        = { name_unique = "asp-${local.name_prefix}" }
    app_service             = { name_unique = "app-${local.name_prefix}" }
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
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "P1v2"
  tags = {
    app = "${local.naming.app_service.name_unique}-default"
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.log_analytics_workspace.name}-auto-heal"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
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

  kind                     = "webapp"
  env                      = "tst"
  au                       = "00121"
  app_code                 = "appsvc"
  bu                       = "it"
  owner                    = "ceat"
  business_owner           = "Platform Owner"
  business_unit            = "GTD-ISD"
  criticality              = "T3"
  cost_center              = "383-80572"
  data_classification      = "Business Sensitive"
  compliance               = "BNM RMIT"
  environment              = "Test"
  budget_id                = "83254"
  app_name                 = "mbb-app-service"
  service                  = "AppService"
  os_type                  = azurerm_service_plan.example.os_type
  resource_group_name      = azurerm_resource_group.example.name
  service_plan_resource_id = azurerm_service_plan.example.id
  application_insights = {
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
  }
  auto_heal_setting = {
    setting_1 = {
      action = {
        action_type                    = "Recycle"
        minimum_process_execution_time = "00:01:00"
      }
      trigger = {
        requests = {
          request = {
            count    = 100
            interval = "00:00:30"
          }
        }
        status_code = {
          status_5000 = {
            count             = 5000
            interval          = "00:05:00"
            path              = "/HealthCheck"
            status_code_range = 500
            sub_status        = 0
          }
          status_6000 = {
            count             = 6000
            interval          = "00:05:00"
            path              = "/Get"
            status_code_range = 500
            sub_status        = 0
          }
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  site_config = {

  }
  private_endpoints = {}
}
