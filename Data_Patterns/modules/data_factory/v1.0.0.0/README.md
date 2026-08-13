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

- Data Integeration Service

## Notable changes in this version

### v1.0.0.0

- This is the initial version to deploy Azure Data Factory Service in Azure and no notable changes for version 1.0.0.0.

## Upgrade Path

- Not Available as it is the initial version

# Product Description

## Overview

- Azure Data Factory is a cloud-based data integration service (PaaS) from Microsoft that helps you move, transform, and orchestrate data from different sources.


## Note

- None

## Network Topology (wherever applicable)

- None

## Azure Service(s) in Scope

- Azure Data Factory

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

- This terraform module creates one `Azure Data Factory`.

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
| Azure Data Factory | [mbb_data_factory](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/user/main/modules/mbb_data_factory/v1.0.0.0) | 1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

```main.tf
module "data_factories" {
  for_each = var.data_factories
  source   = "./modules/mbb_data_factory/v1.0.0.0"

  providers = {
    azurerm = azurerm.dev_myw_sub
  }

  location            = each.value.location
  name                = each.value.name
  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name

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

  region              = try(each.value.region, "")
  description         = try(each.value.description, "")
  notification_emails = try(each.value.notification_emails, [])
  app_id              = try(each.value.app_id, "")
  auto_delete         = try(each.value.auto_delete, "")
  delete_after        = try(each.value.delete_after, "")
  integration_id      = try(each.value.integration_id, "")
  retention           = try(each.value.retention, "")
  experiment_phase    = try(each.value.experiment_phase, "")
  sandbox_type        = try(each.value.sandbox_type, "")
  os                  = try(each.value.os, "")
  patch_policy        = try(each.value.patch_policy, "")
  maintenance_window  = try(each.value.maintenance_window, "")
  last_vm_accessed    = try(each.value.last_vm_accessed, "")

  managed_identities = {
    system_assigned = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = distinct(concat(
      try(each.value.managed_identities.user_assigned_resource_ids, []),
      [for key in try(each.value.umi_keys, []) : module.user_managed_identities[key].resource_id]
    ))
  }

  public_network_enabled           = try(each.value.public_network_enabled, false)
  managed_virtual_network_enabled  = try(each.value.managed_virtual_network_enabled, false)
  customer_managed_key_id          = try(each.value.customer_managed_key_id, null)
  customer_managed_key_identity_id = try(each.value.customer_managed_key_identity_id, null)
  purview_id                       = try(each.value.purview_id, null)

  github_configuration = try(each.value.github_configuration, null)
  vsts_configuration   = try(each.value.vsts_configuration, null)
  global_parameters    = try(each.value.global_parameters, [])
  diagnostic_settings  = try(each.value.diagnostic_settings, {})
  role_assignments     = try(each.value.role_assignments, {})
  lock                 = try(each.value.lock, null)

  linked_service_key_vault                = try(each.value.linked_service_key_vault, {})
  linked_service_azure_blob_storage       = try(each.value.linked_service_azure_blob_storage, {})
  linked_service_azure_file_storage       = try(each.value.linked_service_azure_file_storage, {})
  linked_service_azure_sql_database       = try(each.value.linked_service_azure_sql_database, {})
  linked_service_data_lake_storage_gen2   = try(each.value.linked_service_data_lake_storage_gen2, {})
  linked_service_databricks               = try(each.value.linked_service_databricks, {})
  linked_service_cosmosdb_mongoapi        = try(each.value.linked_service_cosmosdb_mongoapi, {})
  dataset_cosmosdb_mongoapi               = try(each.value.dataset_cosmosdb_mongoapi, {})
  integration_runtime_self_hosted         = try(each.value.integration_runtime_self_hosted, {})
  azure_integration_runtime_azure         = try(each.value.azure_integration_runtime_azure, {})
  credential_service_principal            = try(each.value.credential_service_principal, {})
  credential_user_managed_identity        = try(each.value.credential_user_managed_identity, {})
  private_endpoints_manage_dns_zone_group = try(each.value.private_endpoints_manage_dns_zone_group, true)

  private_endpoints = {
    for pe_key, pe in try(each.value.private_endpoints, {}) : pe_key => {
      name                                    = try(pe.name, null)
      subnet_resource_id                      = data.azurerm_subnet.existing_subnet[pe.subnet_key].id
      private_dns_zone_group_name             = try(pe.private_dns_zone_group_name, "default")
      private_dns_zone_resource_ids           = [for zone_key in try(pe.dns_zone_keys, []) : data.azurerm_private_dns_zone.existing_private_dns_zones[zone_key].id]
      application_security_group_associations = try(pe.application_security_group_associations, {})
      private_service_connection_name         = try(pe.private_service_connection_name, null)
      network_interface_name                  = try(pe.network_interface_name, null)
      location                                = try(pe.location, null)
      resource_group_name                     = try(pe.resource_group_name, null)
      ip_configurations                       = try(pe.ip_configurations, {})
      tags                                    = try(pe.tags, null)
    }
  }

  enable_telemetry = try(each.value.enable_telemetry, true)

  depends_on = [
    module.data_resource_groups,
    module.user_managed_identities,
  ]
}

```

