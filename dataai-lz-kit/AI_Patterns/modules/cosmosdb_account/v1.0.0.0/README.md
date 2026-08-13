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

- Data Platform

## Notable changes in this version

### v1

- Initial version to deploy Cosmos DB account with SQL databases/containers, private endpoints, and enterprise tagging.

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module deploys an Azure Cosmos DB account (NoSQL/SQL API by default) using the Maybank naming module.
- It supports SQL database and SQL container provisioning, network restrictions, private endpoints, optional multi-region failover, and restore configuration.
- Security defaults include TLS 1.2, local authentication disabled, public network access disabled, and metadata write restrictions via keys.

## Note

- `sql_databases` and nested `containers` are optional and can be managed in the same module invocation.
- If private DNS zone groups are managed outside Terraform/Azure Policy, set `private_endpoints_manage_dns_zone_group = false`.

## Network Topology (wherever applicable)

- Recommended with private endpoint integration in hub/spoke networks.
- Firewall and VNet filtering can be enabled for controlled inbound access.

## Azure Service(s) in Scope

- Azure Cosmos DB Account
- Azure Cosmos DB SQL Database and SQL Container
- Azure Private Endpoint

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Optional subnets and private DNS zones for private endpoint setup
- Optional Key Vault/HSM key resources if customer-managed encryption is required

## Optional Azure services Used (Customer Choice)

- Private DNS Zones
- Azure Key Vault / Managed HSM

## Limitations

- Some settings are mutually dependent (for example bounded staleness requires both interval and staleness prefix values).
- `sql_databases` throughput and autoscale settings are mutually exclusive per database/container.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one Cosmos DB account with optional SQL databases/containers and private endpoints.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 4.0.0, < 5.0.0 |
| modtm | ~> 0.3 |
| random | >= 3.5.0, < 4.0.0 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| mbb_cosmosdb_account | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_cosmosdb_account) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "cosmosdb_account" {
  source = "../../modules/mbb_cosmosdb_account/v1.0.0.0"

  resource_group_name           = var.resource_group_name
  public_network_access_enabled = false
  local_authentication_disabled = true

  sql_databases = {
    appdb = {
      name = "appdb"
      containers = {
        c1 = {
          name                = "orders"
          partition_key_paths = ["/orderId"]
        }
      }
    }
  }

  private_endpoints = {
    pe1 = {
      subnet_resource_id            = var.pe_subnet_id
      subresource_name              = "Sql"
      private_dns_zone_resource_ids = [var.private_dns_zone_id]
    }
  }

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "cosno"

  business_owner      = var.business_owner
  budget_id           = var.budget_id
  cost_center         = var.cost_center
  criticality         = var.criticality
  environment         = var.environment
  service             = var.service
}
```

```tfvars
resource_group_name = "rg-data-prod"
pe_subnet_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/snet-pe"
private_dns_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group where Cosmos DB account is deployed | `string` | n/a | yes |
| offer_type | Cosmos account offer type (`Standard`) | `string` | `"Standard"` | no |
| kind | Cosmos account kind (default `GlobalDocumentDB`) | `string` | `"GlobalDocumentDB"` | no |
| public_network_access_enabled | Enable/disable public network access | `bool` | `false` | no |
| is_virtual_network_filter_enabled | Enable VNet filtering | `bool` | `false` | no |
| ip_range_filter | Set of allowed CIDR ranges | `set(string)` | `[]` | no |
| virtual_network_rules | List of VNet rules for account access | `list(object)` | `[]` | no |
| consistency_policy | Consistency policy object | `object` | `null` | no |
| geo_locations | Multi-region location list with failover priorities | `list(object)` | `[]` | no |
| capabilities | Set of capabilities (for example `EnableServerless`) | `set(string)` | `[]` | no |
| sql_databases | Map of SQL databases and nested containers to create | `map(object)` | `{}` | no |
| private_endpoints | Map of private endpoint definitions | `map(object)` | `{}` | no |
| private_endpoints_manage_dns_zone_group | Manage private DNS zone group in module | `bool` | `true` | no |
| backup | Backup configuration object | `object` | `null` | no |
| identity | Managed identity configuration object | `object` | `null` | no |
| key_vault_key_id | Key Vault key ID for CMK | `string` | `null` | no |
| managed_hsm_key_id | Managed HSM key ID for CMK | `string` | `null` | no |
| restore | Restore configuration for `create_mode = Restore` | `object` | `null` | no |
| tags | Resource tags merged with naming module tags | `map(string)` | `{}` | no |
| env | Naming module environment code | `string` | n/a | yes |
| au | Accounting unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| business_owner | Mandatory business owner tag | `string` | n/a | yes |
| budget_id | Mandatory budget ID tag | `string` | n/a | yes |
| cost_center | Mandatory cost center tag | `string` | module-defined | no |
| criticality | Mandatory criticality tag | `string` | module-defined | no |
| environment | Mandatory environment tag | `string` | module-defined | no |
| service | Mandatory service tag value | `string` | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azurerm_cosmosdb_account.this | resource |
| azurerm_cosmosdb_sql_database.this | resource |
| azurerm_cosmosdb_sql_container.this | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_private_endpoint.this_unmanaged_dns_zone_groups | resource |
| azurerm_private_endpoint_application_security_group_association.this | resource |
| modtm_telemetry.telemetry | resource |
| random_uuid.telemetry | resource |

### Outputs

| Name | Description |
|------|-------------|
| id | Cosmos DB account resource ID |
| name | Cosmos DB account name |
| endpoint | Primary endpoint |
| read_endpoints | Read endpoints list |
| write_endpoints | Write endpoints list |
| identity_principal_id | Managed identity principal ID when configured |
| private_endpoints | Map of private endpoint resources |
| sql_databases | Map of SQL database resources |
| sql_containers | Map of SQL container resources |
