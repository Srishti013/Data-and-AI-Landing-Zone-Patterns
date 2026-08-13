# -
# Required Variables for Naming
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
# Optional Variables for Naming
# -
variable "org" {
  type        = string
  description = "(Optional) <CN> company/businness unit code. Example: `mbb`."
  default     = "mbb"
}

variable "region_code" {
  type        = string
  description = "(Optional) mbb region code.<br></br>&#8226; Value of `region_code` must be one of: `[ea,sea,eu,myw,sg,idc]`."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw", "sg", "idc"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw,sg,idc]."
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
  default     = 80
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the `random_number` generated."
  default     = 2
}

# -
# Mandatory Tags - Only the required 8 tags as per specification
# -
variable "environment" {
  type        = string
  description = "(Required) Environment where the resource is located."
}

variable "business_owner" {
  type        = string
  description = "(Required) Contact name of the application owner."
}

variable "business_unit" {
  type        = string
  description = "(Required) Department that owns the resources."
}

variable "criticality" {
  type        = string
  description = "(Required) Workload SLA requirements."
}

variable "cost_center" {
  type        = string
  description = "(Required) Cost center that should bear the costs."
}

variable "data_classification" {
  type        = string
  description = "(Required) Data classification level."
}

variable "compliance" {
  type        = string
  description = "(Required) Specific standard/regulation."
}

# -
# Optional Tags - Only the required 3 optional tags as per specification
# -
variable "region" {
  type        = string
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

variable "description" {
  type        = string
  description = "(Optional) Brief description of the resource purpose."
  default     = ""
}

variable "notification_emails" {
  type        = list(string)
  description = "(Optional) List of email addresses for notifications."
  default     = []
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  default     = "No"
}
