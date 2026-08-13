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

- Application Hosting

## Notable changes in this version

### v1

- Initial version to deploy Azure App Service Plan (`mbb_app_service_plan`).

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This Terraform module deploys an Azure App Service Plan for App Service, Function App, and Logic App Standard workloads.
- It supports Linux, Windows, and WindowsContainer operating systems, optional App Service Environment deployment, optional resource lock, RBAC assignments, and Maybank naming and tagging standards.
- Resource name and location are derived from the naming module rather than direct `name` and `location` inputs.

## Note

- `os_type` must be one of `Windows`, `Linux`, or `WindowsContainer`.
- `premium_plan_auto_scale_enabled` should only be enabled for Premium SKUs.
- Default SKU is `P1v2`, which is also the minimum recommended SKU for zone balancing.

## Network Topology (wherever applicable)

- This module creates a compute hosting plan only. Network topology is defined by downstream App Service resources and any App Service Environment configuration.

## Azure Service(s) in Scope

- Azure App Service Plan

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Optional App Service Environment, if isolated deployment is required

## Optional Azure services Used (Customer Choice)

- App Service Environment

## Limitations

- Resource naming and location are controlled by the naming module.
- Zone balancing and elastic worker settings are subject to supported SKU behaviour in Azure.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This module creates one App Service Plan and optionally applies resource lock and RBAC role assignments.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | ~> 4.0 |
| azapi | ~> 2.0 |
| modtm | ~> 0.3 |
| random | ~> 3.5 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| mbb_app_service_plan | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_app_service_plan) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "app_service_plan" {
  source = "../../modules/mbb_app_service_plan/v1.0.0.0"

  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name
  worker_count        = var.worker_count

  app_service_environment_id      = var.app_service_environment_id
  maximum_elastic_worker_count    = var.maximum_elastic_worker_count
  per_site_scaling_enabled        = var.per_site_scaling_enabled
  premium_plan_auto_scale_enabled = var.premium_plan_auto_scale_enabled
  zone_balancing_enabled          = var.zone_balancing_enabled
  role_assignments                = var.role_assignments
  lock                            = var.lock
  tags                            = var.tags

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  business_owner     = var.business_owner
  resource_type_code = "asp"

  environment         = var.environment
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  budget_id           = var.budget_id
}
```

```tfvars
resource_group_name = "rg-app-sea-001"
os_type             = "Linux"
sku_name            = "P1v2"
worker_count        = 3

app_service_environment_id      = null
maximum_elastic_worker_count    = null
per_site_scaling_enabled        = false
premium_plan_auto_scale_enabled = false
zone_balancing_enabled          = true
role_assignments                = {}
lock                            = null
tags                            = {}

env                = "tst"
au                 = "00121"
app_code           = "sample"
bu                 = "it"
owner              = "CEAT"
business_owner     = "Platform Owner"
resource_type_code = "asp"

environment         = "Test"
business_unit       = "GTD-ISD"
criticality         = "T3"
cost_center         = "383-80572"
data_classification = "Business Sensitive"
compliance          = "BNM RMIT"
budget_id           = "83254"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group where the App Service Plan is deployed | `string` | n/a | yes |
| os_type | Operating system type: `Windows`, `Linux`, or `WindowsContainer` | `string` | n/a | yes |
| sku_name | App Service Plan SKU name | `string` | `"P1v2"` | no |
| worker_count | Number of workers allocated to the plan | `number` | `3` | no |
| app_service_environment_id | Optional App Service Environment resource ID | `string` | `null` | no |
| maximum_elastic_worker_count | Maximum elastic worker count | `number` | `null` | no |
| per_site_scaling_enabled | Enable per-site scaling | `bool` | `false` | no |
| premium_plan_auto_scale_enabled | Enable Premium auto scale | `bool` | `false` | no |
| zone_balancing_enabled | Enable zone balancing | `bool` | `true` | no |
| role_assignments | RBAC role assignment map | `map(object)` | `{}` | no |
| lock | Resource lock configuration | `object` | `null` | no |
| tags | Resource tags | `map(string)` | `null` | no |
| enable_telemetry | Enable telemetry collection | `bool` | `true` | no |
| env | Environment code | `string` | n/a | yes |
| au | Accounting Unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Azure resource type abbreviation | `string` | `"asp"` | no |
| business_owner | Contact name of the application owner | `string` | n/a | yes |
| business_unit | Department owning the resource | `string` | n/a | yes |
| cost_center | Cost center | `string` | n/a | yes |
| data_classification | Data classification level | `string` | n/a | yes |
| compliance | Compliance standard | `string` | n/a | yes |
| criticality | Workload criticality | `string` | n/a | yes |
| environment | Environment tag value | `string` | n/a | yes |
| budget_id | Budget or GL code used by Finance | `string` | n/a | yes |
| org | Company or business unit code | `string` | `"mbb"` | no |
| region_code | Region code | `string` | `"sea"` | no |
| additional_tags | Additional tags to merge with module tags | `map(string)` | `null` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_service_plan.this | resource |
| azurerm_management_lock.this | resource |
| azurerm_role_assignment.this | resource |
| random_uuid.telemetry | resource |
| modtm_telemetry.telemetry | resource |

### Outputs

| Name | Description |
|------|-------------|
| name | Name of the App Service Plan |
| resource | Full App Service Plan resource object |
| resource_id | Resource ID of the App Service Plan |
