# -
# Required Variables
# -
variable "env" {
  type        = string
  description = "(Required) <CN> environment code. Example: `test`. <br></br>&#8226; Value of `env` must be one of: `[nonprod,prod,core,int,uat,stage,dev,test,p,np]`."
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

variable "product_version" {
  type        = string
  description = "(Required) mbb product version. Example: `1.0.0`."
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
# Mandatory Tags for Resources
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

variable "country" {
  type        = string
  description = "(Required) Country where the resource belongs."
  default     = "th"
}

variable "product_name" {
  type        = string
  description = "(Required) Terraform Module name."
}

variable "cost_center" {
  type        = string
  description = "(Required) Cost center that should bear the costs."
  default     = ""
}

variable "cost_allocation_unit" {
  type        = string
  description = "(Required) Logical bucket to split shared platform cost."
  default     = ""
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
  default     = ""
}

variable "data_classification" {
  type        = string
  description = "(optional) Data classification level."
  default     = ""
}

variable "criticality" {
  type        = string
  description = "(Required) Workload SLA requirements."
  default     = "Medium"
}

variable "environment" {
  type        = string
  description = "(Required) Environment where the resource is located."
}

variable "status" {
  type        = string
  description = "(Required) Status of the resource."
  validation {
    condition     = contains(["Live", "Non-Operational", "Decommissioned"], var.status)
    error_message = "Value must be one of: Live, Non-Operational, Decommissioned."
  }
  default = "Live"
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

variable "budget_limit" {
  type        = string
  description = "(Required) Maximum budget allocated."
  default     = ""
}

variable "cost_alert_threshold" {
  type        = string
  description = "(Required) Cost threshold for triggering alerts."
  default     = ""
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  default     = ""
}

variable "compliance" {
  type        = string
  description = "(Required) Specific standard/regulation."
  default     = "None"
}

# -
# Optional Tags for Resources
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
  validation {
    condition     = var.auto_delete == "" || contains(["Yes", "No"], var.auto_delete)
    error_message = "Value must be Yes or No."
  }
  default = ""
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
  description = "(Optional) Is review needed before deletion?"
  default     = ""
}

variable "automation_policy" {
  type        = string
  description = "(Optional) Reference to any automation policy."
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

variable "experiment_phase" {
  type        = string
  description = "(Optional) Phase of the experiment."
  default     = ""
}

variable "last_vm_accessed" {
  type        = string
  description = "(Optional) Timestamp of the last access."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Maintenance window frequency."
  default     = ""
}

variable "notification_emails" {
  type        = list(string)
  description = "(Optional) List of emails for notifications."
  default     = [""]
}

variable "os" {
  type        = string
  description = "(Optional) Operating System for VMs."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch policy configuration."
  default     = ""
}

variable "region" {
  type        = string
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

variable "retention" {
  type        = string
  description = "(Optional) Retention period in days (0 = no snapshot)."
  default     = ""
}

variable "sandbox_type" {
  type        = string
  description = "(Optional) Type of sandbox (POC, Training, Demo, R&D)."
  default     = ""
}

variable "service" {
  type        = string
  description = "(Optional) Service component identifier."
  default     = ""
}

variable "landing_zone" {
  type        = string
  description = "(Optional) Platform or Application Landing Zone (Subscription only)."
  default     = ""
}

variable "platform_area" {
  type        = string
  description = "(Optional) Functional area of the platform (Subscription only)."
  default     = ""
}

# -
# Optional Variables
# -
variable "org" {
  type        = string
  description = "(Optional) <CN> company/businness unit code. Example: `mbb`."
  default     = "mbb"
}

variable "region_code" {
  type        = string
  description = "(Optional) mbb region code.<br></br>&#8226; Value of `region_code` must be one of: `[sea,ea,eu,sg,myw,idc]`."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw", "sg", "idc"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw,sg,idc]."
  }
  default = "sea"
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
