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

- Data Platform and Caching

## Notable changes in this version

### v1

- Initial version to deploy Azure Managed Redis with enterprise naming/tagging, high availability, identity support, optional CMK, and configurable default database settings.

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module deploys Azure Managed Redis using azurerm_managed_redis and standardized naming from naming_module.
- It supports configurable SKU tiers, high availability, public network access policy, optional managed identity, and optional customer-managed key settings.
- It allows detailed default database controls including clustering, eviction policy, persistence, and Redis modules.

## Note

- The Microsoft.Cache resource provider must be registered in the target subscription.
- Validate regional availability for Azure Managed Redis before deployment.

## Network Topology (wherever applicable)

- Typically deployed in private application tiers where cache endpoints are consumed by application workloads.
- Public network access defaults to Disabled in this module.

## Azure Service(s) in Scope

- Azure Managed Redis
- Azure RBAC and Managed Identity (if configured)

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Optional User Assigned Managed Identity (if identity type requires it)
- Optional Key Vault key and identity permissions (if CMK is configured)

## Optional Azure services Used (Customer Choice)

- Azure Key Vault (for CMK)
- User Assigned Managed Identity

## Limitations

- Provider constraints in this version:
  - terraform >= 1.9, < 2.0
  - azurerm >= 3.71, < 5.0.0
  - azapi ~> 2.0
  - modtm ~> 0.3
  - random ~> 3.5

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Azure Managed Redis instance with configurable database and security controls.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 3.71, < 5.0.0 |
| azapi | ~> 2.0 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| managed_redis_cache | [IAC link](https://github.com/your-org/iac-modules/tree/main/modules/managed_redis_cache) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "managed_redis" {
  source = "../../modules/managed_redis_cache/v1.0.0.0"

  resource_group_name = var.resource_group_name
  sku_name            = "Balanced_B3"

  default_database = {
    client_protocol   = "Encrypted"
    clustering_policy = "OSSCluster"
    eviction_policy   = "VolatileLRU"
  }

  public_network_access    = "Disabled"
  high_availability_enabled = true

  env                = var.env
  au                 = var.au
  owner              = var.owner
  app_code           = var.app_code
  bu                 = var.bu
  resource_type_code = "redis"

  app_name            = var.app_name
  app_support         = var.app_support
  business_unit       = var.business_unit
  business_owner      = var.business_owner
  budget_id           = var.budget_id
  cost_center         = var.cost_center
  criticality         = var.criticality
  environment         = var.environment
  data_classification = var.data_classification
  compliance          = var.compliance
}
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group for deployment | string | n/a | yes |
| sku_name | Managed Redis SKU | string | n/a | yes |
| default_database | Default database configuration object | object | n/a | yes |
| high_availability_enabled | Enable high availability | bool | true | no |
| public_network_access | Public network access mode | string | "Disabled" | no |
| managed_redis_identity | Managed identity configuration | object | null | no |
| customer_managed_key | Customer managed key object | object | null | no |
| timeouts | Custom create/read/update/delete timeouts | object | null | no |
| tags | Additional custom tags | map(string) | null | no |
| enable_telemetry | Enable AVM telemetry | bool | true | no |
| env | Naming module environment code | string | n/a | yes |
| au | Accounting unit code | string | n/a | yes |
| owner | Technology owner group | string | n/a | yes |
| app_code | Application code | string | n/a | yes |
| bu | Business unit code | string | n/a | yes |
| resource_type_code | Azure resource type code | string | n/a | yes |
| app_name | Mandatory business tag | string | n/a | yes |
| app_support | Mandatory support contact tag | string | n/a | yes |
| business_unit | Mandatory business tag | string | n/a | yes |
| business_owner | Mandatory business tag | string | n/a | yes |
| budget_id | Mandatory finance tag | string | n/a | yes |
| cost_center | Mandatory finance tag | string | "" | no |
| criticality | Mandatory operations tag | string | n/a | yes |
| environment | Mandatory operations tag | string | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azurerm_managed_redis.this | resource |
| random_uuid.telemetry | resource |
| modtm_telemetry.telemetry | resource |
| azurerm_client_config.telemetry | data |
| modtm_module_source.telemetry | data |

### Outputs

| Name | Description |
|------|-------------|
| resource | Full Managed Redis resource object |
| resource_id | Managed Redis resource ID |
| hostname | DNS hostname of Managed Redis endpoint |
