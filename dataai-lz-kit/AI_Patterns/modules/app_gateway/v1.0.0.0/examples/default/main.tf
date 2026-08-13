
#----------Testing Use Case  -------------
# Application Gateway routing traffic from your application.
# Assume that your Application runing the scale set contains two virtual machine instances.
# The scale set is added to the default backend pool need to updated with IP or FQDN of the application gateway.
# The example input from https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-manage-web-traffic-cli

#----------All Required Provider Section-----------
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate deterministic short suffix for example resource names
resource "random_string" "name_suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  name_prefix = "agw-${random_string.name_suffix.result}"
}


module "application_gateway" {
  # checkov:skip=CKV_AZURE_218: Not in scope for this example - secure protocol enforcement is handled by example listener and backend settings
  source = "../../"

  env                = "tst"
  au                 = "00121"
  owner              = "ceat"
  app_code           = "appgwy"
  resource_type_code = "agw"
  bu                 = "it"
  business_owner     = "Platform Owner"
  budget_id          = "83254"
  app_name           = "mbb-app-gateway"
  service            = "ApplicationGateway"

  # Backend address pool configuration for the application gateway
  # Mandatory Input
  backend_address_pools = {
    appGatewayBackendPool = {
      name         = "appGatewayBackendPool"
      ip_addresses = ["100.64.2.6", "100.64.2.5"]
      #fqdns        = ["example1.com", "example2.com"]
    }
  }
  # Backend http settings configuration for the application gateway
  # Mandatory Input
  backend_http_settings = {
    appGatewayBackendHttpSettings = {
      name = "appGatewayBackendHttpSettings"
      #Github issue #55 allow custom port for the backend
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      request_timeout       = 30


      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300

      }
    }
    # Add more http settings as needed
  }
  # frontend port configuration block for the application gateway
  # WAF : This example NO HTTPS, We recommend to  Secure all incoming connections using HTTPS for production services with end-to-end SSL/TLS or SSL/TLS termination at the Application Gateway to protect against attacks and ensure data remains private and encrypted between the web server and browsers.
  # WAF : Please refer kv_selfssl_waf_https_app_gateway example for HTTPS configuration
  frontend_ports = {
    frontend-port-80 = {
      name = "frontend-port-80"
      port = 8080
    }
  }
  gateway_ip_configuration = {
    subnet_id = azurerm_subnet.backend.id
  }
  # Http Listerners configuration for the application gateway
  # Mandatory Input
  http_listeners = {
    appGatewayHttpListener = {
      name               = "appGatewayHttpListener"
      host_name          = null
      frontend_port_name = "frontend-port-80"
    }
    # # Add more http listeners as needed
  }
  # Routing rules configuration for the backend pool
  # Mandatory Input
  request_routing_rules = {
    routing-rule-1 = {
      name                       = "rule-1"
      rule_type                  = "Basic"
      http_listener_name         = "appGatewayHttpListener"
      backend_address_pool_name  = "appGatewayBackendPool"
      backend_http_settings_name = "appGatewayBackendHttpSettings"
      priority                   = 100
    }
    # Add more rules as needed
  }
  resource_group_name = azurerm_resource_group.rg_group.name
  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 3
  }
  # pre-requisites resources input required for the module
  public_ip_name = "pip-${local.name_prefix}"
  tags = {
    environment = "dev"
    owner       = "application_gateway"
    project     = "AVM"
  }
  # Zone redundancy for the application gateway
  zones = ["1", "2", "3"]
}
