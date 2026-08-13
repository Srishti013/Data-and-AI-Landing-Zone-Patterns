# variable "location" {
#   type        = string
#   description = "Required. The Azure region for deployment of the this resource."
#   nullable    = false
# }

# variable "name" {
#   type        = string
#   description = "Required. The name of the this resource."

#   validation {
#     condition     = can(regex("^[a-zA-Z0-9_().-]{1,89}[a-zA-Z0-9_()-]$", var.name))
#     error_message = <<ERROR_MESSAGE
#     The resource group name must meet the following requirements:
#     - `Between 1 and 90 characters long.` 
#     - `Can only contain Alphanumerics, underscores, parentheses, hyphens, periods.`
#     - `Cannot end in a period`
#     ERROR_MESSAGE
#   }
# }

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  Controls the Resource Lock configuration for this resource. The following properties can be specified:
  
  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

# tflint-ignore: terraform_heredoc_usage
variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
Optional. A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - (Required) The ID or name of the role definition to assign to the principal.
- `principal_id` - (Required) The ID of the principal to assign the role to.
- `description` - (Optional) The description of the role assignment.
- `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - (Optional) The condition which will be used to scope the role assignment.
- `condition_version` - (Optional) The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. NOTE:
this field is only used in cross tenant scenario.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Example Input:
```hcl
role_assignments = {
  "role_assignment1" = {
    role_definition_id_or_name = "Reader"
    principal_id = "4179302c-702e-4de7-a061-beacd0a1be09"
    
  },
"role_assignment2" = {
  role_definition_id_or_name = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1" // Storage Blob Data Reader Role Guid 
  principal_id = "4179302c-702e-4de7-a061-beacd0a1be09"
  skip_service_principal_aad_check = false
  condition_version = "2.0"
  condition = <<-EOT
(
  (
    !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
  )
OR 
  (
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId]
  ForAnyOfAnyValues:GuidEquals {4179302c-702e-4de7-a061-beacd0a1be09}
  )
)
AND
(
  (
    !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
  )
  OR 
  (
    @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId]
    ForAnyOfAnyValues:GuidEquals {dc887ae1-fe50-4307-be53-213ff08f3c0b}
  )
)
EOT  
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue(
      [for role in var.role_assignments :
        can(regex("^/providers/Microsoft\\.Authorization/roleDefinitions/[0-9a-fA-F-]+$", role.role_definition_id_or_name))
        ||
        can(regex("^[[:alpha:]]+?", role.role_definition_id_or_name))
      ]
    )
    error_message = <<ERROR_MESSAGE
        role_definition_id_or_name must have the following format: 
         - Using the role definition Id : `/providers/Microsoft.Authorization/roleDefinitions/<role_guid>`
         - Using the role name: Reader | "Storage Blob Data Reader"
      ERROR_MESSAGE
  }
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

# -
# Mandatory Business Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Human readable name for the Application."
}

variable "app_support" {
  type        = string
  description = "(Required) Email address of the support team."
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.app_support))
    error_message = "Value for \"app_support\" must be a valid email address."
  }
}

variable "business_unit" {
  type        = string
  description = "(Required) Department that owns the resources."
}

variable "business_owner" {
  type        = string
  description = "(Required) Contact name of the application owner."
}

variable "type" {
  type        = string
  description = "(Required) Infrastructure or business service type."
  default     = "Infrastructure"
}

# -
# Mandatory DevOps Tags
# -
variable "product_name" {
  type        = string
  description = "(Required) Terraform Module name."
  default     = "resource_group"
}

variable "product_version" {
  type        = string
  description = "(Required) Terraform Module version."
}

# -
# Mandatory Finance Tags
# -
variable "cost_center" {
  type        = string
  description = "(Required) Cost center that should bear the costs."
}

variable "cost_allocation_unit" {
  type        = string
  description = "(Required) Logical bucket to split shared platform cost."
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
}

variable "budget_limit" {
  type        = string
  description = "(Required) Maximum budget allocated."
}

variable "cost_alert_threshold" {
  type        = string
  description = "(Required) Cost threshold for triggering alerts."
}

# -
# Mandatory Governance Tags
# -
variable "data_classification" {
  type        = string
  description = "(Required) Data classification level."
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  default     = "No"
}

variable "compliance" {
  type        = string
  description = "(Required) Specific standard/regulation."
  default     = "None"
}

# -
# Mandatory Operation Tags
# -
variable "criticality" {
  type        = string
  description = "(Required) Workload SLA requirements."
}

variable "environment" {
  type        = string
  description = "(Required) Environment where the resource is located."
}

