[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span> |
| --- | --- |
| Version | 1 |
| Created By | Pooja Pradhan |
| Reviewed By | Amit Kumar |

# About this product version

## Product State: Released

## Product Category

- API Platform

## Notable changes in this version

### v1

- Initial version to deploy Internal Azure API Management with enterprise naming/tagging integration.
- Introduces global mandatory policy variable block for standardized policy enforcement.
- Keeps core APIM resource model and outputs consistent with previous version.

## Upgrade Path

- Upgrade supported from `v1.0.0.0` to `v1.0.0.1`.
- Update module source from `modules/internal_apim/v1.0.0.0` to `modules/internal_apim/v1.0.0.1`.
- Update input contracts before running plan:
  - New required input: `global_policy_vars`.
  - Removed input: `protocols` (if previously passed at module level).
- If your existing pipeline passes `protocols` at module root, remove it and keep protocol settings inside per-API configuration blocks where applicable.
- Run `terraform plan` and verify APIM policies, APIs, products, subscriptions, and private endpoint related changes.

# Product Description

## Overview

- This module deploys Internal Azure API Management (`azurerm_api_management`) with optional API entities and policy components.
- It supports API version sets, APIs, operations, named values, products, subscriptions, diagnostics, role assignments, and private endpoint integration.
- It applies standardized naming and enterprise tags through `naming_module` v1.0.0.1.

## Note

- Internal APIM deployment requires subnet and network prerequisites compatible with APIM internal mode.
- Validate DNS resolution and private connectivity dependencies before deployment.

## Network Topology (wherever applicable)

- Internal APIM with private network integration and optional private endpoint connectivity.

## Azure Service(s) in Scope

- Azure API Management
- Azure Private Endpoint
- Azure Monitor Diagnostic Settings
- Azure RBAC Role Assignments

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Virtual Network and APIM subnet
- DNS strategy for internal endpoint resolution
- Optional Log Analytics Workspace for diagnostics

## Optional Azure services Used (Customer Choice)

- Key Vault for certificate retrieval
- Application Insights / Log Analytics for observability
- Private DNS Zones

## Limitations

- Provider constraints require Terraform and provider versions defined in `terraform.tf`.
- Invalid policy XML, API schema imports, or product/API mappings will fail at plan/apply.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one internal APIM service and optional child resources (APIs, products, subscriptions, policies, private endpoints).

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 4.0, < 5.0 |
| azapi | ~> 2.4 |
| modtm | >= 0.3, < 1.0 |
| random | >= 3.5, < 4.0 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| internal_apim | [IAC link](https://github.com/your-org/iac-modules/tree/main/modules/internal_apim) | v1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "internal_apim" {
  source = "../../modules/internal_apim/v1.0.0.1"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = "Premium_1"

  global_policy_vars = {
    jwt_header_name        = "Authorization"
    jwt_failed_status_code = 401
    jwt_failed_message     = "Unauthorized"
    jwt_require_expiry     = true
    jwt_scheme             = "Bearer"
    openid_config_url      = var.openid_config_url
    jwt_audience           = var.jwt_audience
    jwt_issuer             = var.jwt_issuer
    rate_limit_calls       = 100
    rate_limit_period      = 60
    rate_limit_counter_key = "@(context.Subscription?.Key)"
    quota_calls            = 10000
    quota_period           = 86400
    quota_counter_key      = "@(context.Subscription?.Key)"
  }

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "apim"

  business_owner      = var.business_owner
  business_unit       = var.business_unit
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  criticality         = var.criticality
  environment         = var.environment
  service             = var.service
}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | APIM instance name | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group for APIM deployment | `string` | n/a | yes |
| publisher_email | APIM publisher email | `string` | n/a | yes |
| publisher_name | APIM publisher name | `string` | `""` | no |
| sku_name | APIM SKU name | `string` | `"Developer_1"` | no |
| global_policy_vars | Global policy parameter object for JWT/rate-limit/quota controls | `object` | n/a | yes |
| api_version_sets | API version set definitions | `map(object)` | `{}` | no |
| apis | API definitions with operations and policy options | `map(object)` | `{}` | no |
| products | Product definitions and API links | `map(object)` | `{}` | no |
| subscriptions | Subscription definitions | `map(object)` | `{}` | no |
| private_endpoints | Private endpoint definitions | `map(object)` | `{}` | no |
| diagnostic_settings | Diagnostic settings map | `map(object)` | `{}` | no |
| role_assignments | Role assignments map | `map(object)` | `{}` | no |
| env | Naming module environment code | `string` | n/a | yes |
| au | Accounting unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner | `string` | n/a | yes |
| business_owner | Mandatory business owner tag | `string` | n/a | yes |
| business_unit | Mandatory business unit tag | `string` | n/a | yes |
| cost_center | Mandatory cost center tag | `string` | n/a | yes |
| data_classification | Mandatory data classification tag | `string` | n/a | yes |
| compliance | Mandatory compliance tag | `string` | n/a | yes |
| criticality | Mandatory criticality tag | `string` | n/a | yes |
| environment | Mandatory environment tag | `string` | n/a | yes |
| service | Required service tag | `string` | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azurerm_api_management.this | resource |
| azurerm_api_management_api_version_set.this | resource |
| azurerm_api_management_api.this | resource |
| azurerm_api_management_api_operation.this | resource |
| azurerm_api_management_api_policy.this | resource |
| azurerm_api_management_api_operation_policy.this | resource |
| azurerm_api_management_policy.this | resource |
| azurerm_api_management_product.this | resource |
| azurerm_api_management_product_api.this | resource |
| azurerm_api_management_product_group.this | resource |
| azurerm_api_management_named_value.this | resource |
| azurerm_api_management_subscription.this | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_management_lock.this | resource |

### Outputs

| Name | Description |
|------|-------------|
| resource | APIM resource object |
| resource_id | APIM resource ID |
| apim_gateway_url | APIM gateway URL |
| apim_management_url | APIM management endpoint URL |
| api_ids | Map of API resource IDs |
| product_ids | Map of product resource IDs |
| subscription_ids | Map of subscription resource IDs |
| private_endpoints | Private endpoint output details |



## Security Policies (Hardcoded & Non-Negotiable)

All security settings are intentionally hardcoded to ensure compliance with security baseline. Users **cannot override** these settings.

| Policy | Description |
|--------|-------------|
| **Enforce HTTPS-only** | policy -Enforces HTTPS-only communication for all APIs to ensure encrypted data transmission and prevent insecure HTTP access.  |
| **TLS 1.2+**** | policy – All gateway, management, and portal endpoints enforce encrypted communication. No plaintext or legacy TLS protocols accepted. |

---------------
# Internal APIM v1.0.0.1 — Pre-Deployment, Configuration, and Post-Deployment Guide

---

## Table of Contents

1. [Pre-Deployment Requirements](#1-pre-deployment-requirements-mandatory)
2. [Module Configuration Examples](#2-module-configuration-examples)
3. [NSG Rules (Complete Reference)](#3-nsg-rules-complete-reference)

---

## 1. Pre-Deployment Requirements (Mandatory)

Before deploying the Internal APIM module, ensure these prerequisites are in place.

### 1.1 Subscription and Access

**Required:**
- Azure subscription active and quota available
- Resource Group created
- Deployment identity (Service Principal or Managed Identity) with permissions:
  - `Microsoft.ApiManagement/*` (APIM operations)
  - `Microsoft.Network/*` (VNet, NSG, Subnet operations)
  - `Microsoft.KeyVault/*` (Certificate retrieval)
  - `Microsoft.Insights/*` (Monitoring/Diagnostics)
  - `Microsoft.Authorization/*` (RBAC assignments)

### 1.2 Virtual Network and Subnet

**Mandatory:**
- Virtual Network exists in target region
- **Dedicated subnet for APIM** (no other workloads can share)
- Subnet size:
  - **Minimum:** `/27` (32 IPs)
  - **Production Recommended:** `/26` (64 IPs)
  - **Maximum:** `/24` or larger

**Example values:**

```hcl
vnet_name            = "vnet-apim-prod-sea-01"
vnet_address_space   = ["10.10.0.0/16"]
vnet_location        = "Southeast Asia"

apim_subnet_name     = "subnet-apim-int-prod-sea"
apim_subnet_cidr     = ["10.10.1.0/26"]

# Service endpoints that must be enabled on APIM subnet
apim_service_endpoints = [
  "Microsoft.Storage",         # For diagnostic logs
  "Microsoft.KeyVault",        # For certificate retrieval
  "Microsoft.Sql",             # For backend SQL connections
  "Microsoft.EventHub",        # For event streaming
  "Microsoft.AzureCosmosDB"    # For CosmosDB backends
]

# Delegation (allows APIM service to manage subnet)
apim_delegation_service = "Microsoft.ApiManagement/service"
apim_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
```

### 1.3 Network Security Group (NSG)

**Mandatory:**
- NSG must be created and attached to APIM subnet
- Default posture: **DENY ALL** (explicit allow rules only)
- All required rules pre-configured (see [Section 3](#3-nsg-rules-complete-reference))

**Minimum inbound rules:**

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 443 | TCP | Internal VNets (10.0.0.0/8, 172.16.0.0/12) | API Gateway |
| 3443 | TCP | Internal VNets + AzureCloud | Management Plane |
| 6390 | TCP | AzureLoadBalancer | Health Probes |

**Minimum outbound rules:**

| Port | Protocol | Destination | Purpose |
|------|----------|-------------|---------|
| 443 | TCP | Storage, Sql, AzureMonitor, AzureActiveDirectory, KeyVault | Azure Dependencies |
| 53 | UDP | 0.0.0.0/0 | DNS Resolution |
| 80 | TCP | Internal networks (if legacy HTTP backends) | Backend APIs (optional) |

### 1.4 DNS Strategy (Mandatory)



**Azure Private DNS Zones**

dns_option = "Azure Private DNS Zones"

**Zones to create** :

primary_dns_zone     = "privatelink.azure-api.net" \
custom_dns_zone      = "internal.example.local" \
custom_dns_zone_linked_to_vnet = true


NOTE : This is the resource id for Malaysia private dns zone - /subscriptions/66f0d854-131d-4a6d-8ba0-6e289d4b540d/resourceGroups/{org}-rg-private-network-pd-myw-01/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net
 
 - This is hosted in the subscription {org}-plt-sub-network-prd-myw-01
 - This is in the resourcegroup : {org}-rg-private-network-pd-myw-01

  This is not for every entity. The respective dns zone details for the entity can be taken from the respective entitie's management group


**Critical:** Internal APIM **cannot work** without DNS resolution.


### 1.5 Key Vault and Certificates (Optional but Recommended for Custom Domains)

If using custom hostnames (e.g., `api.internal.company.local`):

**Required:**
- Azure Key Vault exists (Premium tier recommended for production)
- TLS certificates imported:
  - `gateway-cert` (for API Gateway)
  - `mgmt-cert` (for Management endpoint)
  - `portal-cert` (for Developer Portal)
- APIM managed identity has permissions:
  - `Key Vault Secrets User`
  - `Key Vault Certificate User`

**Certificate requirements:**
```hcl
certificate_properties = {
  format              = "PFX/PKCS12"
  key_algorithm       = "RSA 2048-bit (minimum)"
  validity_period     = "365 days"
  subject_cn          = "*.internal.example.local"
  subject_alt_names   = ["api.internal.example.local", "mgmt.internal.example.local", "portal.internal.example.local"]
  tls_version_minimum = "1.2"
  expiration_check    = "At least 90 days validity"
}
```

### 1.6 Logging and Monitoring Baseline

**Recommended:**
- Log Analytics Workspace exists
- Action Group created (for alerts)
- Diagnostic settings plan ready


Diagnostic setting is applied through policy \
Logger needs to be created and linked with app insights


## 2. Module Configuration Examples

Use these examples to pass configuration values to the `internal_apim` module (v1.0.0.1).

### 2.1 Minimal Configuration (Production-Ready Internal APIM)

```hcl
module "internal_apim" {
  source = "./modules/internal_apim/v1.0.0.1"

  # Identity and Location
  name                = "apim-internal-prod-sea-01"
  location            = "Southeast Asia"
  resource_group_name = azurerm_resource_group.apim_rg.name

  # Publisher Details
  publisher_name  = "Platform Engineering"
  publisher_email = "platform-eng@example.com"

  # APIM SKU and VNet Mode (ALL REQUIRED FOR INTERNAL)
  sku_name              = "Premium_1"
  virtual_network_type  = "Internal"
  virtual_network_subnet_id = azurerm_subnet.apim_internal.id

  # Security: Disable external internet access
  public_network_access_enabled = false

  # Identity for Key Vault access
  identity {
    type = "SystemAssigned"
  }

  # Tags
  tags = {
    environment  = "production"
    cost_center  = "CC-001"
    owner        = "platform-team"
    criticality  = "Critical"
  }
}
```

**Terraform input variables file (`terraform.tfvars`):**

```hcl
name                = "apim-internal-prod-sea-01"
location            = "Southeast Asia"
resource_group_name = "rg-apim-internal-prod-sea-01"

publisher_name  = "Platform Engineering"
publisher_email = "platform-eng@example.com"

sku_name                      = "Premium_1"
virtual_network_type          = "Internal"
virtual_network_subnet_id     = "/subscriptions/{subId}/resourceGroups/rg-apim.../providers/Microsoft.Network/virtualNetworks/vnet-apim-prod-sea-01/subnets/subnet-apim-int-prod-sea"
public_network_access_enabled = false

tags = {
  environment = "production"
}
```

### 2.2 Full Configuration with Custom Domains and Diagnostics

```hcl
module "internal_apim" {
  source = "./modules/internal_apim/v1.0.0.1"

  # Core Configuration
  name                = "apim-internal-prod-sea-01"
  location            = "Southeast Asia"
  resource_group_name = azurerm_resource_group.apim_rg.name

  publisher_name  = "Platform Engineering"
  publisher_email = "platform-eng@example.com"

  # APIM Mode and SKU
  sku_name                      = "Premium_1"  # Premium supports VNet injection
  virtual_network_type          = "Internal"
  virtual_network_subnet_id     = azurerm_subnet.apim_internal.id
  public_network_access_enabled = false

  # Identity for Key Vault / Managed Resources
  identity {
    type = "SystemAssigned"
  }

  # Security Policies (TLS hardening)
  security_settings = {
    enable_backend_ssl30         = false
    enable_backend_tls10         = false
    enable_backend_tls11         = false
    enable_frontend_ssl30        = false
    enable_frontend_tls10        = false
    enable_frontend_tls11        = false
    triple_des_ciphers_enabled   = false
    min_tls_version              = "1.2"
  }

  # Custom Domain Configuration (if using custom hostnames)
  hostname_configuration = {
    proxy = [
      {
        host_name            = "api.internal.example.local"
        key_vault_id         = azurerm_key_vault.apim_kv.id
        certificate_name     = "gateway-cert"
        default_ssl_binding  = true
        negotiate_client_certificate = false
      }
    ]
    
    management = [
      {
        host_name        = "mgmt.internal.example.local"
        key_vault_id     = azurerm_key_vault.apim_kv.id
        certificate_name = "mgmt-cert"
        negotiate_client_certificate = false
      }
    ]
    
    portal = [
      {
        host_name        = "portal.internal.example.local"
        key_vault_id     = azurerm_key_vault.apim_kv.id
        certificate_name = "portal-cert"
        negotiate_client_certificate = false
      }
    ]

    scm = [
      {
        host_name        = "api.internal.example.local"
        key_vault_id     = azurerm_key_vault.apim_kv.id
        certificate_name = "gateway-cert"
        negotiate_client_certificate = false
      }
    ]
  }

  # Diagnostics: Send logs to Log Analytics
  diagnostic_settings = {
    name                       = "apim-diagnostics"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.apim_law.id
    
    log_categories = [
      "GatewayLogs",         # API traffic
      "TenantAuditLogs",     # Admin actions
      "HttpRequestLogs"      # Detailed request logs
    ]
    
    metric_categories = [
      "AllMetrics"
    ]
    
    retention_days = 90
  }

  # Tags
  tags = {
    environment          = "production"
    cost_center          = "CC-001"
    owner                = "platform-team"
    criticality          = "Critical"
    data_classification = "Confidential"
    compliance           = "SOX,GDPR"
    backup_required      = "true"
  }
}

# Output private IP for DNS record creation
output "apim_private_ip" {
  value       = module.internal_apim.private_ip_addresses[0]
  description = "APIM Private IP for DNS A record configuration"
}

# Depends on networking and Key Vault
depends_on = [
  azurerm_subnet.apim_internal,
  azurerm_network_security_group.apim_nsg,
  azurerm_key_vault.apim_kv
]
```

### 2.3 APIM with API Configuration (Example)

```hcl
# Deploy APIM first, then add APIs

resource "azurerm_api_management_api" "orders_api" {
  name                = "orders-api"
  resource_group_name = azurerm_resource_group.apim_rg.name
  api_management_name = module.internal_apim.apim_name
  
  revision       = "1"
  display_name   = "Orders API"
  path           = "orders"
  protocols      = ["https"]
  service_url    = "https://backend-orders.internal.example.local"  # Internal backend
  
  subscription_required = true
  
  api_type = "http"
  
  depends_on = [module.internal_apim]
}

# API-level policy
resource "azurerm_api_management_api_policy" "orders_api_policy" {
  api_name            = azurerm_api_management_api.orders_api.name
  api_management_name = module.internal_apim.apim_name
  resource_group_name = azurerm_resource_group.apim_rg.name

  xml_content = file("${path.module}/policies/01-correlation.xml")
}

# API Operation: Get Orders
resource "azurerm_api_management_api_operation" "get_orders" {
  operation_id        = "get-orders"
  api_name            = azurerm_api_management_api.orders_api.name
  api_management_name = module.internal_apim.apim_name
  resource_group_name = azurerm_resource_group.apim_rg.name

  display_name = "Get Orders"
  method       = "GET"
  url_template = "/"
  
  depends_on = [azurerm_api_management_api.orders_api]
}

# API Operation: Create Order
resource "azurerm_api_management_api_operation" "create_order" {
  operation_id        = "create-order"
  api_name            = azurerm_api_management_api.orders_api.name
  api_management_name = module.internal_apim.apim_name
  resource_group_name = azurerm_resource_group.apim_rg.name

  display_name = "Create Order"
  method       = "POST"
  url_template = "/"
  
  depends_on = [azurerm_api_management_api.orders_api]
}

# API Operation: Get Order by ID
resource "azurerm_api_management_api_operation" "get_order_by_id" {
  operation_id        = "get-order-by-id"
  api_name            = azurerm_api_management_api.orders_api.name
  api_management_name = module.internal_apim.apim_name
  resource_group_name = azurerm_resource_group.apim_rg.name

  display_name = "Get Order By ID"
  method       = "GET"
  url_template = "/{id}"
  
  template_parameter {
    name        = "id"
    required    = true
    type        = "string"
    description = "Order ID"
  }
  
  depends_on = [azurerm_api_management_api.orders_api]
}

# Subscription Key (Products)
resource "azurerm_api_management_product" "orders_product" {
  product_id              = "orders-product"
  api_management_name     = module.internal_apim.apim_name
  resource_group_name     = azurerm_resource_group.apim_rg.name
  display_name            = "Orders API Product"
  subscription_required   = true
  approval_required       = false
  published               = true
  
  depends_on = [module.internal_apim]
}

# Link API to Product
resource "azurerm_api_management_product_api" "orders_product_api" {
  product_id          = azurerm_api_management_product.orders_product.product_id
  api_name            = azurerm_api_management_api.orders_api.name
  api_management_name = module.internal_apim.apim_name
  resource_group_name = azurerm_resource_group.apim_rg.name
  
  depends_on = [azurerm_api_management_product.orders_product, azurerm_api_management_api.orders_api]
}
```

---

## 3. NSG Rules (Complete Reference)

Complete NSG configuration block with all required rules.

```hcl
resource "azurerm_network_security_group" "apim_nsg" {
  name                = "nsg-apim-internal-prod-sea"
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name = azurerm_resource_group.apim_rg.name

  # ══════════════════════════════════════════════════════════════════════
  # INBOUND RULES
  # ══════════════════════════════════════════════════════════════════════

  # Rule 1: Gateway HTTPS (443) — API consumer traffic
  security_rule {
    name                       = "Allow-Inbound-Gateway-443"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = ["10.0.0.0/8", "172.16.0.0/12"]  # Internal VNets
    destination_address_prefix = "*"
    description                = "Allow HTTPS traffic from internal consumers"
  }

  # Rule 2: Management Plane (3443) — Admin/DevOps access
  security_rule {
    name                       = "Allow-Inbound-Management-3443"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefixes    = ["10.0.0.0/8", "172.16.0.0/12", "AzureCloud"]
    destination_address_prefix = "*"
    description                = "Allow management plane access for policy/config deployment"
  }

  # Rule 3: Azure Load Balancer Health Probe (6390)
  security_rule {
    name                       = "Allow-Inbound-LB-HealthProbe-6390"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    description                = "Allow Azure Load Balancer health checks"
  }

  # Rule 4: Optional HTTP (80) — Only for legacy/non-prod backends
  security_rule {
    name                       = "Allow-Inbound-HTTP-80-Legacy"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = ["10.10.0.0/16"]  # Only from APIM VNet (restrict scope)
    destination_address_prefix = "*"
    description                = "Allow HTTP from internal (legacy backends only — not recommended for prod)"
  }

  # Rule 5: Deny All Other Inbound (implicit default, but explicit recommended)
  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Deny all other inbound traffic"
  }

  # ══════════════════════════════════════════════════════════════════════
  # OUTBOUND RULES
  # ══════════════════════════════════════════════════════════════════════

  # Rule 1: Azure Storage HTTPS (443)
  security_rule {
    name                       = "Allow-Outbound-Storage-443"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Storage"  # Azure service tag
    description                = "Allow HTTPS to Storage (diagnostic logs, blob access)"
  }

  # Rule 2: Azure SQL HTTPS (443)
  security_rule {
    name                       = "Allow-Outbound-SQL-443"
    priority                   = 210
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Sql"  # Azure service tag
    description                = "Allow HTTPS to Azure SQL (backend APIs)"
  }

  # Rule 3: Azure Monitor HTTPS (443)
  security_rule {
    name                       = "Allow-Outbound-AzureMonitor-443"
    priority                   = 220
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureMonitor"  # Azure service tag
    description                = "Allow HTTPS to Azure Monitor (health checks, metrics)"
  }

  # Rule 4: Azure Active Directory HTTPS (443)
  security_rule {
    name                       = "Allow-Outbound-AAD-443"
    priority                   = 230
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureActiveDirectory"  # Azure service tag
    description                = "Allow HTTPS to Azure AD (authentication)"
  }

  # Rule 5: Key Vault HTTPS (443) — Certificate retrieval
  security_rule {
    name                       = "Allow-Outbound-KeyVault-443"
    priority                   = 240
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureKeyVault"  # Azure service tag
    description                = "Allow HTTPS to Key Vault (certificate/secret access)"
  }

  # Rule 6: Event Hub HTTPS (443) — Event streaming
  security_rule {
    name                       = "Allow-Outbound-EventHub-443"
    priority                   = 250
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "EventHub"  # Azure service tag
    description                = "Allow HTTPS to Event Hub (streaming)"
  }

  # Rule 7: DNS (UDP 53)
  security_rule {
    name                       = "Allow-Outbound-DNS-53"
    priority                   = 260
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow DNS queries (name resolution)"
  }

  # Rule 8: NTP (UDP 123) — Time synchronization
  security_rule {
    name                       = "Allow-Outbound-NTP-123"
    priority                   = 270
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "123"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow NTP (time synchronization)"
  }

  # Rule 9: Internal Backends HTTPS (443) — Custom backend APIs
  security_rule {
    name                       = "Allow-Outbound-Internal-HTTPS-443"
    priority                   = 280
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefixes = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    description                = "Allow HTTPS to internal backend APIs"
  }

  # Rule 10: Internal Backends HTTP (80) — Legacy backend APIs only
  security_rule {
    name                       = "Allow-Outbound-Internal-HTTP-80-Legacy"
    priority                   = 290
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefixes = ["10.0.0.0/8", "172.16.0.0/12"]
    description                = "Allow HTTP to internal backends (legacy only — not recommended)"
  }

  # Rule 11: Deny All Other Outbound
  security_rule {
    name                       = "Deny-All-Outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Deny all other outbound traffic"
  }
}

# Associate NSG to APIM subnet
resource "azurerm_subnet_network_security_group_association" "apim_nsg_assoc" {
  subnet_id                 = azurerm_subnet.apim_internal.id
  network_security_group_id = azurerm_network_security_group.apim_nsg.id
}
```

---


<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.4)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 4.0, < 5.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (>= 0.3, < 1.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5, < 4.0)

## Resources

The following resources are used by this module:

- [azurerm_api_management.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management) (resource)
- [azurerm_api_management_api.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api) (resource)
- [azurerm_api_management_api_operation.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_operation) (resource)
- [azurerm_api_management_api_operation_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_operation_policy) (resource)
- [azurerm_api_management_api_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_policy) (resource)
- [azurerm_api_management_api_version_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_api_version_set) (resource)
- [azurerm_api_management_named_value.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_named_value) (resource)
- [azurerm_api_management_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_policy) (resource)
- [azurerm_api_management_product.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_product) (resource)
- [azurerm_api_management_product_api.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_product_api) (resource)
- [azurerm_api_management_product_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_product_group) (resource)
- [azurerm_api_management_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_subscription) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_client_config.telemetry](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_publisher_email"></a> [publisher\_email](#input\_publisher\_email)

Description: The email of the API Management service publisher.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_additional_location"></a> [additional\_location](#input\_additional\_location)

Description: Additional datacenter locations where the API Management service should be provisioned.

Type:

```hcl
list(object({
    location             = string
    capacity             = optional(number, null)
    zones                = optional(list(string), null)
    public_ip_address_id = optional(string, null)
    gateway_disabled     = optional(bool, null)
    virtual_network_configuration = optional(object({
      subnet_id = string
    }), null)
  }))
```

Default: `[]`

### <a name="input_api_version_sets"></a> [api\_version\_sets](#input\_api\_version\_sets)

Description: API Version Sets for the API Management service. Version sets enable API versioning using Header, Query, or Segment-based schemes.

- `display_name` - (Required) The display name of the API version set.
- `versioning_scheme` - (Required) The versioning scheme. Valid values: `Header`, `Query`, `Segment`.
- `description` - (Optional) Description of the API version set.
- `version_header_name` - (Optional) Name of the HTTP header parameter for the `Header` versioning scheme. Required when `versioning_scheme` is `Header`.
- `version_query_name` - (Optional) Name of the query string parameter for the `Query` versioning scheme. Required when `versioning_scheme` is `Query`.

Example:
```terraform
api_version_sets = {
  "my-api-versions" = {
    display_name        = "My API Versions"
    versioning_scheme   = "Header"
    version_header_name = "api-version"
    description         = "Version set for My API"
  }
}
```

Type:

```hcl
map(object({
    display_name        = string
    versioning_scheme   = string
    description         = optional(string)
    version_header_name = optional(string)
    version_query_name  = optional(string)
  }))
```

Default: `{}`

### <a name="input_apis"></a> [apis](#input\_apis)

Description: APIs for the API Management service. APIs define the operations available to API consumers.

- `display_name` - (Required) The display name of the API.
- `path` - (Required) The relative path for the API. Must be unique within the API Management service.
- `protocols` - (Optional) A list of protocols the API supports. Valid values: `http`, `https`, `ws`, `wss`. Defaults to `["https"]`.
- `revision` - (Optional) The revision number of the API. Defaults to `"1"`.
- `service_url` - (Optional) The backend service URL for the API.
- `description` - (Optional) Description of the API.
- `subscription_required` - (Optional) Whether a subscription key is required to access the API. Defaults to `true`.

Versioning:
- `api_version` - (Optional) The version identifier for the API.
- `api_version_set_name` - (Optional) The name of the API version set to associate with this API.
- `revision_description` - (Optional) Description of the API revision.

Import:
- `import` - (Optional) Import configuration for OpenAPI, WSDL, WADL specifications.
  - `content_format` - (Required) Format of the content. Valid values: `openapi`, `openapi+json`, `openapi+json-link`, `openapi-link`, `swagger-json`, `swagger-link-json`, `wadl-link-json`, `wadl-xml`, `wsdl`, `wsdl-link`.
  - `content_value` - (Required) The API definition content or URL.
  - `wsdl_selector` - (Optional) WSDL selector for SOAP APIs.

Operations:
- `operations` - (Optional) Map of API operations. Each operation defines an HTTP method and URL template.

Policies:
- `policy` - (Optional) API-level policy configuration.
  - `xml_content` - (Optional) XML policy content.
  - `xml_link` - (Optional) URL to XML policy content.

Example:
```terraform
apis = {
  "petstore-api" = {
    display_name = "Petstore API"
    path         = "petstore"
    protocols    = ["https"]
    service_url  = "https://petstore.swagger.io/v2"

    operations = {
      "get-pets" = {
        display_name = "Get all pets"
        method       = "GET"
        url_template = "/pets"
      }
    }
  }
}
```

Type:

```hcl
map(object({
    # Basic API properties
    display_name          = string
    path                  = string
    protocols             = optional(list(string), ["https"])
    revision              = optional(string, "1")
    service_url           = optional(string)
    description           = optional(string)
    subscription_required = optional(bool, true)

    # API versioning
    api_version          = optional(string)
    api_version_set_name = optional(string)
    revision_description = optional(string)

    # Import configuration (OpenAPI, WSDL, WADL, etc.)
    import = optional(object({
      content_format = string
      content_value  = string
      wsdl_selector = optional(object({
        service_name  = string
        endpoint_name = string
      }))
    }))

    # Source API for cloning
    source_api_id = optional(string)

    # OAuth2 Authorization
    oauth2_authorization = optional(object({
      authorization_server_name = string
      scope                     = optional(string)
    }))

    # OpenID Connect Authentication
    openid_authentication = optional(object({
      openid_provider_name         = string
      bearer_token_sending_methods = optional(list(string))
    }))

    # Subscription key parameter names
    subscription_key_parameter_names = optional(object({
      header = string
      query  = string
    }))

    # Contact information
    contact = optional(object({
      email = optional(string)
      name  = optional(string)
      url   = optional(string)
    }))

    # License information
    license = optional(object({
      name = optional(string)
      url  = optional(string)
    }))

    terms_of_service_url = optional(string)

    # API-level policy
    policy = optional(object({
      xml_content = optional(string)
      xml_link    = optional(string)
    }))

    # API operations
    operations = optional(map(object({
      display_name = string
      method       = string
      url_template = string
      description  = optional(string)

      # Template parameters (URL path parameters)
      template_parameters = optional(list(object({
        name          = string
        required      = bool
        type          = string
        description   = optional(string)
        default_value = optional(string)
        values        = optional(list(string))
      })))

      # Request configuration
      request = optional(object({
        description = optional(string)

        query_parameters = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        headers = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        representations = optional(list(object({
          content_type = string
          schema_id    = optional(string)
          type_name    = optional(string)

          form_parameters = optional(list(object({
            name          = string
            required      = bool
            type          = string
            description   = optional(string)
            default_value = optional(string)
            values        = optional(list(string))
          })))
        })))
      }))

      # Response configuration
      responses = optional(list(object({
        status_code = number
        description = optional(string)

        headers = optional(list(object({
          name          = string
          required      = bool
          type          = string
          description   = optional(string)
          default_value = optional(string)
          values        = optional(list(string))
        })))

        representations = optional(list(object({
          content_type = string
          schema_id    = optional(string)
          type_name    = optional(string)

          form_parameters = optional(list(object({
            name          = string
            required      = bool
            type          = string
            description   = optional(string)
            default_value = optional(string)
            values        = optional(list(string))
          })))
        })))
      })))

      # Operation-level policy
      policy = optional(object({
        xml_content = optional(string)
        xml_link    = optional(string)
      }))
    })), {})
  }))
```

Default: `{}`

### <a name="input_certificate"></a> [certificate](#input\_certificate)

Description: Certificate configurations for the API Management service.

Type:

```hcl
list(object({
    encoded_certificate  = string
    store_name           = string
    certificate_password = optional(string, null)
  }))
```

Default: `[]`

### <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled)

Description: Enforce a client certificate to be presented on each request to the gateway. This is only supported when SKU type is Consumption.

Type: `bool`

Default: `false`

### <a name="input_delegation"></a> [delegation](#input\_delegation)

Description: Delegation settings for the API Management service.

Type:

```hcl
object({
    subscriptions_enabled     = optional(bool, false)
    user_registration_enabled = optional(bool, false)
    url                       = optional(string, null)
    validation_key            = optional(string, null)
  })
```

Default: `null`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_gateway_disabled"></a> [gateway\_disabled](#input\_gateway\_disabled)

Description: Disable the gateway in the main region? This is only supported when additional\_location is set.

Type: `bool`

Default: `false`

### <a name="input_hostname_configuration"></a> [hostname\_configuration](#input\_hostname\_configuration)

Description: Hostname configuration for the API Management service.

Type:

```hcl
object({
    management = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    developer_portal = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    proxy = optional(list(object({
      host_name                       = string
      default_ssl_binding             = optional(bool, false)
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
    scm = optional(list(object({
      host_name                       = string
      key_vault_id                    = optional(string, null)
      certificate                     = optional(string, null)
      certificate_password            = optional(string, null)
      negotiate_client_certificate    = optional(bool, false)
      ssl_keyvault_identity_client_id = optional(string, null)
    })), [])
  })
```

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_min_api_version"></a> [min\_api\_version](#input\_min\_api\_version)

Description: The version which the control plane API calls to API Management service are limited with version equal to or newer than.

Type: `string`

Default: `null`

### <a name="input_named_values"></a> [named\_values](#input\_named\_values)

Description: Named values for the API Management service. Named values are a collection of key/value pairs that can be referenced in policies and API configurations.

- `display_name` - (Required) The display name of the named value. Must be unique within the API Management service.
- `value` - (Optional) The value of the named value. Conflicts with `value_from_key_vault`. If neither is specified, the named value must be set through other means.
- `secret` - (Optional) Whether the value is a secret and should be encrypted. Defaults to `false`.
- `tags` - (Optional) A list of tags that can be used to filter the named values list.
- `value_from_key_vault` - (Optional) A Key Vault configuration for secret values. Conflicts with `value`.
  - `secret_id` - (Required) The versioned secret ID from Key Vault (e.g., `https://myvault.vault.azure.net/secrets/mysecret/version`).
  - `identity_client_id` - (Optional) The client ID of a user-assigned managed identity to use for Key Vault access. If not specified, the system-assigned identity will be used.

Example:
```terraform
named_values = {
  "api-key" = {
    display_name = "API Key"
    value        = "my-secret-key"
    secret       = true
    tags         = ["production", "api"]
  }
  "keyvault-secret" = {
    display_name = "Database Connection String"
    secret       = true
    value_from_key_vault = {
      secret_id = "https://myvault.vault.azure.net/secrets/db-conn/abc123"
    }
  }
}
```

Type:

```hcl
map(object({
    display_name = string
    value        = optional(string)
    secret       = optional(bool, false)
    tags         = optional(list(string), [])
    value_from_key_vault = optional(object({
      secret_id          = string
      identity_client_id = optional(string)
    }))
  }))
```

Default: `{}`

### <a name="input_notification_sender_email"></a> [notification\_sender\_email](#input\_notification\_sender\_email)

Description: Email address from which the notification will be sent.

Type: `string`

Default: `null`

### <a name="input_policy"></a> [policy](#input\_policy)

Description: Service-level (global) policy for the API Management service. This policy applies to all APIs.

- `xml_content` - (Required) The XML content of the policy.

Example:
```terraform
policy = {
  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <cors allow-credentials="true">
      <allowed-origins>
        <origin>https://example.com</origin>
      </allowed-origins>
      <allowed-methods>
        <method>GET</method>
        <method>POST</method>
      </allowed-methods>
    </cors>
    <rate-limit-by-key calls="100" renewal-period="60" counter-key="@(context.Subscription.Id)" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <set-header name="X-Powered-By" exists-action="delete" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}
```

Type:

```hcl
object({
    xml_content = string
  })
```

Default: `null`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group)

Description: Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.

Type: `bool`

Default: `true`

### <a name="input_products"></a> [products](#input\_products)

Description: Products for the API Management service. The map key is the product identifier.

- `display_name` - (Required) The display name of the product.
- `description` - (Optional) Description of the product.
- `terms` - (Optional) Terms of use for the product.
- `subscription_required` - (Optional) Whether a subscription is required to access APIs in this product. Default is `false`.
- `approval_required` - (Optional) Whether subscription approval is required. Default is `false`.
- `subscriptions_limit` - (Optional) Maximum number of subscriptions allowed for this product.
- `state` - (Optional) Publication state of the product. Valid values: `published`, `notPublished`. Default is `published`.
- `api_names` - (Optional) List of API names to associate with this product.
- `group_names` - (Optional) List of group names to associate with this product (e.g., "developers", "administrators", "guests").

Example:
```terraform
products = {
  "starter" = {
    display_name          = "Starter"
    description           = "Starter product for new developers"
    subscription_required = true
    approval_required     = false
    state                 = "published"
    api_names             = ["petstore-api", "weather-api"]
    group_names           = ["developers"]
  }
}
```

Type:

```hcl
map(object({
    display_name          = string
    description           = optional(string)
    terms                 = optional(string)
    subscription_required = optional(bool, false)
    approval_required     = optional(bool, false)
    subscriptions_limit   = optional(number)
    state                 = optional(string, "published") # published, notPublished

    # Associations
    api_names   = optional(list(string), [])
    group_names = optional(list(string), [])
  }))
```

Default: `{}`

### <a name="input_protocols"></a> [protocols](#input\_protocols)

Description: Protocol settings for the API Management service.

Type:

```hcl
object({
    enable_http2 = optional(bool, false)
  })
```

Default: `null`

### <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id)

Description: ID of a standard SKU IPv4 Public IP. Only supported on Premium and Developer tiers when deployed in a virtual network.

Type: `string`

Default: `null`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Is public access to the API Management service allowed? This only applies to the Management plane, not the API gateway or Developer portal.

Type: `bool`

Default: `true`

### <a name="input_publisher_name"></a> [publisher\_name](#input\_publisher\_name)

Description: The name of the API Management service publisher.

Type: `string`

Default: `"Apim Example Publisher"`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_security"></a> [security](#input\_security)

Description: Security settings for the API Management service.

Type:

```hcl
object({
    enable_backend_ssl30                                = optional(bool, false)
    enable_backend_tls10                                = optional(bool, false)
    enable_backend_tls11                                = optional(bool, false)
    enable_frontend_ssl30                               = optional(bool, false)
    enable_frontend_tls10                               = optional(bool, false)
    enable_frontend_tls11                               = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = optional(bool, false)
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = optional(bool, false)
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = optional(bool, false)
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = optional(bool, false)
    triple_des_ciphers_enabled                          = optional(bool, false)
  })
```

Default: `null`

### <a name="input_sign_in"></a> [sign\_in](#input\_sign\_in)

Description: Sign-in settings for the API Management service. When enabled, anonymous users will be redirected to the sign-in page.

Type:

```hcl
object({
    enabled = bool
  })
```

Default: `null`

### <a name="input_sign_up"></a> [sign\_up](#input\_sign\_up)

Description: Sign-up settings for the API Management service.

Type:

```hcl
object({
    enabled = bool
    terms_of_service = object({
      consent_required = bool
      enabled          = bool
      text             = optional(string, null)
    })
  })
```

Default: `null`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: The SKU name of the API Management service.

Type: `string`

Default: `"Developer_1"`

### <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions)

Description: Subscriptions for the API Management service. The map key is the subscription identifier.

- `display_name` - (Required) The display name of the subscription.
- `scope_type` - (Required) The scope type. Valid values: `product`, `api`, `all_apis`.
- `scope_identifier` - (Optional) The product ID or API name. Required for `product` and `api` scope types. Not needed for `all_apis`.
- `user_id` - (Optional) The user ID for this subscription (format: /users/{userId}).
- `primary_key` - (Optional) Custom primary subscription key.
- `secondary_key` - (Optional) Custom secondary subscription key.
- `state` - (Optional) The state of the subscription. Valid values: `active`, `suspended`, `submitted`, `rejected`, `cancelled`. Default is `active`.
- `allow_tracing` - (Optional) Whether tracing is allowed. Default is `false`.

Example:
```terraform
subscriptions = {
  "developer-sub" = {
    display_name     = "Developer Subscription"
    scope_type       = "product"
    scope_identifier = "starter"
    state            = "active"
    allow_tracing    = true
  }
  "api-specific-sub" = {
    display_name     = "Petstore API Subscription"
    scope_type       = "api"
    scope_identifier = "petstore-api"
    state            = "active"
  }
}
```

Type:

```hcl
map(object({
    display_name     = string
    scope_type       = string           # "product", "api", or "all_apis"
    scope_identifier = optional(string) # Product ID or API name (not needed for "all_apis")
    user_id          = optional(string)
    primary_key      = optional(string)
    secondary_key    = optional(string)
    state            = optional(string, "active") # active, suspended, submitted, rejected, cancelled
    allow_tracing    = optional(bool, false)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_tenant_access"></a> [tenant\_access](#input\_tenant\_access)

Description: Controls whether access to the management API is enabled. When enabled, the primary/secondary keys provide access to this API.

Type:

```hcl
object({
    enabled = bool
  })
```

Default: `null`

### <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id)

Description: The ID of the subnet in the virtual network where the API Management service will be deployed.

Type: `string`

Default: `null`

### <a name="input_virtual_network_type"></a> [virtual\_network\_type](#input\_virtual\_network\_type)

Description: The type of virtual network configuration for the API Management service.

Type: `string`

Default: `"None"`

### <a name="input_zones"></a> [zones](#input\_zones)

Description: Specifies a list of Availability Zones in which this API Management service should be located. Only supported in the Premium tier.

Type: `list(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_additional_locations"></a> [additional\_locations](#output\_additional\_locations)

Description: Information about additional locations for the API Management Service.

### <a name="output_api_ids"></a> [api\_ids](#output\_api\_ids)

Description: A map of API names to their resource IDs.

### <a name="output_api_operation_ids"></a> [api\_operation\_ids](#output\_api\_operation\_ids)

Description: A map of API operation keys to their operation IDs.

### <a name="output_api_operations"></a> [api\_operations](#output\_api\_operations)

Description: A map of API operations created in the API Management service.

### <a name="output_api_version_set_ids"></a> [api\_version\_set\_ids](#output\_api\_version\_set\_ids)

Description: A map of API version set names to their resource IDs.

### <a name="output_api_version_sets"></a> [api\_version\_sets](#output\_api\_version\_sets)

Description: A map of API version sets created in the API Management service.

### <a name="output_apim_gateway_url"></a> [apim\_gateway\_url](#output\_apim\_gateway\_url)

Description: The gateway URL of the API Management service.

### <a name="output_apim_management_url"></a> [apim\_management\_url](#output\_apim\_management\_url)

Description: The management URL of the API Management service.

### <a name="output_apis"></a> [apis](#output\_apis)

Description: A map of APIs created in the API Management service.

### <a name="output_certificates"></a> [certificates](#output\_certificates)

Description: Certificate information for the API Management Service.

### <a name="output_developer_portal_url"></a> [developer\_portal\_url](#output\_developer\_portal\_url)

Description: The publisher URL of the API Management service.

### <a name="output_gateway_regional_url"></a> [gateway\_regional\_url](#output\_gateway\_regional\_url)

Description: The Region URL for the Gateway of the API Management Service.

### <a name="output_hostname_configuration"></a> [hostname\_configuration](#output\_hostname\_configuration)

Description: The hostname configuration for the API Management Service.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the API Management service.

### <a name="output_named_value_ids"></a> [named\_value\_ids](#output\_named\_value\_ids)

Description: A map of named value keys to their resource IDs.

### <a name="output_named_values"></a> [named\_values](#output\_named\_values)

Description: A map of named values created in the API Management service.

### <a name="output_policy"></a> [policy](#output\_policy)

Description: Service-level policy details.

### <a name="output_portal_url"></a> [portal\_url](#output\_portal\_url)

Description: The URL for the Publisher Portal associated with this API Management service.

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of the private endpoints created.

### <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses)

Description: The private IP addresses of the private endpoints created by this module

### <a name="output_product_ids"></a> [product\_ids](#output\_product\_ids)

Description: A map of product keys to their resource IDs.

### <a name="output_products"></a> [products](#output\_products)

Description: A map of products created in the API Management service.

### <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses)

Description: The Public IP addresses of the API Management Service.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The API Management service resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the API Management service.

### <a name="output_scm_url"></a> [scm\_url](#output\_scm\_url)

Description: The URL for the SCM (Source Code Management) Endpoint associated with this API Management service.

### <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids)

Description: A map of subscription keys to their resource IDs.

### <a name="output_subscription_keys"></a> [subscription\_keys](#output\_subscription\_keys)

Description: A map of subscription keys to their primary and secondary keys.

### <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions)

Description: A map of subscriptions created in the API Management service.

### <a name="output_tenant_access"></a> [tenant\_access](#output\_tenant\_access)

Description: The tenant access information for the API Management Service.

### <a name="output_workspace_identity"></a> [workspace\_identity](#output\_workspace\_identity)

Description: The identity for the created workspace.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->