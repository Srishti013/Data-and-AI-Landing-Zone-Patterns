[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1.0.0.0 |
| Created By | Sandeep B R |
| Reviewed By| |

# About this product version

## Product State: Released

## Product Category

- AI Service

## Notable changes in this version

### v1.0.0.0

- This is the initial version to deploy Azure Bing Search Service in Azure and no notable changes for version 1.

## Upgrade Path

- Not Available as it is the initial version

# Product Description

## Overview

- Grounding with Bing Search in Azure AI is a service that connects Large Language Models (LLMs) to real-time public web data, ensuring AI-generated responses are accurate, current, and cited. It acts as a search tool for AI agents, retrieving up-to-date information, news, and images


## Note

- None

## Network Topology (wherever applicable)

- None

## Azure Service(s) in Scope

- Azure Bing Search

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

- This terraform module creates one `Azure Document Intelligence`.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.4 |




### Azure Artifacts

| Name | Source | Version |
|------|--------|---------|
| Azure Bing Search| [mbb_bing_resource](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/user/main/modules/mbb_bing_resource/v1.0.0.0) | 1.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

```main.tf
module "mbb_bing_resource" {
  for_each = var.bing_accounts

  source = "./modules/mbb_bing_resource/v1.0.0.0"

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

  parent_id = module.aea_resource_group[
    each.value.resource_group_key
  ].resource_id

  # Pass single account as map (module expects map)
  bing_accounts = {
    (each.key) = {
      sku_name           = each.value.sku_name
      kind               = each.value.kind
      location           = each.value.location
      statistics_enabled = each.value.statistics_enabled
      tags               = each.value.tags
    }
  }
}

```

- terraform Variables

```tfvars
bing_accounts = {
  mbb-bing-aea-dev-global-01 = {
    env                = "dev"
    org                = "mbb"
    region_code        = "myw"
    base_name          = ""
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    app_code           = "aea"
    bu                 = "it"
    owner              = "CEAT"
    resource_type_code = "bing"
    max_length         = 128
    no_dashes          = false
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
    region              = "global"
    description         = "Bing Custom Search"
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

    resource_group_key = "mbb-rg-aea-dev-myw-01"
    sku_name           = "G2"
    kind               = "Bing.GroundingCustomSearch"
    location           = "global"
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
| parent_id  | Parent_id of the Bing Resource | `string` | n/a | yes |
| Kind | Specifies the type of Bing Resources to be created | `string` | n/a | yes |
| Location |Location of the Bing Resource to be created | `string` | n/a | yes |
| sku |sku of the Bing Resource Account | `string` | n/a | yes |


### Resources

| Name | Type |
|------|------|
| [azapi_resource.bing_account"](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |





### Outputs

| Name | Description |
|------|-------------|
| bing_account_ids | The ID of the Bing Resource |
| bing_account_names | The name of the Bing Resource |
| bing_account_details | The Resource details of the Bing Resource |