- terraform Variables

```tfvars
data_factories = {
  "mbb-adf-data-dev-myw-01" = {
    location           = "malaysiawest"
    name               = "mbb-adf-data-dev-myw-01"
    resource_group_key = "mbb-rg-dataingestion-dev-myw-01"

    env                = "dev"
    org                = "mbb"
    region_code        = "myw"
    base_name          = ""
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    app_code           = "data"
    bu                 = "it"
    owner              = "CEAT"
    resource_type_code = "adf"
    max_length         = 63
    no_dashes          = false
    add_random         = false
    rnd_length         = 2

    environment         = "Development"
    business_owner      = "Head of Cloud Engineering and Automation"
    business_unit       = "GTD-ISD"
    criticality         = "T1"
    cost_center         = "383-80572"
    data_classification = "Business Sensitive"
    compliance          = "BNM RMIT"
    app_name            = "Azure Data Factory"
    budget_id           = "83254"
    status              = "Live"
    service             = "DataPlatform"

    region              = "MYW"
    description         = "Data Factory dev deployment"
    notification_emails = ["mss_ceat@maybank.com"]

    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = []
    }
    umi_keys = ["mbb-uami-adf-data-dev-myw-01"]

    public_network_enabled          = false
    managed_virtual_network_enabled = false
    enable_telemetry                = true

    private_endpoints = {
      adf_pe = {
        name                        = "mbb-pe-adf-data-dev-myw-01"
        subnet_key                  = "pe_subnet"
        dns_zone_keys               = ["adf"]
        private_dns_zone_group_name = "default"
        network_interface_name      = "mbb-pe-adf-data-dev-myw-01-nic"
      }
    }
    azure_integration_runtime_azure = {
      azure_ir_01 = {
        name     = "mbb-azure-ir-data-dev-myw-01"
        location = "malaysiawest"
      }
    }
    integration_runtime_self_hosted = {
      self_hosted_ir_01 = {
        name     = "mbb-selfhosted-ir-data-dev-myw-01"
        location = "malaysiawest"
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
| name | Specifies the name of the Data Factory | `string` | n/a | yes |
| resource_group_name  | The name of the resource group in which to create the Data Factory| `string` | n/a | yes |
| Location |Specifies the supported Azure location where the resource exists | `string` | n/a | yes |
| github_configuration |Github configuration of Data Factory | `map(string)` | n/a | no |
| global_parameter |Global Parameter of Data Factory | `list(string)` | n/a | no |
| identity |Identity of Data Factory | `map(string)` | n/a | no |
| vsts_configuration |vsts configuration of Data Factory | `map(string)` | n/a | no |
| managed_virtual_network_enabled |managed virtual network of Data Factory | `bool` | n/a | no |
| public_network_enabled  |Public Network Enabled option for Data Factory | `bool` | n/a | no |
| customer_managed_key_id  |Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key (CMK) for double encryption | `string` | n/a | no |
| customer_managed_key_identity_id |Specifies the ID of the user assigned identity associated with the Customer Managed Key. | `string` | n/a | no |
| purview_id  |Specifies the ID of the purview account resource associated with the Data Factory | `string` | n/a | no |
| tags  | A mapping of tags to assign to the resource | `map(string)` | n/a | no |

### Resources

| Name | Type |
|------|------|
| [azurerm_bastion_host.this](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.integration_runtime_self_hosted](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_data_factory.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory) |  resource |
| [azurerm_data_factory_credential_service_principal.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_credential_service_principal) | resource |
| [azurerm_data_factory_credential_user_managed_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_credential_user_managed_identity) | resource |
| [azurerm_data_factory_linked_service_azure_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_azure_blob_storage) | resource |
| [azurerm_data_factory_linked_service_azure_databricks.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_azure_databricks) | resource |
| [azurerm_data_factory_linked_service_azure_file_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_azure_file_storage) | resource |
| [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) | source |
| [azurerm_data_factory_linked_service_azure_sql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_azure_sql_database) | resource |
| [azurerm_data_factory_linked_service_cosmosdb_mongoapi.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_cosmosdb_mongoapi) | resource |
| [azurerm_data_factory_linked_service_data_lake_storage_gen2.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_data_lake_storage_gen2) | resource |
|  [azurerm_data_factory_linked_service_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_linked_service_key_vault) |resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this_managed_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource|
| [azurerm_private_endpoint.this_unmanaged_dns_zone_groups](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
|  [azurerm_private_endpoint_application_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
|  [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) | resource |
| [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
|  [azapi_client_config.telemetry](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/client_config) | data source |
|  [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) | data source |



### Outputs

| Name | Description |
|------|-------------|
| name |The name of the Data Factory resource |
| private_endpoints | The Private Endpoint of the Data Factory resource |
| resource | This is the full output for the resource |
| resource_id | The resource id of the Data Factory resource |


## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure region where this and supporting resources should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_credential_service_principal"></a> [credential\_service\_principal](#input\_credential\_service\_principal)

Description: A map of Azure Data Factory Credentials, where each key represents a unique configuration.  
Each object in the map consists of the following properties:

- `name` - (Required) The unique name of the credential.
- `data_factory_id` - (Required) The ID of the Data Factory where the credential is associated.
- `tenant_id` - (Required) The Tenant ID of the Service Principal.
- `service_principal_id` - (Required) The Client ID of the Service Principal.
- `annotations` - (Optional) A list of tags to annotate the credential.
- `description` - (Optional) A description of the credential.
- `service_principal_key` - (Optional) A block defining the service principal key details.
  - `linked_service_name` - (Required) The name of the Linked Service to use for the Service Principal Key.
  - `secret_name` - (Required) The name of the Secret in the Key Vault.
  - `secret_version` - (Optional) The version of the Secret in the Key Vault.

Type:

```hcl
map(object({
    name                 = string
    data_factory_id      = optional(string)
    tenant_id            = string
    service_principal_id = string
    annotations          = optional(list(string), null)
    description          = optional(string, null)

    service_principal_key = optional(object({
      linked_service_name = string
      secret_name         = string
      secret_version      = optional(string, null)
    }), null)
  }))
