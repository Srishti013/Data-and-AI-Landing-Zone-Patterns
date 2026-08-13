# -
# Basic Naming Parameters
# -
variable "env" {
  type        = string
  description = "(Required) Environment code. Example: `test`."
}

variable "org" {
  type        = string
  description = "(Optional) Company/Business unit code. Example: `mbb`."
  default     = "mbb"
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code. Example: `sea`."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw"], var.region_code)
    error_message = "Value must be one of: [ea,sea,eu,myw]."
  }
  default = "sea"
}

variable "base_name" {
  type        = string
  description = "(Optional) Application/Infrastructure base name. Example: `cosmos`."
  default     = null
}

variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness. Example: `db1`."
  default     = null
}

variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness. Example: `001`."
  default     = null
}

variable "au" {
  type        = string
  description = "(Required) Accounting Unit code. Example: `0233985`."
  validation {
    condition     = can(regex("^[[:digit:]]+$", var.au))
    error_message = "Value must be numeric characters."
  }
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: data, analytics."
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: IT or mbb."
}

variable "owner" {
  type        = string
  description = "(Required) Technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation."
  default     = "cosmos"
}

variable "max_length" {
  type        = number
  description = "(Optional) Maximum length of generated name."
  default     = 63
}

variable "no_dashes" {
  type        = bool
  description = "(Optional) Remove dashes in generated name."
  default     = false
}

variable "add_random" {
  type        = bool
  description = "(Optional) Add random characters to name."
  default     = false
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Length of random string."
  default     = 2
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

variable "country" {
  type        = string
  description = "(Optional) Country code. Example: `th`."
  default     = "th"
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
}

variable "product_version" {
  type        = string
  description = "(Required) mbb product version. Example: `1.0.0`."
}

# -
# Mandatory Finance Tags
# -
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

# -
# Mandatory Governance Tags
# -
variable "data_classification" {
  type        = string
  description = "(Optional) Data classification level."
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
# Mandatory Operation Tags
# -
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

# -
# Optional Tags
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
  description = "(Optional) List of email addresses for notifications."
  default     = []
  validation {
    condition     = alltrue([for email in var.notification_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "All notification emails must be valid email addresses."
  }
}

variable "region" {
  type        = string
  description = "(Required) Azure region where the resource is deployed."
}

# Additional custom tags
variable "additional_tags" {
  type        = map(string)
  description = "(Optional) Additional tags to add to resources"
  default     = {}
}
