locals {
  example_suffix = "logs"
  azure_region   = "southeastasia"
  name_prefix    = "appsvc-${local.example_suffix}"
  storage_suffix = substr(local.example_suffix, 0, 18)

  naming = {
    resource_group          = { name_unique = "rg-${local.name_prefix}" }
    app_service_plan        = { name_unique = "asp-${local.name_prefix}" }
    app_service             = { name_unique = "app-${local.name_prefix}" }
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
  sku_name            = "S1"
  tags = {
    app = "${local.naming.app_service.name_unique}-logs"
  }
}

resource "azurerm_application_insights" "example_staging" {
  application_type    = "web"
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.application_insights.name_unique}-staging"
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example_staging.id
}

resource "azurerm_log_analytics_workspace" "example_production" {
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.log_analytics_workspace.name}-production"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "example_staging" {
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.log_analytics_workspace.name}-staging"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_workspace" "example_development" {
  location            = azurerm_resource_group.example.location
  name                = "${local.naming.log_analytics_workspace.name}-development"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

# This is the module call
module "avm_res_web_site" {
  # checkov:skip=CKV_AZURE_153: Not in scope for this example - web app slot HTTPS redirect behavior is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_15: Not in scope for this example - TLS enforcement is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_222: Not in scope for this example - web app public network access is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_72: Not in scope for this example - remote debugging settings are not required for testing scenarios
  # checkov:skip=CKV_AZURE_88: Not in scope for this example - Azure Files usage is not required for testing scenarios
  # checkov:skip=CKV_AZURE_145: Not in scope for this example - TLS posture is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_221: Not in scope for this example - public network access behavior is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_214: Not in scope for this example - always_on behavior is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_17: Not in scope for this example - client certificate behavior is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_65: Not in scope for this example - detailed error messages are not required for testing scenarios
  # checkov:skip=CKV_AZURE_80: Not in scope for this example - .NET framework version enforcement is not required for testing scenarios
  # checkov:skip=CKV_AZURE_66: Not in scope for this example - failed request tracing is not required for testing scenarios
  # checkov:skip=CKV_AZURE_78: Not in scope for this example - FTP deployment setting is controlled by example inputs for testing scenarios
  # checkov:skip=CKV_AZURE_14: Not in scope for this example - HTTPS redirect behavior is controlled by module defaults for testing scenarios
  # checkov:skip=CKV_AZURE_18: Not in scope for this example - HTTP version enforcement is not required for testing scenarios
  source = "../.."

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
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  }
  deployment_slots = {
    slot1 = {
      name                                           = "development-logs"
      ftp_publish_basic_authentication_enabled       = false
      webdeploy_publish_basic_authentication_enabled = false
      site_config = {
        slot_application_insights_object_key = "development" # This is the key for the slot application insights mapping
        application_stack = {
          dotnet = {
            dotnet_version              = "8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
      logs = {
        app_service_logs = {
          application_logs = {
            file_system_level = {
              file_system_level = "Warning"
            }
          }
          http_logs = {
            file_system_level = {
              file_system = {
                retention_in_days = 7
                retention_in_mb   = 35
              }
            }
          }
        }
      }
    }
    slot2 = {
      name                                           = "staging-logs"
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

      logs = {
        app_service_logs = {
          application_logs = {
            file_system_level = {
              file_system_level = "Off"
            }
          }
          http_logs = {
            file_system_level = {
              file_system = {
                retention_in_days = 7
                retention_in_mb   = 35
              }
            }
          }
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  logs = {
    app_service_logs = {
      # Added validation to ensure that logs object is configured.
      # If file_system_level is set to "Off", then http_logs will have no effect
      # logs set in `logs`
      application_logs = {
        file_system_level = {
          file_system_level = "Off"
        }
      }
      # Added validation to ensure that is http_logs is configured, application_logs must also be configured.
      http_logs = {
        file_system_level = {
          file_system = {
            retention_in_days = 7
            retention_in_mb   = 35
          }
        }
      }
    }
  }
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "8.0"
        use_custom_runtime          = false
        use_dotnet_isolated_runtime = true
      }
    }
  }
  # Creates application insights for slot
  slot_application_insights = {
    development = {
      name                  = "${local.naming.application_insights.name_unique}-development"
      workspace_resource_id = azurerm_log_analytics_workspace.example_development.id
      inherit_tags          = true
    }
  }
}