```

Default: `{}`

### <a name="input_credential_user_managed_identity"></a> [credential\_user\_managed\_identity](#input\_credential\_user\_managed\_identity)

Description: A map of Azure Data Factory Credentials using User Assigned Managed Identity, where each key represents a unique configuration.  
Each object in the map consists of the following properties:

- `name` - (Required) The unique name of the credential.
- `data_factory_id` - (Required) The ID of the Data Factory where the credential is associated.
- `identity_id` - (Required) The Resource ID of an existing User Assigned Managed Identity. **Attempting to create a Credential resource without first assigning the identity to the parent Data Factory will result in an Azure API error.**
- `annotations` - (Optional) A list of tags to annotate the credential. **Manually altering the resource may cause annotations to be lost.**
- `description` - (Optional) A description of the credential.

Type:

```hcl
map(object({
    name            = string
    data_factory_id = optional(string)
    identity_id     = string
    annotations     = optional(list(string), null)
    description     = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_customer_managed_key_id"></a> [customer\_managed\_key\_id](#input\_customer\_managed\_key\_id)

Description: Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key (CMK). Required with user assigned identity.

Type: `string`

Default: `null`

### <a name="input_customer_managed_key_identity_id"></a> [customer\_managed\_key\_identity\_id](#input\_customer\_managed\_key\_identity\_id)

Description: Specifies the ID of the user assigned identity associated with the Customer Managed Key. Must be supplied if customer\_managed\_key\_id is set.

Type: `string`

Default: `null`

### <a name="input_dataset_cosmosdb_mongoapi"></a> [dataset\_cosmosdb\_mongoapi](#input\_dataset\_cosmosdb\_mongoapi)

Description: A map of Azure Data Factory Datasets for CosmosDB MongoDB API, where each key represents a unique dataset configuration.  
Each object in the map consists of the following properties:

- `name` - (Required) The unique name of the Data Factory Dataset for CosmosDB MongoDB API.
- `linked_service_name` - (Required) The name of the linked service that references the CosmosDB MongoDB API.
- `collection_name` - (Required) The name of the collection in the CosmosDB MongoDB API.
- `annotations` - (Optional) A list of tags that can be used for describing the Dataset.
- `description` - (Optional) A description for the Dataset.
- `folder` - (Optional) The folder name that this dataset is in. If not specified, dataset will appear at the root level.
- `parameters` - (Optional) A map of parameters to associate with the dataset.

Type:

```hcl
map(object({
    name                = string
    linked_service_name = string
    collection_name     = string
    annotations         = optional(list(string))
    description         = optional(string)
    folder              = optional(string)
    parameters          = optional(map(string))
  }))
```

Default: `{}`

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

### <a name="input_github_configuration"></a> [github\_configuration](#input\_github\_configuration)

Description: Defines the GitHub configuration for the Data Factory.
- account\_name: Specifies the GitHub account name.
- branch\_name: Specifies the branch of the repository to get code from.
- git\_url: Specifies the GitHub Enterprise host name. Defaults to https://github.com for open source repositories.
- repository\_name: Specifies the name of the git repository.
- root\_folder: Specifies the root folder within the repository. Set to / for the top level.
- publishing\_enabled: Is automated publishing enabled? Defaults to true.
**You must log in to the Data Factory management UI to complete the authentication to the GitHub repository.**

Type:

```hcl
object({
    account_name       = string
    branch_name        = string
    git_url            = optional(string, null)
    repository_name    = string
    root_folder        = string
    publishing_enabled = optional(bool, true)
  })
```

Default: `null`

### <a name="input_global_parameters"></a> [global\_parameters](#input\_global\_parameters)

Description: Defines a list of global parameters for the Data Factory.
- name: Specifies the global parameter name.
- type: Specifies the global parameter type. Possible values: Array, Bool, Float, Int, Object, or String.
- value: Specifies the global parameter value.
**For type Array and Object, it is recommended to use jsonencode() for the value.**

Type:

```hcl
list(object({
    name  = string
    type  = string
    value = any
  }))
```

Default: `[]`

### <a name="input_integration_runtime_self_hosted"></a> [integration\_runtime\_self\_hosted](#input\_integration\_runtime\_self\_hosted)

Description: A map of Azure Data Factory Self-hosted Integration Runtimes, where each key represents a unique configuration. Each object in the map consists of the following properties:

- `data_factory_id` - (Required) The ID of the Data Factory where the integration runtime is associated.
- `name` - (Required) The unique name of the integration runtime. Changing this forces a new resource to be created.
- `description` - (Optional) A description of the integration runtime.
- `self_contained_interactive_authoring_enabled` - (Optional) Specifies whether to enable interactive authoring when the self-hosted integration runtime cannot establish a connection with Azure Relay.
- `rbac_authorization` - (Optional) Defines RBAC authorization settings. Changing this forces a new resource to be created.
  - `resource_id` - (Required) The resource identifier of the integration runtime to be shared.
  - `credential_name` - (Optional) The name of the credential to use for the Managed Integration Runtime.
  **Note:** RBAC Authorization creates a linked Self-hosted Integration Runtime targeting the Shared Self-hosted Integration Runtime in `resource_id`. The linked Self-hosted Integration Runtime requires Contributor access to the Shared Self-hosted Data Factory.

Type:

```hcl
map(object({
    data_factory_id                              = optional(string)
    name                                         = string
    description                                  = optional(string, null)
    self_contained_interactive_authoring_enabled = optional(bool, true)
    rbac_authorization = optional(object({
      credential_name = optional(string)
      resource_id     = string
    }), null)
  }))
```

Default: `{}`

### <a name="input_linked_service_azure_blob_storage"></a> [linked\_service\_azure\_blob\_storage](#input\_linked\_service\_azure\_blob\_storage)

Description: A map of Azure Blob Storage linked services, where each key represents a unique linked service configuration. Each object in the map consists of the following properties:

- `name` - (Required) Specifies the name of the Azure Data Factory Linked Service.
- `description` - (Optional) A description for the linked service.
- `integration_runtime_name` - (Optional) The integration runtime reference associated with the linked service.
- `annotations` - (Optional) A list of annotations (tags) for additional metadata.
- `parameters` - (Optional) A map of parameters to associate with the linked service.
- `additional_properties` - (Optional) Additional custom properties for the linked service.
### Authentication Options (Only one can be set):
- `connection_string` - (Optional) The secure connection string for the storage account. **Conflicts with** `connection_string_insecure`, `sas_uri`, and `service_endpoint`.
- `connection_string_insecure` - (Optional) The connection string sent insecurely. **Conflicts with** `connection_string`, `sas_uri`, and `service_endpoint`.
- `sas_uri` - (Optional) The Shared Access Signature (SAS) URI for authentication. **Conflicts with** `connection_string`, `connection_string_insecure`, and `service_endpoint`.
- `service_endpoint` - (Optional) The Service Endpoint for direct connectivity. **Conflicts with** `connection_string`, `connection_string_insecure`, and `sas_uri`.
### Identity Options:
- `use_managed_identity` - (Optional) Whether to use a managed identity for authentication.
- `service_principal_id` - (Optional) The service principal ID for authentication.
- `service_principal_key` - (Optional) The service principal key (password) for authentication.
- `tenant_id` - (Optional) The tenant ID for authentication.
### Storage Options:
- `storage_kind` - (Optional) The kind of storage account. Allowed values: `Storage`, `StorageV2`, `BlobStorage`, `BlockBlobStorage`.
### Key Vault Options:
- `key_vault_sas_token` - (Optional) A Key Vault SAS Token object containing:
  - `linked_service_name` - The name of the existing Key Vault Linked Service.
  - `secret_name` - The name of the secret in Azure Key Vault that stores the SAS token.
- `service_principal_linked_key_vault_key` - (Optional) A Key Vault object for storing the Service Principal Key:
  - `linked_service_name` - The name of the existing Key Vault Linked Service.
  - `secret_name` - The name of the secret in Azure Key Vault that stores the Service Principal Key.

Type:

```hcl
map(object({
    name                       = string
    description                = optional(string, null)
    integration_runtime_name   = optional(string, null)
    annotations                = optional(list(string), null)
    parameters                 = optional(map(string), null)
    additional_properties      = optional(map(string), null)
    connection_string          = optional(string, null)
    connection_string_insecure = optional(string, null)
    sas_uri                    = optional(string, null)
    service_endpoint           = optional(string, null)
    use_managed_identity       = optional(bool, null)
    service_principal_id       = optional(string, null)
    service_principal_key      = optional(string, null)
    storage_kind               = optional(string, null)
    tenant_id                  = optional(string, null)

    # Key Vault SAS Token (Optional)
    key_vault_sas_token = optional(object({
      linked_service_name = string
      secret_name         = string
    }), null)

    # Service Principal Linked Key Vault Key (Optional)
    service_principal_linked_key_vault_key = optional(object({
      linked_service_name = string
      secret_name         = string
    }), null)
  }))
```

Default: `{}`

### <a name="input_linked_service_azure_file_storage"></a> [linked\_service\_azure\_file\_storage](#input\_linked\_service\_azure\_file\_storage)

Description: A map of Azure Data Factory Linked Services for Azure File Storage, where each key represents a unique configuration.  
Each object in the map consists of the following properties:

- `name` - (Required) The unique name of the linked service.
- `data_factory_id` - (Required) The ID of the Data Factory where the linked service is associated.
- `description` - (Optional) A description of the linked service.
- `host` - (Optional) The Host name of the server.
- `integration_runtime_name` - (Optional) The integration runtime reference.
- `annotations` - (Optional) A list of tags to annotate the linked service.
- `parameters` - (Optional) A map of parameters.
- `password` - (Optional) The password to log in to the server.
- `user_id` - (Optional) The user ID to log in to the server.
- `additional_properties` - (Optional) Additional custom properties.
- `connection_string` - (Required) The connection string.
- `file_share` - (Optional) The name of the file share.

### Key Vault Password Block:
- `key_vault_password` - (Optional) Use an existing Key Vault to store the Azure File Storage password.
  - `linked_service_name` - (Required) The name of the Key Vault Linked Service.
  - `secret_name` - (Required) The secret storing the Azure File Storage password.

Type:

```hcl
map(object({
    name                     = string
    data_factory_id          = optional(string)
    description              = optional(string, null)
    host                     = optional(string, null)
    integration_runtime_name = optional(string, null)
    annotations              = optional(list(string), null)
    parameters               = optional(map(string), null)
    password                 = optional(string, null)
    user_id                  = optional(string, null)
    additional_properties    = optional(map(string), null)
    connection_string        = string
    file_share               = optional(string, null)
    key_vault_password = optional(object({
      linked_service_name = string
      secret_name         = string
    }), null)
  }))
```

Default: `{}`

### <a name="input_linked_service_azure_sql_database"></a> [linked\_service\_azure\_sql\_database](#input\_linked\_service\_azure\_sql\_database)

Description: A map of Azure Data Factory Linked Services for Azure SQL Database, where each key represents a unique configuration.  
Each object in the map consists of the following properties:

- `name` - (Required) The unique name of the linked service.
- `data_factory_id` - (Required) The ID of the Data Factory where the linked service is associated.
- `connection_string` - (Optional) The connection string used to authenticate with Azure SQL Database. **Exactly one of** `connection_string` **or** `key_vault_connection_string` **must be specified.**
- `use_managed_identity` - (Optional) Whether to use the Data Factory's managed identity for authentication. **Incompatible with** `service_principal_id` **and** `service_principal_key`.
- `service_principal_id` - (Optional) The service principal ID for authentication. **Required if** `service_principal_key` **is set.**
- `service_principal_key` - (Optional) The service principal key (password) for authentication. **Required if** `service_principal_id` **is set.**
- `tenant_id` - (Optional) The tenant ID for authentication.
- `description` - (Optional) A description of the linked service.
- `integration_runtime_name` - (Optional) The integration runtime reference.
- `annotations` - (Optional) A list of tags to annotate the linked service.
- `parameters` - (Optional) A map of parameters.
- `additional_properties` - (Optional) Additional custom properties.
- `credential_name` - (Optional) The name of a User-assigned Managed Identity for authentication.
- `key_vault_connection_string` - (Optional) Use an existing Key Vault to store the Azure SQL Database connection string.
  - `linked_service_name` - (Required) The name of the Key Vault Linked Service.
  - `secret_name` - (Required) The secret storing the SQL Server connection string.
- `key_vault_password` - (Optional) Use an existing Key Vault to store the Azure SQL Database password.
  - `linked_service_name` - (Required) The name of the Key Vault Linked Service.
  - `secret_name` - (Required) The secret storing the SQL Server password.

Type:

```hcl
map(object({
    name                     = string
    data_factory_id          = optional(string)
    connection_string        = optional(string, null)
    use_managed_identity     = optional(bool, null)
    service_principal_id     = optional(string, null)
    service_principal_key    = optional(string, null)
    tenant_id                = optional(string, null)
    description              = optional(string, null)
    integration_runtime_name = optional(string, null)
    annotations              = optional(list(string), null)
    parameters               = optional(map(string), null)
    additional_properties    = optional(map(string), null)
    credential_name          = optional(string, null)

    key_vault_connection_string = optional(object({
      linked_service_name = string
      secret_name         = string
    }), null)

    key_vault_password = optional(object({
      linked_service_name = string
      secret_name         = string
    }), null)
  }))
```

Default: `{}`

### <a name="input_linked_service_cosmosdb_mongoapi"></a> [linked\_service\_cosmosdb\_mongoapi](#input\_linked\_service\_cosmosdb\_mongoapi)

Description: A map of CosmosDB MongoDB API linked services, where each key represents a unique linked service configuration. Each object in the map consists of the following properties:

- `name` - (Required) Specifies the name of the Data Factory Linked Service.
- `connection_string` - (Optional) The connection string to the CosmosDB MongoDB API.
- `database` - (Optional) The name of the database in the CosmosDB MongoDB API.

Type:

```hcl
map(object({
    name              = string
    connection_string = optional(string)
    database          = optional(string)
  }))
```

Default: `{}`

### <a name="input_linked_service_data_lake_storage_gen2"></a> [linked\_service\_data\_lake\_storage\_gen2](#input\_linked\_service\_data\_lake\_storage\_gen2)

Description: A map of Azure Data Factory Linked Services for Data Lake Storage Gen2, where each key represents a unique configuration.  
Each object in the map consists of the following properties:

- `name` - (Required) The unique name of the linked service.
- `data_factory_id` - (Required) The ID of the Data Factory where the linked service is associated.
- `description` - (Optional) A description of the linked service.
- `integration_runtime_name` - (Optional) The integration runtime reference.
- `annotations` - (Optional) A list of tags to annotate the linked service.
- `parameters` - (Optional) A map of parameters.
- `additional_properties` - (Optional) Additional custom properties.
- `url` - (Required) The endpoint for the Azure Data Lake Storage Gen2 service.

### Authentication Options (Only one can be set):
- `storage_account_key` - (Optional) The Storage Account Key used for authentication. **Incompatible with** `service_principal_id`, `service_principal_key`, `tenant`, and `use_managed_identity`.
- `use_managed_identity` - (Optional) Whether to use the Data Factory's managed identity for authentication. **Incompatible with** `service_principal_id`, `service_principal_key`, `tenant`, and `storage_account_key`.
- `service_principal_id` - (Optional) The service principal ID used for authentication. **Incompatible with** `storage_account_key` and `use_managed_identity`.
- `service_principal_key` - (Optional) The service principal key used for authentication. **Required if** `service_principal_id` **is set.**
- `tenant` - (Optional) The tenant ID where the service principal exists. **Required if** `service_principal_id` **is set.**

Type:

```hcl
map(object({
    name                     = string
    data_factory_id          = optional(string)
    description              = optional(string, null)
    integration_runtime_name = optional(string, null)
    annotations              = optional(list(string), null)
    parameters               = optional(map(string), null)
    additional_properties    = optional(map(string), null)
    url                      = string
    storage_account_key      = optional(string, null)
    use_managed_identity     = optional(bool, null)
    service_principal_id     = optional(string, null)
    service_principal_key    = optional(string, null)
    tenant                   = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_linked_service_databricks"></a> [linked\_service\_databricks](#input\_linked\_service\_databricks)

Description: A map of Azure Data Factory Linked Services for Databricks, where each key represents a unique configuration.  
Each object in the map consists of the following properties:

- `adb_domain` - (Required) The domain URL of the Databricks instance.
- `data_factory_id` - (Required) The ID of the Data Factory where the linked service is associated.
- `name` - (Required) The unique name of the linked service.
- `additional_properties` - (Optional) Additional custom properties.
- `annotations` - (Optional) A list of tags to annotate the linked service.
- `description` - (Optional) A description of the linked service.
- `integration_runtime_name` - (Optional) The integration runtime reference.
- `parameters` - (Optional) A map of parameters.

### Authentication Options (Only one can be set):
- `access_token` - (Optional) Authenticate to Databricks via an access token.
- `key_vault_password` - (Optional) Authenticate via Azure Key Vault.
  - `linked_service_name` - (Required) Name of the Key Vault Linked Service.
  - `secret_name` - (Required) The secret storing the access token.
- `msi_work_space_resource_id` - (Optional) Authenticate via managed service identity.

### Cluster Integration Options (Only one can be set):
- `existing_cluster_id` - (Optional) The ID of an existing cluster.
- `instance_pool` - (Optional) Use an instance pool. This requires a nested `instance_pool` block.
  - `instance_pool_id` - (Required) The identifier of the instance pool.
  - `cluster_version` - (Required) The Spark version.
  - `min_number_of_workers` - (Optional) Minimum worker nodes (default: 1).
  - `max_number_of_workers` - (Optional) Maximum worker nodes.
- `new_cluster_config` - (Optional) Create a new cluster.
  - `cluster_version` - (Required) Spark version.
  - `node_type` - (Required) Node type.
  - `driver_node_type` - (Optional) Driver node type.
  - `max_number_of_workers` - (Optional) Max workers.
  - `min_number_of_workers` - (Optional) Min workers (default: 1).
  - `spark_config` - (Optional) Key-value pairs for Spark configuration.
  - `spark_environment_variables` - (Optional) Spark environment variables.
  - `custom_tags` - (Optional) Tags for the cluster.
  - `init_scripts` - (Optional) Initialization scripts.
  - `log_destination` - (Optional) Log storage location.

Type:

```hcl
map(object({
    adb_domain                 = string
    data_factory_id            = optional(string)
    name                       = string
    additional_properties      = optional(map(string), null)
    annotations                = optional(list(string), null)
    description                = optional(string, null)
    integration_runtime_name   = optional(string, null)
    parameters                 = optional(map(string), null)
    access_token               = optional(string, null)
    msi_work_space_resource_id = optional(string, null)
    key_vault_password = optional(object({
      linked_service_name = string
      secret_name         = string
    }), null)
    existing_cluster_id = optional(string, null)
    instance_pool = optional(object({
      instance_pool_id      = string
      cluster_version       = string
      min_number_of_workers = optional(number, 1)
      max_number_of_workers = optional(number, null)
    }), null)
    new_cluster_config = optional(object({
      cluster_version             = string
      node_type                   = string
      driver_node_type            = optional(string, null)
      max_number_of_workers       = optional(number, null)
      min_number_of_workers       = optional(number, 1)
      spark_config                = optional(map(string), null)
      spark_environment_variables = optional(map(string), null)
      custom_tags                 = optional(map(string), null)
      init_scripts                = optional(list(string), null)
      log_destination             = optional(string, null)
    }), null)
  }))
```

Default: `{}`

### <a name="input_linked_service_key_vault"></a> [linked\_service\_key\_vault](#input\_linked\_service\_key\_vault)

Description: A map of Azure Data Factory Linked Services for Azure Key Vault, where each key represents a unique configuration.  
Each object in the map consists of the following properties:

- `name` - (Required) The unique name of the linked service.
- `data_factory_id` - (Required) The ID of the Data Factory where the linked service is associated.
- `key_vault_id` - (Required) The ID of the Azure Key Vault resource.
- `description` - (Optional) A description of the linked service.
- `integration_runtime_name` - (Optional) The integration runtime reference.
- `annotations` - (Optional) A list of tags to annotate the linked service.
- `parameters` - (Optional) A map of parameters.
- `additional_properties` - (Optional) Additional custom properties.

Type:

```hcl
map(object({
    name                     = string
    data_factory_id          = optional(string)
    key_vault_id             = string
    description              = optional(string, null)
    integration_runtime_name = optional(string, null)
    annotations              = optional(list(string), null)
    parameters               = optional(map(string), null)
    additional_properties    = optional(map(string), null)
  }))
```

Default: `{}`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Example Input:
```hcl
lock = {
  kind = "CanNotDelete"
  name = "Delete"
}
```

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

Example Input:

```hcl
managed_identities = {
  system_assigned = true
}
```

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_managed_virtual_network_enabled"></a> [managed\_virtual\_network\_enabled](#input\_managed\_virtual\_network\_enabled)

Description: Is Managed Virtual Network enabled?

Type: `bool`

Default: `false`

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

Example Input:

```hcl
private_endpoints = {
  endpoint1 = {
    subnet_resource_id            = azurerm_subnet.endpoint.id
    private_dns_zone_group_name   = "private-dns-zone-group"
    private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
  }
}
```

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

Description: Default to true. Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.

Type: `bool`

Default: `true`

### <a name="input_public_network_enabled"></a> [public\_network\_enabled](#input\_public\_network\_enabled)

Description: Is the Data Factory visible to the public network?

Type: `bool`

Default: `true`

### <a name="input_purview_id"></a> [purview\_id](#input\_purview\_id)

Description: Specifies the ID of the purview account resource associated with the Data Factory.

Type: `string`

Default: `null`

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

Example Input:

```hcl
role_assignments = {
  deployment_user_contributor = {
    role_definition_id_or_name = "Contributor"
    principal_id               = data.azurerm_client_config.current.client_id
  }
}
```

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

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `null`

### <a name="input_vsts_configuration"></a> [vsts\_configuration](#input\_vsts\_configuration)

Description: Defines the VSTS configuration for the Data Factory.
- account\_name: Specifies the VSTS account name.
- branch\_name: Specifies the branch of the repository to get code from.
- project\_name: Specifies the name of the VSTS project.
- repository\_name: Specifies the name of the git repository.
- root\_folder: Specifies the root folder within the repository. Set to / for the top level.
- tenant\_id: Specifies the Tenant ID associated with the VSTS account.
- publishing\_enabled: Is automated publishing enabled? Defaults to true.

Type:

```hcl
object({
    account_name       = string
    branch_name        = string
    project_name       = string
    repository_name    = string
    root_folder        = string
    tenant_id          = string
    publishing_enabled = optional(bool, true)
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Data Factory resource

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of private endpoints. The map key is the supplied input to var.private\_endpoints. The map value is the entire azurerm\_private\_endpoint resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource id of the Data Factory resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->