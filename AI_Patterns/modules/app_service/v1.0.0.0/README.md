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

- Initial version to deploy Azure App Service workloads (`app_service`).

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This Terraform module deploys Azure App Service workloads for `webapp`, `functionapp`, and `logicapp` scenarios.
- It supports Windows and Linux workloads, deployment slots, private endpoints, custom domains, authentication settings, diagnostic settings, managed identities, application settings, connection strings, certificates, and optional Application Insights integration.
- Naming and location are derived from the naming module rather than direct `name` and `location` inputs.

## Note

- `kind` must be one of `functionapp`, `webapp`, or `logicapp`.
- `os_type` must be `Linux` or `Windows`.
- This module expects an existing App Service Plan via `service_plan_resource_id`.

## Network Topology (wherever applicable)

- Hub/spoke with private endpoint connectivity and centralized private DNS is recommended for production workloads.
- Public access, private endpoint access, and slot-specific private endpoints are supported depending on configuration.

## Azure Service(s) in Scope

- Azure App Service
- Azure Function App
- Azure Logic App Standard
- Private Endpoint
- Azure Application Insights

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Existing App Service Plan
- Subnet(s) for Private Endpoint, if private access is required

## Optional Azure services Used (Customer Choice)

- Azure Application Insights
- Azure DNS Zones for custom domains
- Azure Key Vault for certificates and secrets

## Limitations

