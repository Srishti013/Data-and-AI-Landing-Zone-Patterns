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

- Security and Secrets Management

## Notable changes in this version

### v1

- Initial version to deploy Azure Key Vault with enterprise naming/tagging, RBAC, private endpoint support, key and secret management, diagnostics, and lock controls.
- Security baseline is enforced in module logic for RBAC authorization, private-only network access, and purge protection.

## Upgrade Path

- Upgrade supported from v1.0.0.1 to v1.0.0.2.
- Update module source from modules/mbb_key_vault/v1.0.0.1 to modules/mbb_key_vault/v1.0.0.2.
- Input contract change:
  - Removed input: purge_protection_enabled.

# Product Description

## Overview

- This module deploys Azure Key Vault and applies standardized naming/tags using mbb_naming_module.
- It supports Key Vault contacts, keys, secrets, private endpoints, role assignments, diagnostics, and management locks.
- Key and secret lifecycle resources are managed through embedded submodules.

## Note

- Security behavior is enforced in module implementation:
  - enable_rbac_authorization = true
  - public_network_access_enabled = false
  - purge_protection_enabled = true
- Diagnostic settings input is required in this version and must include at least one valid sink for each setting object.

## Network Topology (wherever applicable)

- Designed for private network access patterns using private endpoints and private DNS zone integration.
- Suitable for hub/spoke landing zones with centralized secret management.

## Azure Service(s) in Scope

- Azure Key Vault
- Azure Private Endpoint
- Azure RBAC Role Assignments
- Azure Monitor Diagnostic Settings

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Tenant ID
- Subnet for private endpoint (if private endpoint is used)
- RBAC principals for data-plane/access governance

## Optional Azure services Used (Customer Choice)

- Log Analytics Workspace
- Event Hub
- Storage Account
- Private DNS Zones

## Limitations

- Provider constraints in this version: azurerm >= 3.117, < 5.0.
- Legacy access policy mode is optional but RBAC mode is enforced by default behavior in main resource configuration.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Key Vault with optional keys, secrets, and private endpoints.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 3.117, < 5.0 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |
| time | ~> 0.9 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| mbb_key_vault | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_key_vault) | v1.0.0.2 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "key_vault" {
  source = "../../modules/mbb_key_vault/v1.0.0.2"

  name                = "kv-platform-prod-sea-01"
  location            = "southeastasia"
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id

  diagnostic_settings = {
    default = {
      workspace_resource_id = var.log_analytics_workspace_id
      log_groups            = ["allLogs"]
      metric_categories     = ["AllMetrics"]
    }
  }

  private_endpoints = {
    pe1 = {
      subnet_resource_id            = var.private_endpoint_subnet_id
      private_dns_zone_resource_ids = [var.private_dns_zone_id]
    }
  }

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "kv"

  app_name             = var.app_name
  business_unit        = var.business_unit
  business_owner       = var.business_owner
  budget_id            = var.budget_id
  cost_center          = var.cost_center
  criticality          = var.criticality
  environment          = var.environment
  data_classification  = var.data_classification
  compliance           = var.compliance
}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Key Vault name | string | n/a | yes |
| location | Azure location | string | n/a | yes |
| resource_group_name | Resource group for deployment | string | n/a | yes |
| tenant_id | Azure tenant ID | string | n/a | yes |
| sku_name | Key Vault SKU | string | Standard | no |
| diagnostic_settings | Diagnostic settings map | map(object) | n/a | yes |
| contacts | Certificate contacts map | map(object) | {} | no |
| role_assignments | Role assignment map | map(object) | {} | no |
| lock | Lock configuration | object | null | no |
| network_acls | Network ACL configuration | object | {} | no |
| private_endpoints | Private endpoint map | map(object) | {} | no |
| private_endpoints_manage_dns_zone_group | Manage private DNS zone groups in module | bool | true | no |
| keys | Keys map | map(object) | {} | no |
| secrets | Secrets map | map(object) | {} | no |
| secrets_value | Secret values map (sensitive) | map(string) | {} | no |
| env | Naming module environment code | string | n/a | yes |
| au | Accounting unit code | string | n/a | yes |
| app_code | Application code | string | n/a | yes |
| bu | Business unit code | string | n/a | yes |
| owner | Technology owner group | string | n/a | yes |
| business_owner | Mandatory business owner tag | string | n/a | yes |
| business_unit | Mandatory business unit tag | string | n/a | yes |
| budget_id | Mandatory budget ID tag | string | n/a | yes |
| cost_center | Mandatory cost center tag | string | "" | no |
| criticality | Mandatory criticality tag | string | n/a | yes |
| environment | Mandatory environment tag | string | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azurerm_key_vault.this | resource |
| azurerm_key_vault_certificate_contacts.this | resource |
| azurerm_management_lock.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_private_endpoint.this_unmanaged_dns_zone_groups | resource |
| azurerm_private_endpoint_application_security_group_association.this | resource |
| time_sleep.wait_for_rbac_before_contact_operations | resource |
| time_sleep.wait_for_rbac_before_key_operations | resource |
| time_sleep.wait_for_rbac_before_secret_operations | resource |
| module.keys | module |
| module.secrets | module |

### Outputs

| Name | Description |
|------|-------------|
| name | Key Vault name |
| resource_id | Key Vault resource ID |
| uri | Key Vault URI |
| private_endpoints | Private endpoint resources map |
| keys | Keys module output map |
| keys_resource_ids | Key resource ID map |
| secrets | Secrets module output map |
| secrets_resource_ids | Secret resource ID map |
