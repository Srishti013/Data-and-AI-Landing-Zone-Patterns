[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span> |
| --- | --- |
| Version | 1.0.0.1 |
| Created By | Pooja Pradhan |
| Reviewed By | Amit Kumar |

# About this product version

## Product State: Released

## Product Category

- Backup and Recovery

## Notable changes in this version

### v1.0.0.1

-  Initial version to deploy Backup Vault.

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module deploys Azure Data Protection Backup Vault and optional backup policies/instances for multiple workload types.
- The vault name, location, and baseline tags are generated through `naming_module`.
- The module supports lock, RBAC, diagnostic settings, resource guard association, and customer-managed key encryption.

## Note

- Vault redundancy and datastore choices drive feature availability; for example, cross-region restore is only valid with Geo-redundant storage.

## Network Topology (wherever applicable)

- Recommended in hub/spoke landing zones with centralized Key Vault, monitoring, and policy governance.
- If private connectivity is required for protected workloads, ensure dependent service networking is already in place.

## Azure Service(s) in Scope

- Azure Data Protection Backup Vault
- Backup Policies and Backup Instances (Disk, Blob, AKS, PostgreSQL, PostgreSQL Flexible)
- Azure Monitor Diagnostic Settings
- Azure Data Protection Resource Guard

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Protected source resources (managed disks, storage accounts/containers, AKS clusters, PostgreSQL resources)
- Optional Key Vault and key material for CMK
- Optional Log Analytics/Event Hub/Storage for diagnostics

## Optional Azure services Used (Customer Choice)

- Azure Key Vault (for customer-managed encryption)
- Azure Monitor (diagnostics destinations)
- Resource Guard for delete protection controls

## Limitations

- `cross_region_restore_enabled` is supported only when `redundancy = "GeoRedundant"`.
- Backup instance type must match referenced backup policy type.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This Terraform module deploys one Backup Vault and optional policy/instance objects for supported datasource types.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | ~> 4.0 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | >= 3.5.0, < 4.0 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| backup_vault | [IAC link](https://github.com/your-org/iac-modules/tree/main/modules/backup_vault) | v1.0.0.1 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "backup_vault" {
  source = "../../modules/backup_vault/v1.0.0.1"

  resource_group_name = var.resource_group_name
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"

  backup_policies = {
    disk_daily = {
      type                            = "disk"
      name                            = "disk-policy-daily"
      backup_repeating_time_intervals = ["R/2026-01-01T01:00:00+00:00/P1D"]
      default_retention_duration      = "P30D"
    }
  }

  backup_instances = {
    disk01 = {
      type                         = "disk"
      name                         = "disk-backup-01"
      backup_policy_key            = "disk_daily"
      disk_id                      = var.disk_id
      snapshot_resource_group_name = var.snapshot_resource_group_name
    }
  }

  managed_identities = {
    system_assigned = true
  }

  diagnostic_settings = {
    default = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = "bv"

  business_owner      = var.business_owner
  business_unit       = var.business_unit
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance
  criticality         = var.criticality
  environment         = var.environment
  budget_id           = var.budget_id
  service             = var.service
}
```

```tfvars
resource_group_name           = "rg-backup-core"
disk_id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.Compute/disks/disk-app-01"
snapshot_resource_group_name  = "rg-backup-snapshots"
log_analytics_workspace_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/law-core"

env                 = "prod"
au                  = "0233985"
app_code            = "backup"
bu                  = "it"
owner               = "platform"
business_owner      = "Platform Team"
business_unit       = "Infrastructure"
cost_center         = "CC001"
data_classification = "Internal"
compliance          = "Standard"
criticality         = "High"
environment         = "Prod"
budget_id           = "BUD001"
service             = "Backup"
```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Resource group where Backup Vault is deployed | `string` | n/a | yes |
| datastore_type | Backup vault datastore type (`ArchiveStore`, `OperationalStore`, `SnapshotStore`, `VaultStore`) | `string` | n/a | yes |
| redundancy | Backup storage redundancy (`GeoRedundant`, `LocallyRedundant`, `ZoneRedundant`) | `string` | n/a | yes |
| backup_policies | Map of backup policy definitions used by backup instances | `map(object)` | `{}` | no |
| backup_instances | Map of backup instances that reference `backup_policies` keys | `map(object)` | `{}` | no |
| cross_region_restore_enabled | Enable CRR (valid only for GeoRedundant) | `bool` | `false` | no |
| immutability | Vault immutability mode | `string` | `"Disabled"` | no |
| retention_duration_in_days | Soft delete retention duration in days | `number` | module-defined | no |
| soft_delete | Soft delete state for backup vault | `string` | module-defined | no |
| managed_identities | Managed identity settings for the vault | `object` | module-defined | no |
| customer_managed_key | Customer-managed key configuration | `object` | `null` | no |
| resource_guard | Optional resource guard configuration | `object` | module-defined | no |
| role_assignments | Role assignments on vault (and related resources when configured) | `map(object)` | `{}` | no |
| lock | Optional management lock configuration | `object` | `null` | no |
| diagnostic_settings | Diagnostic settings map for vault telemetry export | `map(object)` | `{}` | no |
| tags | Additional tags merged with naming module tags | `map(string)` | module-defined | no |
| env | Naming module environment code | `string` | n/a | yes |
| org | Naming module organization code | `string` | `"{org}"` | no |
| region_code | Naming module region code | `string` | module-defined | no |
| base_name | Naming module base name | `string` | `null` | no |
| additional_name | Naming module additional suffix | `string` | `null` | no |
| iterator | Naming module iterator | `string` | `null` | no |
| au | Accounting unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Resource type code for generated name | `string` | n/a | yes |
| business_owner | Mandatory business owner tag | `string` | n/a | yes |
| business_unit | Mandatory business unit tag | `string` | n/a | yes |
| cost_center | Mandatory cost center tag | `string` | n/a | yes |
| data_classification | Mandatory data classification tag | `string` | n/a | yes |
| compliance | Mandatory compliance tag | `string` | n/a | yes |
| criticality | Mandatory criticality tag | `string` | n/a | yes |
| environment | Mandatory environment tag | `string` | n/a | yes |
| budget_id | Mandatory budget/finance tag | `string` | n/a | yes |
| service | Mandatory service tag value | `string` | n/a | yes |

### Resources

| Name | Type |
|------|------|
| azurerm_data_protection_backup_vault.this | resource |
| azurerm_data_protection_backup_policy_disk.this | resource |
| azurerm_data_protection_backup_policy_blob_storage.this | resource |
| azurerm_data_protection_backup_policy_kubernetes_cluster.this | resource |
| azurerm_data_protection_backup_policy_postgresql.this | resource |
| azurerm_data_protection_backup_policy_postgresql_flexible_server.this | resource |
| azurerm_data_protection_backup_instance_disk.this | resource |
| azurerm_data_protection_backup_instance_blob_storage.this | resource |
| azurerm_data_protection_backup_instance_kubernetes_cluster.this | resource |
| azurerm_data_protection_backup_instance_postgresql.this | resource |
| azurerm_data_protection_backup_instance_postgresql_flexible_server.this | resource |
| azurerm_data_protection_backup_vault_customer_managed_key.this | resource |
| azurerm_data_protection_resource_guard.this | resource |
| azapi_resource.vault_resource_guard_association | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_management_lock.this | resource |

### Outputs

| Name | Description |
|------|-------------|
| backup_vault_id | Resource ID of the Backup Vault |
| backup_vault_name | Name of the Backup Vault |
| backup_policy_ids | Map of backup policy IDs by key |
| backup_instance_ids | Map of backup instance IDs by key |
| resource_id | Alias output for backup vault resource ID |
| vault_id | Alias output for backup vault resource ID |
| identity_principal_id | System-assigned identity principal ID when enabled |
| resource_guard_id | Resource Guard resource ID when enabled |
| customer_managed_key_id | CMK binding resource ID when enabled |