- The deployed runtime resource depends on the combination of `kind`, `os_type`, and function-app Flex Consumption settings.
- Some configuration blocks are only valid for specific workload types, operating systems, or slot scenarios.
- The module interface is extensive; consumers should keep inputs limited to the selected workload pattern.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- This module creates one App Service workload and can optionally configure deployment slots, private endpoints, App Insights, diagnostics, custom domains, authentication, and resource locks.

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
| app_service | [IAC link](https://github.com/your-org/iac-modules/tree/main/modules/app_service) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "app_service" {
  source = "../../modules/app_service/v1.0.0.0"

  # Required workload parameters
  kind                     = var.kind
  os_type                  = var.os_type
  resource_group_name      = var.resource_group_name
  service_plan_resource_id = var.service_plan_resource_id

  # Common workload configuration
  app_settings        = var.app_settings
  connection_strings  = var.connection_strings
  diagnostic_settings = var.diagnostic_settings
  private_endpoints   = var.private_endpoints

  # Optional Application Insights
  application_insights = var.application_insights

  # Naming module required variables
  env                = var.env
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  business_owner     = var.business_owner
  resource_type_code = var.resource_type_code

  # Mandatory tags
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
kind                     = "webapp"
os_type                  = "Linux"
resource_group_name      = "rg-app-sea-001"
service_plan_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.Web/serverfarms/asp-sea-001"

app_settings = {
  WEBSITE_RUN_FROM_PACKAGE = "1"
}

connection_strings  = {}
diagnostic_settings = {}
private_endpoints   = {}

application_insights = {}

env                = "tst"
au                 = "00121"
app_code           = "sample"
bu                 = "it"
owner              = "CEAT"
business_owner     = "Platform Owner"
resource_type_code = "app"

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
| kind | App Service workload type: `functionapp`, `webapp`, or `logicapp` | `string` | n/a | yes |
| os_type | Operating system for the workload: `Linux` or `Windows` | `string` | n/a | yes |
| resource_group_name | Resource group where the workload is deployed | `string` | n/a | yes |
| service_plan_resource_id | Existing App Service Plan resource ID | `string` | n/a | yes |
| app_settings | Map of app settings | `map(string)` | `{}` | no |
| application_insights | Optional Application Insights configuration object | `object` | `{}` | no |
| auth_settings | Authentication settings (legacy auth model) | `map(object)` | `{}` | no |
| auth_settings_v2 | Authentication settings v2 | `map(object)` | `{}` | no |
| auto_heal_setting | Auto-heal configuration | `map(object)` | `{}` | no |
| backup | Backup configuration | `map(object)` | `{}` | no |
| builtin_logging_enabled | Enable built-in logging | `bool` | `true` | no |
| client_affinity_enabled | Enable client affinity | `bool` | `false` | no |
| client_certificate_enabled | Enable client certificate | `bool` | `false` | no |
| connection_strings | Map of connection strings | `map(object)` | `{}` | no |
| custom_domains | Custom domain and certificate configuration | `map(object)` | `{}` | no |
| app_service_active_slot | Active slot configuration | `object` | `null` | no |
| deployment_slots | Deployment slot configuration | `map(object)` | module-defined | no |
| diagnostic_settings | Diagnostic settings map | `map(object)` | module-defined | no |
| managed_identities | Managed identity configuration | `object` | module-defined | no |
| private_endpoints | Private endpoint configuration map | `map(object)` | module-defined | no |
| private_endpoints_manage_dns_zone_group | Whether to manage private DNS zone groups | `bool` | module-defined | no |
| all_child_resources_inherit_lock | Child resources inherit parent lock | `bool` | `true` | no |
| all_child_resources_inherit_tags | Child resources inherit parent tags | `bool` | `true` | no |
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

### Resources

| Name | Type |
|------|------|
| azurerm_windows_web_app.this | resource |
| azurerm_linux_web_app.this | resource |
| azurerm_windows_web_app_slot.this | resource |
| azurerm_linux_web_app_slot.this | resource |
| azurerm_web_app_active_slot.this | resource |
| azurerm_windows_function_app.this | resource |
| azurerm_linux_function_app.this | resource |
| azurerm_function_app_flex_consumption.this | resource |
| azurerm_windows_function_app_slot.this | resource |
| azurerm_linux_function_app_slot.this | resource |
| azurerm_function_app_active_slot.this | resource |
| azurerm_logic_app_standard.this | resource |
| azurerm_application_insights.this | resource |
| azurerm_application_insights.slot | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_private_endpoint.this_unmanaged_dns_zone_groups | resource |
| azurerm_private_endpoint.slot | resource |
| azurerm_private_endpoint.slot_this_unmanaged_dns_zone_groups | resource |
| azurerm_private_endpoint_application_security_group_association.this | resource |
| azurerm_private_endpoint_application_security_group_association.slot | resource |
| azurerm_app_service_certificate.this | resource |
| azurerm_dns_cname_record.this | resource |
| azurerm_dns_txt_record.this | resource |
| azurerm_app_service_custom_hostname_binding.this | resource |
| azurerm_app_service_slot_custom_hostname_binding.slot | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_role_assignment.this | resource |
| azurerm_role_assignment.pe | resource |
| azurerm_role_assignment.slot | resource |
| azurerm_role_assignment.slot_pe | resource |
| azurerm_management_lock.this | resource |
| azurerm_management_lock.pe | resource |
| azurerm_management_lock.slot | resource |
| random_uuid.telemetry | resource |
| modtm_telemetry.telemetry | resource |

### Outputs

| Name | Description |
|------|-------------|
| application_insights | Application Insights resource created by the module |
| function_app_active_slot | Active function app slot ID |
| function_app_deployment_slots | Function app deployment slot resources |
| identity_principal_id | Principal ID of the deployed resource identity |
| kind | Deployed workload kind |
| location | Resolved location from naming module |
| name | Deployed resource name |
| os_type | Operating system type |
| resource | Full deployed resource object |
| resource_id | Deployed resource ID |
| resource_private_endpoints | Map of private endpoint resources |
| resource_uri | Default hostname of the deployed resource |
| resource_lock | Resource lock objects |
| private_endpoint_locks | Private endpoint lock objects |
| deployment_slot_locks | Deployment slot lock objects |
| system_assigned_mi_principal_id | System-assigned managed identity principal ID |
| system_assigned_mi_principal_id_slots | Slot managed identity principal IDs |
| thumbprints | Certificate thumbprint resources |
| web_app_active_slot | Active web app slot ID |
| web_app_deployment_slots | Web app deployment slot resources |
