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

- Analytics Platform

## Notable changes in this version

### v1

- Initial version to deploy Microsoft Fabric Capacity with naming and enterprise tagging standards.

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module deploys an Azure Fabric Capacity resource with configurable capacity SKU.
- It assigns capacity administrators and applies standardized naming/tagging through `naming_module`.
- The module is intended for centralized Microsoft Fabric capacity provisioning in enterprise environments.

## Note

- `Microsoft.Fabric` resource provider must be registered in the subscription.
- Capacity administrators must also have required Fabric portal level roles to manage and view capacity.

## Network Topology (wherever applicable)

- Not applicable for direct network pathing; capacity is a platform control-plane resource.

## Azure Service(s) in Scope

- Azure Fabric Capacity

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Registered `Microsoft.Fabric` provider
- Entra users/service principals to assign as administrators

## Optional Azure services Used (Customer Choice)

- Monitoring and governance integrations based on organization standards

## Limitations

- Provider pinning is constrained to `azurerm < 4.37` per module compatibility note.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Fabric Capacity resource.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 4.0, < 4.37 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | >= 3.6.2 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| fabric_capacity | [IAC link](https://github.com/your-org/iac-modules/tree/main/modules/fabric_capacity) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "fabric_capacity" {
  source = "../../modules/fabric_capacity/v1.0.0.0"

  resource_group_name      = var.resource_group_name
  administration_members   = var.administration_members
  sku_name                 = "F32"

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "fbc"
  product_version    = "1.0.0.0"

  business_owner      = var.business_owner
  business_unit       = var.business_unit
  budget_id           = var.budget_id
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  criticality         = var.criticality
  environment         = var.environment
  service             = var.service
}
```

```tfvars
resource_group_name    = "rg-fabric-core"
administration_members = ["user@contoso.com", "00000000-0000-0000-0000-000000000000"]
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group where Fabric Capacity will be deployed | `string` | n/a | yes |
| administration_members | List of Entra users/service principals for capacity admin assignment | `list(string)` | n/a | yes |
| sku_name | Fabric capacity SKU (`F2` to `F2048`) | `string` | `"F2"` | no |
| env | Naming module environment code | `string` | n/a | yes |
| au | Accounting unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Naming module resource type code | `string` | n/a | yes |
| product_version | Product version string | `string` | n/a | yes |
| business_owner | Mandatory business owner tag | `string` | n/a | yes |
| business_unit | Mandatory business unit tag | `string` | n/a | yes |
| budget_id | Mandatory budget ID tag | `string` | n/a | yes |
| cost_center | Mandatory cost center tag | `string` | n/a | yes |
| data_classification | Mandatory data classification tag | `string` | n/a | yes |
| compliance | Mandatory compliance tag | `string` | n/a | yes |
| criticality | Mandatory criticality tag | `string` | n/a | yes |
| environment | Mandatory environment tag | `string` | n/a | yes |
| service | Mandatory service tag value | `string` | n/a | yes |
| additional_tags | Additional tags merged with naming tags | `map(string)` | `null` | no |

### Resources

| Name | Type |
|------|------|
| azurerm_fabric_capacity.fabric_capacity | resource |

### Outputs

| Name | Description |
|------|-------------|
| capacity_id | Resource ID of Fabric Capacity |
