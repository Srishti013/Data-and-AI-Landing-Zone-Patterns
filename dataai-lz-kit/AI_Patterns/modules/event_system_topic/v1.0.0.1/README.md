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

- EventGrid System Topic

## Notable changes in this version

### v1.0.0.0

- This is the initial version to deploy Azure Event grid system topic Service in Azure and no notable changes for version 1.0.0.0.

## Upgrade Path

- Not Available as it is the initial version

# Product Description

## Overview

- A system topic in Event Grid represents one or more events published by Azure services such as Azure Storage and Azure Event Hubs. For example, a system topic can represent all blob events or only blob created and blob deleted events published for a specific storage account. In this example, when a blob is uploaded to the storage account, the Azure Storage service publishes a blob created event to the system topic in Event Grid, which then forwards the event to topic's subscribers that receive and process the event.


## Note

- None

## Network Topology (wherever applicable)

- None

## Azure Service(s) in Scope

- Azure Event Grid System Topic

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

- This terraform module creates one `Azure EventGrid System Topic`.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |




### Azure Artifacts

| Name | Source | Version |
|------|--------|---------|
| Azure Event Grid System Topic | [mbb_event_system_topic](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/user/main/modules/mbb_event_system_topic/v1.0.0.0) | 1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

```main.tf
module "mbb_eventgrid_system_topic" {
  for_each = var.eventgrid_system_topics

  providers = {
    azurerm = azurerm.dev_myw_sub
  }
  source = "./modules/mbb_event_system_topic/v1.0.0.0"

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


  eventgrid_system_topic_resource_group_name = module.data_resource_groups[each.value.resource_group_key].name
  eventgrid_system_topic_type                = each.value.eventgrid_system_topic_type
  # eventgrid_system_topic_source_resource_id  = try(each.value.eventgrid_system_topic_source_resource_id, null)
  eventgrid_system_topic_source_resource_id = module.storage_account[each.value.storage_account_key].resource_id

  eventgrid_system_topic_identity = {
    type         = each.value.eventgrid_system_topic_identity.type
    identity_ids = [module.user_managed_identities[each.value.umi_key].resource_id]

  }

  eventgrid_system_topic_event_subscriptions = {
    for esk, es in each.value.event_subscriptions : esk => {

      eventgrid_system_topic_event_subscription_name                  = es.eventgrid_system_topic_event_subscription_name
      eventgrid_system_topic_event_subscription_resource_group_name   = module.data_resource_groups[es.resource_group_key].name
      eventgrid_system_topic_event_subscription_expiration_time_utc   = try(es.eventgrid_system_topic_event_subscription_expiration_time_utc, null)
      eventgrid_system_topic_event_subscription_event_delivery_schema = try(es.eventgrid_system_topic_event_subscription_event_delivery_schema, null)
      eventgrid_system_topic_event_subscription_eventhub_endpoint_id  = try(es.eventgrid_system_topic_event_subscription_eventhub_endpoint_id, null)
      eventgrid_system_topic_event_subscription_storage_queue_endpoint = (try(es.eventgrid_system_topic_event_subscription_storage_queue_endpoint, null) == null ? null :
        {
          storage_account_id                    = module.storage_account[es.eventgrid_system_topic_event_subscription_storage_queue_endpoint.storage_account_key].resource_id
          queue_name                            = es.eventgrid_system_topic_event_subscription_storage_queue_endpoint.queue_name
          queue_message_time_to_live_in_seconds = try(es.eventgrid_system_topic_event_subscription_storage_queue_endpoint.queue_message_time_to_live_in_seconds, null)
        }
      )
    }
  }
}
```

- terraform Variables

```tfvars
eventgrid_system_topics = {
  "mbb-egst-data-dev-myw-01" = {

    env                = "dev"
    org                = "mbb"
    region_code        = "myw"
    base_name          = ""
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    owner              = "CEAT"
    app_code           = "data"
    bu                 = "it"
    resource_type_code = "egst"
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
    app_id              = "MBB-SEA-NET01-00001"

    # Mandatory DevOps Tags
    product_name    = "mbb_eventgrid_namespace"
    product_version = "1.0.0.0"

    # Mandatory Finance Tags
    cost_allocation_unit = "TBD"
    budget_id            = "83254"

    # Mandatory Operation Tags
    criticality = "T1"
    environment = "Development"
    status      = "Live"
    service     = "eventgrid_namespace"

    # Optional Tags
    description         = "Base Infra EventGrid Namespace for development environment"
    region              = "MYW"
    notification_emails = ["mss_ceat@maybank.com"]
    role_assignments    = {}
    additional_tags     = {}

    storage_account_key         = "mbb-sa-egst-data-dev-myw-01"
    umi_key                     = "mbb-uami-egst-data-dev-myw-01"
    resource_group_key          = "mbb-rg-dataingestion-dev-myw-01"
    eventgrid_system_topic_type = "Microsoft.Storage.StorageAccounts"

    eventgrid_system_topic_identity = {
      type = "UserAssigned"
    }

    event_subscriptions = {
      mbb-evgts-data-dev-myw-01 = {
        eventgrid_system_topic_event_subscription_name                  = "mbb-evgts-data-dev-myw-01"
        resource_group_key                                              = "mbb-rg-dataingestion-dev-myw-01"
        eventgrid_system_topic_event_subscription_expiration_time_utc   = "2026-12-31T23:59:59Z"
        eventgrid_system_topic_event_subscription_event_delivery_schema = "EventGridSchema"

        eventgrid_system_topic_event_subscription_storage_queue_endpoint = {
          storage_account_key                   = "mbb-sa-egst-data-dev-myw-01"
          queue_name                            = "mbb-egst-queue-01"
          queue_message_time_to_live_in_seconds = 3600
        }
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
| name |The name which should be used for this Event Grid System Topic | `string` | n/a | yes |
| resource_group_name | The name of the Resource Group where the Event Grid System Topic should exist | `string` | n/a | yes |
| Location | The Azure Region where the Event Grid System Topic should exist | `string` | n/a | yes |
| source_resource_id | The ID of the Event Grid System Topic ARM Source | `string` | n/a | no|
| topic_type | The Topic Type of the Event Grid System Topic | `string` | n/a | no|
| identity | The identity of the Event Grid System Topic | `map(string)` | n/a | no|
| tags | The tags of the Event Grid System Topic | `map(string)` | n/a | no|


### Resources

| Name | Type |
|------|------|
| [azurerm_eventgrid_system_topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic) | resource |
| [azurerm_eventgrid_system_topic_event_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription) | resource |


### Outputs

| Name | Description |
|------|-------------|
| eventgrid_system_topic_id | Event Grid System Topic ID |
| eventgrid_system_topic_name | Event Grid System Topic name |
| eventgrid_system_topic_resource_group | Event Grid System Topic resource group |
| eventgrid_system_topic_location | Event Grid System Topic location |