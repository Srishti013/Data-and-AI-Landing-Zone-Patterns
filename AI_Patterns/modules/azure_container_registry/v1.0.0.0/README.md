[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0|
| Created By | Sandeep B R |
| Reviewed By| |

# About this product version

## Product State: Released

## Product Category

- Azure Container Registry

## Notable changes in this version

### v1.0.0.0

- This is the initial version to deploy Azure Container Registry Service in Azure and no notable changes for version 1.0.0.0

## Upgrade Path

- Not Available as it is the initial version

# Product Description

## Overview

- Azure Container Registry allows you to build, store, and manage container images and artifacts in a private registry for all types of container deployments. Use Azure container registries with your existing container development and deployment pipelines. Use Azure Container Registry Tasks to build container images in Azure on-demand, or automate builds triggered by source code updates, updates to a container's base image, or timers.


## Note

- None

## Network Topology (wherever applicable)

- None

## Azure Service(s) in Scope

- Azure Container Registry

## Azure Services Needed (Pre-Requisites)

- Resource Group

## Optional Azure services Used (Customer Choice)

- None

## Limitations

- None

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This terraform module creates one `Azure Container Registry`.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.4 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.5 |



### Azure Artifacts

| Name | Source | Version |
|------|--------|---------|
| Azure Azure Container Registry | [mbb_azure_container_registry](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/user/sandeep-ai/modules/mbb_azure_container_registry/v1.0.0.0) | 1.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

```main.tf
module "azure_container_registry" {
  source   = "./modules/mbb_azure_container_registry/v1.0.0.0"
  for_each = var.azure_container_registry

  providers = {
    azurerm = azurerm.dev_myw_sub
  }

  # Naming and tag variables
  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = each.value.region
  description         = each.value.description
  notification_emails = each.value.notification_emails
  app_id              = each.value.app_id
  auto_delete         = each.value.auto_delete
  delete_after        = each.value.delete_after
  integration_id      = each.value.integration_id
  retention           = each.value.retention
  experiment_phase    = each.value.experiment_phase
  sandbox_type        = each.value.sandbox_type
  os                  = each.value.os
  patch_policy        = each.value.patch_policy
  maintenance_window  = each.value.maintenance_window
  last_vm_accessed    = each.value.last_vm_accessed

  # location            = each.value.location
  resource_group_name = module.ai_resource_group[each.value.resource_group_key].name

  managed_identities = {
    system_assigned            = each.value.managed_identities.system_assigned
    user_assigned_resource_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  private_endpoints = each.value.private_endpoints != null ? {
    for pe_key, pe_config in each.value.private_endpoints : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.virtual_network[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      subresource_name              = pe_config.subresource_name
      private_dns_zone_resource_ids = pe_config.dns_zone_key != null ? [data.azurerm_private_dns_zone.existing_private_dns_zones[pe_config.dns_zone_key].id] : []
      location                      = pe_config.location
      resource_group_name           = pe_config.resource_group_name
      network_interface_name        = pe_config.network_interface_name
    }
  } : {}

  depends_on = [module.ai_resource_group]
}
```

- terraform Variables

```tfvars
azure_container_registry = {
  "mbb-cr-aishared-dev-myw-01" = {

    env                = "dev"
    org                = "mbb"
    region_code        = "myw"
    base_name          = ""
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    app_code           = "aishared"
    bu                 = "it"
    owner              = "CEAT"
    resource_type_code = "cr"
    max_length         = 128
    no_dashes          = true
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = "Development"
    business_owner      = "Head of Cloud Engineering and Automation"
    business_unit       = "GTD-ISD"
    criticality         = "T1"
    cost_center         = "383-80572"
    data_classification = "Business Sensitive"
    compliance          = "BNM RMIT"
    app_name            = "Network Security and Connectivity"
    budget_id           = "83254"
    status              = "Live"
    service             = "TBD"

    # Optional Tags
    region              = "myw"
    description         = "Azure Container Registry for development environment"
    notification_emails = ["mss_ceat@maybank.com"]
    app_id              = "MBB-MYW-NET01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "NA"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    # location            = "southeastasia"
    resource_group_key = "mbb-rg-axxxx
    enable_telemetry   = true
    umi_key            = "mbb-uamixxx"

    managed_identities = {
      system_assigned = false
    }

    # tags = {
    #   environment = "sample"
    #   cost_centre = "demo"
    # }


    private_endpoints = {
      "mbb-pe-cr-aishared-dev-myw-01" = {
        name                   = "mbb-pe-cxxx"
        vnet_key               = "mbb-vnxx"
        subnet_key             = "mbb-sxxx"
        subresource_name       = "registry"
        dns_zone_key           = "acr"
        location               = "malaysiawest"
        resource_group_name    = "mbb-xxxx"
        network_interface_name = "mbb-pxxx"
      }
    }
  }
}

```

## Terraform Module Documentation

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env | Environment code | `string` | n/a | yes |
| au | Accounting Unit code | `string` | n/a | yes |
| app_code | Application code | `string` | n/a | yes |
| bu | Business unit code | `string` | n/a | yes |
| owner | Technology owner group | `string` | n/a | yes |
| resource_type_code | Azure resource type code | `string` | n/a | yes |
| business_owner | Contact name of the application owner | `string` | n/a | yes |
| business_unit | Business unit tag | `string` | n/a | yes |
| criticality | Criticality tag | `string` | n/a | yes |
| cost_center | Cost center tag | `string` | n/a | yes |
| data_classification | Data classification tag | `string` | n/a | yes |
| compliance | Compliance standard tag | `string` | n/a | yes |
| environment | Environment tag | `string` | n/a | yes |
| budget_id | Budget or GL code used by Finance | `string` | n/a | yes |
| org | Company or business unit code | `string` | module default | no |
| region_code | Region code | `string` | module default | no |
| additional_tags | Additional tags to merge with module tags | `map(string)` | `null` | no |
| name  | Specifies the name of the Container Registry | `string` | n/a | yes |
| resource_group_name| The name of the resource group in which to create the Container Registry | `string` | n/a | yes |
| Location |Specifies the supported Azure location where the resource exists | `string` | n/a | yes |
| sku |The SKU name of the container registry | `string` | n/a | yes |
| admin_enabled  |Specifies whether the admin user is enabled | `bool` | n/a | no |
| tags |Specifies whether the admin user is enabled | `map(string)` | n/a | no |
| georeplications | Specifies georeplications for container registry   | `map(string)` | n/a | no |
| network_rule_set| Specifies network_rule_set for container registry   | `map(string)` | n/a | no |
| public_network_access_enabled | Whether public network access is allowed for the container registry  | `bool` | n/a | no |
| quarantine_policy_enabled | Boolean value that indicates whether quarantine policy is enabled  | `bool` | n/a | no |
| retention_policy_in_days  | Boolean value that indicates whether quarantine policy is enabled  | `number` | n/a | no |
| trust_policy_enabled | Boolean value that indicated whether trust policy is enabled  | `bool` | n/a | no |
| zone_redundancy_enabled | Whether zone redundancy is enabled for this Container Registry | `bool` | n/a | no |
| export_policy_enabled | Boolean value that indicates whether export policy is enabled | `bool` | n/a | no |
| identity | identity of container registry   | `map(string)` | n/a | no |
| encryption  | encryption of container registry   | `map(string)` | n/a | no |
| anonymous_pull_enabled | Whether to allow anonymous (unauthenticated) pull access to this Container Registry  | `string` | n/a | no |
| data_endpoint_enabled | Whether to enable dedicated data endpoints for this Container Registry  | `string` | n/a | no |
| network_rule_bypass_option| WWhether to allow trusted Azure services to access a network-restricted Container Registry | `string` | n/a | no |



### Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | data resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) |  source |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource) | source |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | source |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | source |
| [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | source |
| [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | source |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_key_vault_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_key) | data resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data resource |



### Outputs

| Name | Description |
|------|-------------|
| name | The name of the parent resource |
| resource | This is the full output for the resource |
| resource_id | The resource id for the parent resource |


## Required Inputs

## Note

- Premium SKU is required for capabilities such as private networking rules, geo-replication, customer-managed keys, and zone redundancy.

## Network Topology (wherever applicable)

- For enterprise workloads, deploy ACR behind private endpoints and integrate with hub-hosted private DNS zones.
- When public access is disabled, ensure build agents, AKS clusters, and deployment runners have private connectivity to the registry.

## Azure Service(s) in Scope

- Azure Container Registry
- Azure Private Endpoint
- Azure Monitor Diagnostic Settings

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Virtual network subnet for private endpoints when private access is required
- Log Analytics workspace, storage account, Event Hub, or marketplace partner if diagnostics are enabled
- Key Vault key and user-assigned identity when customer-managed encryption is enabled

## Optional Azure services Used (Customer Choice)

- Private DNS zones for `privatelink.azurecr.io`
- Log Analytics Workspace
- Event Hub
- Storage Account
- Key Vault

## Limitations

- Registry name must be globally unique, 5 to 50 alphanumeric characters, and contain only letters or numbers.
- Certain advanced settings are only valid with Premium SKU.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This Terraform module deploys one Azure Container Registry with optional security, monitoring, identity, and private connectivity controls.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azurerm | >= 4, < 5.0.0 |
| azapi | ~> 2.4 |
| modtm | ~> 0.3 |
| random | >= 3.5.0, < 5.0.0 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| mbb_azure_container_registry | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_azure_container_registry) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "container_registry" {
  source = "../../modules/mbb_azure_container_registry/v1.0.0.0"

  name                = "mbbacrshared001"
  location            = "southeastasia"
  resource_group_name = var.resource_group_name
  sku                 = "Premium"

  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  managed_identities = {
    system_assigned = true
  }

  diagnostic_settings = {
    default = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  private_endpoints = {
    registry = {
      subnet_resource_id            = var.private_endpoint_subnet_id
      private_dns_zone_resource_ids = [var.private_dns_zone_id]
    }
  }

  tags = {
    Project = "ContainerPlatform"
  }
}
```

```tfvars
resource_group_name        = "rg-container-platform"
log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/law-platform"
private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/snet-private-endpoints"
private_dns_zone_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
```

Default: `[]`

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

### <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option)

Description: Specifies whether to allow trusted Azure services access to a network restricted Container Registry.  
Possible values are `None` and `AzureServices`. Defaults to `None`.

Type: `string`

Default: `"None"`

### <a name="input_network_rule_set"></a> [network\_rule\_set](#input\_network\_rule\_set)

Description: The network rule set configuration for the Container Registry.  
Requires Premium SKU.

- `default_action` - (Optional) The default action when no rule matches. Possible values are `Allow` and `Deny`. Defaults to `Deny`.
- `ip_rules` - (Optional) A list of IP rules in CIDR format. Defaults to `[]`.
  - `action` - Only "Allow" is permitted
  - `ip_range` - The CIDR block from which requests will match the rule.

Type:

```hcl
object({
    default_action = optional(string, "Deny")
    ip_rule = optional(list(object({
      # since the `action` property only permits `Allow`, this is hard-coded.
      action   = optional(string, "Allow")
      ip_range = string
    })), [])
  })
```

Default: `null`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on the Container Registry. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Container Registry.
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

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Specifies whether public access is permitted.

Type: `bool`

Default: `true`

### <a name="input_quarantine_policy_enabled"></a> [quarantine\_policy\_enabled](#input\_quarantine\_policy\_enabled)

Description: Specifies whether the quarantine policy is enabled.

Type: `bool`

Default: `false`

### <a name="input_retention_policy_in_days"></a> [retention\_policy\_in\_days](#input\_retention\_policy\_in\_days)

Description: If enabled, this retention policy will purge an untagged manifest after a specified number of days.

- `days` - (Optional) The number of days before the policy Defaults to 7 days.

Type: `number`

Default: `7`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

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

### <a name="input_scope_maps"></a> [scope\_maps](#input\_scope\_maps)

Description: A map of scope maps to create on the Container Registry. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `name` - The name of the scope map.
- `actions` - A list of actions that this scope map can perform. Example: "repo/content/read", "repo2/content/delete"
- `description` - The description of the scope map.
- `registry_tokens` - A map of Azure Container Registry token associated to a scope map. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - Specifies the name of the token.
  - `enabled` - Should the Container Registry token be enabled? Defaults to true.
  - `passwords` - The passwords of the token. The first password is required, the second password is optional.
    - `password1` - The first password of the token.
      - `expiry` - The expiry date of the first password. If not specified, the password will not expire.
    - `password2` - The second password of the token.
      - `expiry` - The expiry date of the second password. If not specified, the password will not expire.

Type:

```hcl
map(object({
    name        = string
    actions     = list(string)
    description = optional(string, null)
    registry_tokens = optional(map(object({
      name    = string
      enabled = optional(bool, true)
      passwords = optional(object({
        password1 = object({
          expiry = optional(string)
        })
        password2 = optional(object({
          expiry = optional(string)
        }))
      }))
    })))
  }))
```

Default: `{}`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: The SKU name of the Container Registry. Default is `Premium`. `Possible values are `Basic`, `Standard` and `Premium`.`

Type: `string`

Default: `"Premium"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_zone_redundancy_enabled"></a> [zone\_redundancy\_enabled](#input\_zone\_redundancy\_enabled)

Description: Specifies whether zone redundancy is enabled.  Modifying this forces a new resource to be created.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the parent resource.

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of private endpoints. The map key is the supplied input to var.private\_endpoints. The map value is the entire azurerm\_private\_endpoint resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource id for the parent resource.

### <a name="output_scope_maps"></a> [scope\_maps](#output\_scope\_maps)

Description: A map of scope maps. The map key is the supplied input to var.scope\_maps. The map value is the entire scope map module.  
The scope map module contains the following outputs:
- `id` - The ID of the Container Registry Scope Map.
- `registry_tokens` - The registry token object.
  - `id` - The ID of the Container Registry token.
  - `registry_token_passwords` - The registry token password object.
    - `id` - The ID of the Container Registry token password.
    - `password1` - The first password object of the token.
    - `password2` - The second password object of the token.

### <a name="output_system_assigned_mi_principal_id"></a> [system\_assigned\_mi\_principal\_id](#output\_system\_assigned\_mi\_principal\_id)

Description: The system assigned managed identity principal ID of the parent resource.

## Modules

The following Modules are called:

### <a name="module_scope_maps"></a> [scope\_maps](#module\_scope\_maps)

Source: ./modules/scope-map

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->
