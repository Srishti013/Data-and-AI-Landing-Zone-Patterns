[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0 |
| Created By | Sandeep B R |
| Reviewed By|  |

# About this product version

## Product State: Released

## Product Category

- AI Services

## Notable changes in this version

### v1.0.0.0

- This is the Initial version to deploy Azure AI Search Service in Azure and no notable changes for version 1.0.0.0.

## Upgrade Path

- Not Available as it is the initial version

# Product Description

## Overview

- Azure AI Search is a fully managed, cloud-hosted service that connects your data to AI. The service unifies access to enterprise and web content so agents and LLMs can use context, chat history, and multi-source signals to produce reliable, grounded answers.


## Note

- None

## Network Topology (wherever applicable)

- None

## Azure Service(s) in Scope

- Azure AI Search

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

- This terraform module creates one `Azure AI Search`.

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
| Azure AI Search | [mbb_ai_search](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/user/main/modules/mbb_ai_search/v1.0.0.0) | 1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

```main.tf
module "ai_search_service" {
  for_each = var.search_services

  providers = {
    azurerm = azurerm.dev_myw_sub
  }

  source             = "./modules/mbb_ai_search/v1.0.0.0"
  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  owner              = each.value.owner
  app_code           = each.value.app_code
  bu                 = each.value.bu
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

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  sku                           = each.value.sku
  public_network_access_enabled = each.value.public_network_access_enabled
  local_authentication_enabled  = each.value.local_authentication_enabled
  enable_telemetry              = each.value.enable_telemetry
  allowed_ips                   = lookup(each.value, "allowed_ips", null)

  managed_identities = {
    system_assigned = each.value.managed_identities.system_assigned
    user_assigned_resource_ids = [
      module.user_managed_identities[each.value.umi_key].resource_id
    ]
  }
  private_endpoints = {
    for pe_key, pe_config in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name = pe_config.name

      subnet_resource_id = data.azurerm_subnet.existing_subnets[pe_config.subnet_key].id

      subresource_name = pe_config.subresource_name

      network_interface_name = lookup(pe_config, "network_interface_name", null)

      private_dns_zone_resource_ids = length(lookup(pe_config, "dns_zone_keys", [])) > 0 ? [
        for dns_key in pe_config.dns_zone_keys :
        data.azurerm_private_dns_zone.existing_private_dns_zones[dns_key].id
      ] : []
    }
  }


  tags = lookup(each.value, "tags", null)

  depends_on = [module.ai_resource_group]
}
```

- terraform Variables

```tfvars
search_services = {
  "mbb-srch-dev-myw-01" = {
    env                = "dev"
    org                = "mbb"
    region_code        = "myw"
    base_name          = ""
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    owner              = "CEAT"
    app_code           = "espi"
    bu                 = "it"
    resource_type_code = "srch"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Business Tags
    app_name            = "AI Base Infrastructure"
    app_support         = "mss_ceat@maybank.com"
    business_unit       = "GTD-ISD"
    business_owner      = "Head of Cloud Engineering and Automation"
    type                = "Development"
    cost_center         = "383-80572"
    data_classification = "Business Sensitive"
    compliance          = "BNM RMIT"
    app_id              = "MBB-MYW-NET01-00001"

    # Mandatory DevOps Tags
    product_name    = "mbb_ai_search"
    product_version = "1.0.0.0"

    # Mandatory Finance Tags
    cost_allocation_unit = "TBD"
    budget_id            = "83254"

    # Mandatory Operation Tags
    criticality = "T1"
    environment = "Development"
    status      = "Live"
    service     = "ai-search-service"

    # Optional Tags
    description         = "Base Infra AI Search for development environment"
    region              = "MYW"
    notification_emails = ["mss_ceat@maybank.com"]
    role_assignments    = {}
    additional_tags     = {}


    # name                          = "mbb-xxxx"
    # location                      = "southeastasia"
    rg_key                        = "mbb-xxx"
    umi_key                       = "mbb-xxx"
    resource_group_name           = "mbb-xxx"
    sku                           = "standard"
    public_network_access_enabled = false
    local_authentication_enabled  = false
    enable_telemetry              = true

    managed_identities = {
      system_assigned = true
    }
    private_endpoints = {
      "mbb-pe-srch-dev-myw-01" = {
        name                   = "mbb-xxxx"
        vnet_key               = "mbb-xxxx"
        subnet_key             = "mbb-sxxx"
        subresource_name       = "searchService"
        dns_zone_keys          = ["search-zone"]
        network_interface_name = "mbb-xxx"
      }
    }

    allowed_ips = []

    tags = {
      environment = "dev"
      workload    = "ai"
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
| location  | The Azure Region where the Search Service should exist | `string` | n/a | yes |
| name| The Name which should be used for this Search Service | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group where the Search Service should exist | `string` | n/a | yes |
| sku | The SKU which should be used for this Search Service | `string` | n/a | yes |
| allowed_ips | Specifies a list of inbound IPv4 or CIDRs that are allowed to access the Search Service | `list(string)` | n/a | no |
| authentication_failure_mode | Specifies the response that the Search Service should return for requests that fail authentication | `string` | n/a | no |
| customer_managed_key_enforcement_enabled  | Specifies whether the Search Service should enforce that non-customer resources are encrypted | `bool` | n/a | no |
| hosting_mode  | Specifies the Hosting Mode, which allows for High Density partitions (that allow for up to 1000 indexes) should be supported | `string` | n/a | no |
| identity   | Identity of the AI Search | `string` | n/a | no |
| local_authentication_enabled   | Specifies whether the Search Service allows authenticating using API Keys | `bool` | n/a | no |
| network_rule_bypass_option | Whether to allow trusted Azure services to access a network restricted Search Service | `string` | n/a | no |
| partition_count | Specifies the number of partitions which should be created.  | `number` | n/a | no |
| public_network_access_enabled  | Specifies whether Public Network Access is allowed for this resource  | `bool` | n/a | no |
| replica_count | Specifies whether Public Network Access is allowed for this resource  | `number` | n/a | no |
| semantic_search_sku | Specifies whether Public Network Access is allowed for this resource  | `string` | n/a | no |
| tags | Specifies a mapping of tags which should be assigned to this Search Service  | `map(string)` | n/a | no |


### Resources

| Name | Type |
|------|------|
| [azurerm_bastion_host.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | data resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) |  source |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource) | source |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | source |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | source |
| [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | source |
| [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) | source |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | source |



### Outputs

| Name | Description |
|------|-------------|
| private_endpoints | The PE of the AI Search |
| resource | The resource of AI Search |
| resource_id | The Resource ID of the AI Search|


## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: (Required) Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) The name of the this resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: (Required) The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips)

Description: One or more IP Addresses, or CIDR Blocks which should be able to access the AI Search service

Type: `list(string)`

Default: `null`

### <a name="input_authentication_failure_mode"></a> [authentication\_failure\_mode](#input\_authentication\_failure\_mode)

Description: (Optional) Specifies the response that the Search Service should return for requests that fail authentication. Possible values include `http401WithBearerChallenge` or `http403`.

Type: `string`

Default: `null`

### <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key)

Description: A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.

Type:

```hcl
object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
```

Default: `null`

### <a name="input_customer_managed_key_enforcement_enabled"></a> [customer\_managed\_key\_enforcement\_enabled](#input\_customer\_managed\_key\_enforcement\_enabled)

Description: (Optional) Specifies whether the Search Service should enforce that non-customer resources are encrypted. Defaults to `false`.

Type: `bool`

Default: `null`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description:   A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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

### <a name="input_hosting_mode"></a> [hosting\_mode](#input\_hosting\_mode)

Description: (Optional) Specifies the Hosting Mode, which allows for High Density partitions (that allow for up to 1000 indexes) should be supported. Possible values are `highDensity` or `default`. Defaults to `default`. Changing this forces a new Search Service to be created.

Type: `string`

Default: `null`

### <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled)

Description: (Optional) Specifies whether the Search Service allows authenticating using API Keys? Defaults to `true`.

Type: `bool`

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

### <a name="input_network_rule_bypass_option"></a> [network\_rule\_bypass\_option](#input\_network\_rule\_bypass\_option)

Description: (Optional) Whether to allow trusted Azure services to access a network restricted Container Registry. Possible values are None and AzureServices. Defaults to None.

Type: `string`

Default: `"None"`

### <a name="input_partition_count"></a> [partition\_count](#input\_partition\_count)

Description: Partitions allow for scaling of document count as well as faster indexing by sharding your index over multiple search units.

Type: `number`

Default: `1`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Key Vault.
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

Description: This variable controls whether or not public network access is enabled for the module.

Type: `bool`

Default: `true`

### <a name="input_replica_count"></a> [replica\_count](#input\_replica\_count)

Description: Replicas distribute search workloads across the service. You need at least two replicas to support high availability of query workloads (not applicable to the free tier).

Type: `number`

Default: `1`

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

### <a name="input_semantic_search_sku"></a> [semantic\_search\_sku](#input\_semantic\_search\_sku)

Description: (Optional) Specifies the Semantic Search SKU which should be used for this Search Service. Possible values include `free` and `standard`.

Type: `string`

Default: `null`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: (Required) The pricing tier of the search service you want to create (for example, basic or standard).

Type: `string`

Default: `"standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of private endpoints. The map key is the supplied input to var.private\_endpoints. The map value is the entire azurerm\_private\_endpoint resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The ID of the machine learning workspace.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->