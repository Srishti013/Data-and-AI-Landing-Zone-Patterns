locals {
  example_suffix = "interfaces"
  azure_region   = "southeastasia"
  name_prefix    = "appsvc-${local.example_suffix}"
  storage_suffix = substr(local.example_suffix, 0, 18)

  naming = {
    resource_group         = { name_unique = "rg-${local.name_prefix}" }
    app_service_plan       = { name_unique = "asp-${local.name_prefix}" }
    function_app           = { name_unique = "func-${local.name_prefix}" }
    storage_account        = { name_unique = "st${local.storage_suffix}" }
    application_insights   = { name_unique = "appi-${local.name_prefix}" }
    virtual_network        = { name_unique = "vnet-${local.name_prefix}" }
    subnet                 = { name_unique = "snet-${local.name_prefix}" }
    user_assigned_identity = { name_unique = "uami-${local.name_prefix}" }
    network_security_group = { name_unique = "nsg-${local.name_prefix}" }
    network_interface      = { name_unique = "nic-${local.name_prefix}" }
    virtual_machine        = { name_unique = "vm-${local.name_prefix}" }
  }
}

# data "azurerm_client_config" "this" {}

# data "azurerm_role_definition" "example" {
#   name = "Contributor"
# }

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
    app = "${local.naming.function_app.name_unique}-interfaces"
  }
}

resource "azurerm_storage_account" "example" {
  # checkov:skip=CKV2_AZURE_1: Not in scope for this example - customer-managed keys are not required for testing
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
}

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "law-test-001"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
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
  application_insights = {
    name                  = local.naming.application_insights.name_unique
    resource_group_name   = azurerm_resource_group.example.name
    application_type      = "web"
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    tags = {
      environment = "dev-tf"
    }
  }
  diagnostic_settings = {
    diagnostic_settings_1 = {
      name                  = "dia_settings_1"
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
    }
  }
  enable_application_insights = true
  enable_telemetry            = var.enable_telemetry
  managed_identities = {
    # Identities can only be used with the Standard SKU
    system_assigned = true
    user_assigned_resource_ids = [
      azurerm_user_assigned_identity.user.id
    ]
  }
  private_endpoints = {
    # Use of private endpoints requires Standard SKU
    primary = {
      name                          = "primary-interfaces"
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.example.id]
      subnet_resource_id            = azurerm_subnet.example.id

      # lock = {
      #   /*
      #   kind = "ReadOnly"
      #   */

      #   /*
      #   kind = "CanNotDelete"
      #   */
      # }

      # role_assignments = {
      #   role_assignment_1 = {
      #     role_definition_id_or_name = data.azurerm_role_definition.example.id
      #     principal_id               = data.azurerm_client_config.this.object_id
      #   }
      # }

      tags = {
        webapp = "${local.naming.function_app.name_unique}-interfaces"
      }

    }

  }
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  # Uses an existing storage account
  storage_account_name = azurerm_storage_account.example.name
}


/*
check "dns" {
  data "azurerm_private_dns_a_record" "assertion" {
    name                = local.split_subdomain[0]
    zone_name           = azurerm_private_dns_zone.example.name
    resource_group_name = azurerm_resource_group.example.name
  }
  assert {
    condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.avm_res_web_site.resource_private_endpoints["primary"].private_service_connection).private_ip_address
    error_message = "The private DNS A record for the private endpoint is not correct."
  }
}
*/

# VM to test private endpoint connectivity

# This allows us to randomize the region for the resource group.
# resource "random_integer" "region_index_vm" {
#   max = length(local.azure_regions) - 1
#   min = 0
# }

resource "random_integer" "zone_index" {
  max = 3
  min = 1
}

resource "azurerm_network_security_group" "example" {
  location            = azurerm_resource_group.example.location
  name                = local.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "example" {
  # checkov:skip=CKV_AZURE_9: Not in scope for this example - RDP access restriction not required for testing
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "AllowAllRDPInbound"
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.example.name
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_interface" "example" {
  location            = azurerm_resource_group.example.location
  name                = "example-nic"
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.example.id
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  # checkov:skip=CKV_AZURE_50: Not in scope for this example - VM extensions restriction not required for testing
  # checkov:skip=CKV_AZURE_151: Not in scope for this example - VM encryption not required for testing
  admin_password = "P@$$w0rd1234!"
  admin_username = "adminuser"
  location       = azurerm_resource_group.example.location
  name           = "example-machine"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_D2s_v5"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# Create the virtual machine
# module "avm_res_compute_virtualmachine" {
#   source  = "Azure/avm-res-compute-virtualmachine/azurerm"
#   version = "0.16.4"

#   enable_telemetry = var.enable_telemetry

#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   name                = "${local.naming.virtual_machine.name_unique}-tf"
#   sku_size            = module.avm_res_compute_virtualmachine_sku_selector.sku
#   os_type             = "Windows"

#   zone = random_integer.zone_index.result

#   generate_admin_password_or_ssh_key = false
#   admin_username                     = "TestAdmin"
#   admin_password                     = "P@ssw0rd1234!"

#   source_image_reference = {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }

#   network_interfaces = {
#     network_interface_1 = {
#       name = "nic-${local.naming.network_interface.name_unique}-tf"
#       ip_configurations = {
#         ip_configuration_1 = {
#           name                          = "${local.naming.network_interface.name_unique}-ipconfig1-public"
#           private_ip_subnet_resource_id = azurerm_subnet.example.id
#           create_public_ip_address      = true
#           public_ip_address_name        = "pip-${local.naming.virtual_machine.name_unique}-tf"
#           is_primary_ipconfiguration    = true
#         }
#       }
#     }
#   }

#   tags = {

#   }

# }

# module "avm_res_compute_virtualmachine_sku_selector" {
#   source  = "Azure/avm-res-compute-virtualmachine/azurerm//modules/sku_selector"
#   version = "0.16.4"

#   deployment_region = azurerm_resource_group.example.location
# }
