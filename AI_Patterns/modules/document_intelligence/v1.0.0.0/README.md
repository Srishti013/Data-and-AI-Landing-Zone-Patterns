[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span>  |
| --- | --- |
| Version | 1 |
| Created By | Sandeep B R |
| Reviewed By| |

# About this product version

## Product State: Released

## Product Category

- AI / Machine Learning

## Notable changes in this version

### v1.0.0.0

- This is the initial version of Azure Document Intelligence and no notable changes for version 1.0.0.0
## Upgrade Path

- Not Available as it is the inital version

# Product Description

## Overview

- The Cognitive Services Account manages the resource type for various Azure AI resource implementations, including Azure AI Foundry, Azure OpenAI, Azure Speech, Azure Vision and others. Each service shares the same control plane but exposes a different subset of developer APIs. Azure AI Foundry (kind = AIServices) provides the superset of capabilities.
- Naming and location are derived from the Maybank naming module rather than direct `name` and `location` inputs.


## Note

- `kind` must be one of `AnomalyDetector`, `Academic`, `AIServices`,`CognitiveServices`,`ComputerVision`,`ContentModerator`,`ContentSafety`,`CustomSpeech`,`CustomVision.Prediction`,`CustomVision.Training`,`Emotion`,`Face`,`FormRecognizer`,`ImmersiveReader`,`LUIS`,`LUIS.Authoring`,`MetricsAdvisor`,`OpenAI`,`Personalizer`,`QnAMaker`,`Recommendations`,`SpeakerRecognition`,`Speech`,`SpeechServices`,`SpeechTranslation`,`TextAnalytics`,`TextTranslation` and `WebLM` . 

## Network Topology (wherever applicable)

- Hub/spoke with private endpoint connectivity and centralized private DNS is recommended for production workloads.

## Azure Service(s) in Scope

- Azure Document Intelligence
- Azure AI Services
- Azure CustomSpeech
- Azure ContentSafety
- Azure Text Analytics
- Azure Face
- Azure Computer Vision
- Azure Cognitive Services

## Azure Services Needed (Pre-Requisites)

- Resource Group
- Subnet(s) for Private Endpoint, if private access is required

## Optional Azure services Used (Customer Choice)

- None

## Limitations

- This module doesn't support Bing Search.

# Product Security

- Private endpoint based access is the recommended connectivity pattern.

# Product Usage Guidance

## Overview

- This module creates  Document AI and other AI services based on the value we are passing on `kind`.
- Azure Document Intelligence is a cloud AI service from Microsoft that lets you extract structured data from documents—like PDFs, images, scans—using AI.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 3.117, < 5.0" |


### Azure Artifacts

| Name | Source | Version |
|------|--------|---------|
| mbb_document_intelligence | [IAC link](https://github.com/maybank-ghes/mbb-az-iac-modules/tree/main/modules/mbb_document_intelligence) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

- used in main terraform configuration file by team that are consuming the product (main.tf)

```main.tf
module "document_intelligence" {
  for_each = var.document_intelligence
  source   = "./modules/mbb_document_intelligence/v1.0.0.0"
  providers = {
    azurerm = azurerm.uat_myw_sub
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

  # name                = each.value.name
  resource_group_name = module.ai_resource_group[each.value.resource_group_key].name
  # location            = each.value.location

  kind     = each.value.kind
  sku_name = each.value.sku_name

  custom_subdomain_name      = try(each.value.custom_subdomain_name, null)
  dynamic_throttling_enabled = try(each.value.dynamic_throttling_enabled, null)
  customer_managed_key       = try(each.value.customer_managed_key, null)
  fqdns                      = try(each.value.fqdns, null)
  identity = {
    type         = each.value.identity.type
    identity_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }
  local_auth_enabled              = try(each.value.local_auth_enabled, null)
  metrics_advisor_aad_client_id   = try(each.value.metrics_advisor_aad_client_id, null)
  metrics_advisor_aad_tenant_id   = try(each.value.metrics_advisor_aad_tenant_id, null)
  metrics_advisor_super_user_name = try(each.value.metrics_advisor_super_user_name, null)
  metrics_advisor_website_name    = try(each.value.metrics_advisor_website_name, null)
  #   network_acls                       = try(each.value.network_acls, null)
  network_injection                  = try(each.value.network_injection, null)
  outbound_network_access_restricted = try(each.value.outbound_network_access_restricted, null)
  project_management_enabled         = try(each.value.project_management_enabled, null)
  public_network_access_enabled      = try(each.value.public_network_access_enabled, null)
  qna_runtime_endpoint               = try(each.value.qna_runtime_endpoint, null)

  custom_question_answering_search_service_id  = try(each.value.custom_question_answering_search_service_id, null)
  custom_question_answering_search_service_key = try(each.value.custom_question_answering_search_service_key, null)

  storage = try(each.value.storage, null)
  tags    = try(each.value.tags, null)
}
```

- terraform Variables

```tfvars
document_intelligence = {
  mbb-di-espi-uat-sea-01 = {
    env                = "uat"
    org                = "mbb"
    region_code        = "sea"
    base_name          = ""
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    app_code           = "espi"
    bu                 = "it"
    owner              = "CEAT"
    resource_type_code = "di"
    max_length         = 128
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = "UAT"
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
    region              = "SEA"
    description         = "Document AI"
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

    # name = "mbb-di-espi-uat-myw-01"
    resource_group_key = "mbb-rg-espi-uat-myw-01"
    # location = "southeastasia"
    sku_name = "S0"
    kind     = "FormRecognizer"
    umi_key  = "mbb-uami-di-espi-uat-sea-01"

    custom_subdomain_name         = "mbb-di-espi-uat-sea-01"
    local_auth_enabled            = true
    public_network_access_enabled = false

    identity = {
      type = "UserAssigned"
    }

    # network_acls = {
    #   default_action = "Allow"
    #   bypass         = "AzureServices"
    #   ip_rules       = []
    # }

    # tags = {
    #   environment         = "uat"
    #   business_unit       = "data"
    #   app_name            = "document-intelligence"
    #   owner               = "mbb"
    #   cost_center         = "12345"
    #   data_classification = "internal"
    # }
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
| resource_group_name  | Resource group name of Document Intelligence | `string` | n/a | yes |
| Kind | Specifies the type of Cognitive Service Account that should be created. | `string` | n/a | yes |
| sku_name |Sku name of Document Intelligence | `string` | n/a | yes |
| custom_subdomain_name |The subdomain name used for Entra ID token-based authentication. | `string` | n/a | no |
| dynamic_throttling_enabled |Whether to enable the dynamic throttling for this Cognitive Service Account | `string` | n/a | no |
| customer_managed_key  | customer managed key for Cognitive Service Account | `map(object)` | n/a | no |
| fqdn | List of FQDNs allowed for the Cognitive Account | `list(string)` | n/a | no |
| identity| Identity configuration for the Cognitive Account | `map(object)` | n/a | no |
| local_auth_enabled| Whether local authentication methods is enabled for the Cognitive Account | `bool` | n/a | no |
| metrics_advisor_aad_client_id | The Azure AD Client ID (Application ID)| `string` | n/a | no |
| metrics_advisor_aad_tenant_id | The Azure AD Tenant ID| `string` | n/a | no |
| metrics_advisor_super_user_name| The super user of Metrics Advisor| `string` | n/a | no |
| metrics_advisor_website_name | The website name of Metrics Advisor | `string` | n/a | no |
| network_acls | Network ACL for Cognitive Account | `map(object)` | n/a | no |
| network_injection  | Network Injection for Cognitive Account | `map(object)` | n/a | no |
| outbound_network_access_restricted   | Whether outbound network access is restricted for the Cognitive Account. | `bool` | n/a | no |
| project_management_enabled | Whether project management is enabled for the Cognitive Account| `bool` | n/a | no |
| public_network_access_enabled | Whether public network access is allowed for the Cognitive Account | `bool` | n/a | no |
| qna_runtime_endpoint | A URL to link a QnAMaker cognitive account to a QnA runtime | `string` | n/a | no |
| custom_question_answering_search_service_id| if `kind` is `TextAnalytics` this specifies the ID of the Search service | `string` | n/a | no |
| custom_question_answering_search_service_key | if `kind` is `TextAnalytics` this specifies the ID of the Search service | `string` | n/a | no |
| storage | Storage for Cognitive Account | `map(object)` | n/a | no |

### Resources

| Name | Type |
|------|------|
| [azurerm_cognitive_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |


### Outputs

| Name | Description |
|------|-------------|
| cognitive_account | Full Cognitive Account resource object |
| id | The ID of the Cognitive Account |
| name | The name of the Cognitive Account |
| endpoint | The endpoint of the Cognitive Account |
| primary_access_key | The primary access key of the Cognitive Account |
| custom_subdomain_name | The custom subdomain name of the Cognitive Account |

