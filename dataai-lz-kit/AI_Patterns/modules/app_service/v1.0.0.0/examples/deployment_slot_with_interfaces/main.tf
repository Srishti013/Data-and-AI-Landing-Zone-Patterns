locals {
  example_suffix = "deploymentslotwithinterfaces"
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
    virtual_network         = { name_unique = "vnet-${local.name_prefix}" }
    subnet                  = { name_unique = "snet-${local.name_prefix}" }
    user_assigned_identity  = { name_unique = "uami-${local.name_prefix}" }
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
    app = "${local.naming.function_app.name_unique}-slots"
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
  name                     = "${local.naming.storage_account.name_unique}dmv"
  resource_group_name      = azurerm_resource_group.example.name

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_virtual_network" "example" {
  location            = azurerm_resource_group.example.location
  name                = local.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "example" {
  # checkov:skip=CKV2_AZURE_31: Not in scope for this example - subnet NSG association is not required for testing
  address_prefixes     = ["192.168.0.0/24"]
  name                 = local.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_private_dns_zone" "example" {
  name                = local.azurerm_private_dns_zone_resource_name
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "${azurerm_virtual_network.example.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  resource_group_name   = azurerm_resource_group.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
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
  name                = "${local.naming.log_analytics_workspace.name}-prod"
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

resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.example.location
  name                = local.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

module "avm_res_web_site" {
  # checkov:skip=CKV_AZURE_145: Not in scope for this example - TLS version managed at platform level
  # checkov:skip=CKV_AZURE_221: Not in scope for this example - public network access required for testing
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
  # checkov:skip=CKV_AZURE_88: Not in scope for this example - storage mounting behavior is controlled by example/module settings
  # checkov:skip=CKV_AZURE_153: Not in scope for this example - HTTPS redirection for web app slots is controlled by example/module settings
  source = "../../"

  kind                = "functionapp"
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
  # Creates application insights
  application_insights = {
    name                  = "${local.naming.application_insights.name_unique}-production"
    workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  }
  deployment_slots = {
    slot1 = {
      name = "development-env"
      site_config = {
        slot_application_insights_object_key = "development" # This is the key for the slot application insights mapping
        application_stack = {
          dotnet = {
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }
    }
    slot2 = {
      name = "staging-env"
      site_config = {
        # Uses existing application insights
        application_insights_connection_string = nonsensitive(azurerm_application_insights.example_staging.connection_string)
        application_insights_key               = nonsensitive(azurerm_application_insights.example_staging.instrumentation_key)
        application_stack = {
          dotnet = {
            dotnet_version              = "v8.0"
            use_custom_runtime          = false
            use_dotnet_isolated_runtime = true
          }
        }
      }

      # lock = {
      #   kind = "CanNotDelete"
      # }

      public_network_access_enabled = false
      private_endpoints = {
        slot_primary = {
          name                          = "slot-primary"
          private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
          subnet_resource_id            = azurerm_subnet.example.id
          ip_configurations = {
            primary = {
              name               = "api.${azurerm_private_dns_zone.example.name}"
              private_ip_address = "192.168.0.4"
            }
          }
          tags = {
            environment = "staging"
          }
        }
      }
    }
  }
  enable_telemetry = var.enable_telemetry
  managed_identities = {
    # Identities can only be used with the Standard SKU
    system_assigned = true
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.user.id
    ]
  }
  site_config = {
    application_stack = {
      dotnet = {
        dotnet_version              = "v8.0"
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
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # Uses an existing storage account
  storage_account_name = azurerm_storage_account.example.name
}