variable "status" {
  type        = string
  description = "(Required) Status of the resource."
  default     = "Live"
}

# -
# Optional Tags for Resource Groups
# -
variable "delete_after" {
  type        = string
  description = "(Optional) Date after which resource should be deleted (MM/DD/YYYY)."
  default     = ""
}

variable "tier" {
  type        = string
  description = "(Optional) Network tier (VNet/subnet name)."
  default     = ""
}

variable "app_id" {
  type        = string
  description = "(Optional) Application ID from CMDB."
  default     = ""
}

variable "auto_delete" {
  type        = string
  description = "(Optional) Should resource be auto-deleted? (Yes/No)."
  default     = ""
}

variable "auto_shutdown" {
  type        = string
  description = "(Optional) Auto-shutdown configuration for cost optimization."
  default     = ""
}

variable "description" {
  type        = string
  description = "(Optional) Brief description of the resource purpose."
  default     = ""
}

variable "sandbox_purpose" {
  type        = string
  description = "(Optional) Purpose of the sandbox."
  default     = ""
}

variable "review_required" {
  type        = string
  description = "(Optional) Is review needed before deletion? (Yes/No)."
  default     = ""
}

variable "backup_policy" {
  type        = string
  description = "(Optional) Backup policy (Manual or Policy Based)."
  default     = ""
}

variable "disaster_recovery" {
  type        = string
  description = "(Optional) DR requirements."
  default     = ""
}

variable "notification_emails" {
  type        = list(string)
  description = "(Optional) List of emails for notifications."
  default     = [""]
}

variable "region" {
  type        = string
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

variable "env" {
  type        = string
  description = "(Required) Environment code for the resource."
}
variable "au" {
  type        = string
  description = "(Required) <CN> Accounting Unit (AU) code. Example: `0233985`. <br></br>&#8226; Value of `au` must be of numeric characters."
  validation {
    condition     = can(regex("^[[:digit:]]+$", var.au))
    error_message = "Value for \"au\" must be of numeric characters."
  }
}

# variable "criticality" {
#   type        = string
#   description = "(Required) <CN> criticality of the workload. Example: `Insignificant`. <br></br>&#8226; Value of `criticality` must be of sting characters."
#   validation {
#     condition     = contains(["Insignificant", "Significant", "Major", "Critical", "Yes", "No", "None"], var.criticality)
#     error_message = "Value of \"criticality\" must be one of: [Insignificant,Significant,Major,Critical,Yes,No,None]."
#   }
# }
variable "owner" {
  type        = string
  description = "(Required) <CN> technology owner group."
}
variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation (or `service` in <CN> Naming Standard). Example: `rg`, `vnet`, `st`, etc. More information: [Azure resource abbreviations](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)"
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: network, mgmt, buil"
}

variable "bu" {
  type        = string
  description = "(Required) Bussiness unit code. Example: IT or mbb."
}

# -
# Optional Variables
# -
variable "org" {
  type        = string
  description = "(Optional) <CN> company/businness unit code. Example: `mbb`."
  default     = "mbb"
}
variable "country" {
  type        = string
  description = "(Optional) <CN> country code. Example: `th`."
  default     = "th"
}
variable "region_code" {
  type        = string
  description = "(Optional) mbb region code.<br></br>&#8226; Value of `region_code` must be one of: `[sea,ea,eu]`."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw]."
  }
  default = "sa"
}
variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated\" suffix. Example: `lan1`."
  default     = null
}
variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated + additional_name\" concatenation. Example: `001`."
  default     = null
}
variable "additional_tags" {
  description = "(Optional) Additional base tags."
  type        = map(string)
  default     = null
}

variable "base_name" {
  type        = string
  description = "(optional) Application/Infrastructure \"base\" name. Example: `aks`."
  default     = null
}


# -
# - Optional tuning switches & defaults
# -
variable "no_dashes" {
  type        = bool
  description = "(Optional) When set to `true`, it will remove all `'-'` separators from the generated name."
  default     = false
}
variable "add_random" {
  type        = bool
  description = "(Optional) When set to `true`, it will add a `rnd_length`'s long `random_number` at the name's end."
  default     = false
}
variable "max_length" {
  type        = number
  description = "(Optional) Set the maximum length of the generated name. If over, the name will be trimmed to the `max_length`, considering the eventual `random_number` suffix. See this link for reference: [Resource name rules](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)"
  default     = 63 # arbitrary default number chosen by browsing the list of major resources.
}
variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the `random_number` generated."
  default     = 2
}
