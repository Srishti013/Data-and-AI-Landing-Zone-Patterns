variable "location" {
  type        = string
  description = "(Required) Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
  nullable    = false
}

# variable "name" {
#   type        = string
#   description = "(Required) The name of the this resource."
# }

variable "network_interface_name" {
  type        = string
  description = "(Optional) The custom name of the network interface attached to the private endpoint. Changing this forces a new resource to be created"
}

variable "private_connection_resource_id" {
  type        = string
  description = "(Required) The ID of the Private Link Enabled Remote Resource which this Private Endpoint should be connected to."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The resource group where the resources will be deployed."
}

variable "subnet_resource_id" {
  type        = string
  description = "(Required) Azure resource ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created."
}

variable "application_security_group_association_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) The resource ids of application security group to associate."
}

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

variable "ip_configurations" {
  type = map(object({
    name               = string
    private_ip_address = string
    subresource_name   = string
    member_name        = optional(string, "default")
  }))
  default     = {}
  description = <<DESCRIPTION
  (Optional) An ip_configuration block as defined below
  map(object({
    private_ip_address = "(Required) Specifies the static IP address within the private endpoint's subnet to be used. Changing this forces a new resource to be created."
    subresource_name   = "(Required) Specifies the subresource this IP address applies to."
    member_name        = "(Optional) Specifies the member name this IP address applies to."
  }))

  Example Input:

  ```terraform
  ip_configurations ={
    "object1" = {
      name               = "<name_of_the_ip_configuration>"
      private_ip_address = "<value_of_the_static_IP >"
      subresource_name   = "<subresource_name>"
    }
  }
  ``` 
  DESCRIPTION
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = string
  })
  default     = null
  description = "The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly", "None"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "private_dns_zone_group_name" {
  type        = string
  default     = null
  description = "(Optional) Specifies the Name of the Private DNS Zone Group."
}

variable "private_dns_zone_resource_ids" {
  type        = list(string)
  default     = []
  description = "(Optional) Specifies the list of Private DNS Zones to include within the private_dns_zone_group."
}

variable "private_service_connection_name" {
  type        = string
  default     = null
  description = "(Optional) Specifies the  Specifies the Name of the Private Service Connection."
}

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
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.  

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Example Input:

  ```terraform
  role_assignments ={
    "object1" = {
      role_definition_id_or_name = "<role_definition_1_name>"
      principal_id               = "<object_id_of_the_principal>"
    },
    "object2" = {
      role_definition_id_or_name = "<role_definition_2_name>"
      principal_id               = "<object_id_of_the_principal>"
      description                = "<description>"
    },
  }
  ``` 
DESCRIPTION
  nullable    = false
}

variable "subresource_names" {
  type        = list(string)
  default     = null
  description = "(Optional) A list of subresource names which the Private Endpoint is able to connect to. [https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource]"
}

# variable "tags" {
#   type        = map(string)
#   default     = null
#   description = "Tags to be applied to the resource"
# }

variable "business_unit" {
  type        = string
  default     = "DefaultBusinessUnit"
  description = "Business Unit tag for the resource group."
}

# variable "data_classification" {
#   type        = string
#   default     = "DefaultClassification"
#   description = "Data Classification tag for the resource group."
# }

# variable "criticality" {
#   type        = string
#   default     = "DefaultCriticality"
#   description = "Criticality tag for the resource group."
# }

# variable "environment" {
#   type        = string
#   default     = "DefaultEnvironment"
#   description = "Environment tag for the resource group."
# }

variable "cost_center" {
  type        = string
  default     = "DefaultCostCenter"
  description = "Cost Center tag for the resource group."
}

variable "app_id" {
  type        = string
  default     = "DefaultAppId"
  description = "AppId tag for the resource group."
}

# variable "app_name" {
#   type        = string
#   default     = "DefaultAppName"
#   description = "App Name tag for the resource group."
# }

variable "app_support" {
  type        = string
  default     = "DefaultAppSupport"
  description = "App Support tag for the resource group."
}

# variable "tier" {
#   type        = string
#   default     = "DefaultTier"
#   description = "Tier tag for the resource group."
# }

# variable "product_name" {
#   type        = string
#   default     = "DefaultProductName"
#   description = "Product Name tag for the resource group."
# }

variable "product_version" {
  type        = string
  default     = "DefaultProductVersion"
  description = "Product Version tag for the resource group."
}

variable "autoshutdown" {
  type        = string
  default     = "DefaultAutoshutDown"
  description = "AutoshutDown tag for the resource group."
}

variable "sandbox_owner" {
  type        = string
  default     = "DefaultSandboxOwner"
  description = "Sandbox Owner tag for the resource group."
}

# variable "delete_after" {
#   type        = string
#   default     = "DefaultDeleteAfter"
#   description = "DeleteAfter tag for the resource group."
# }

variable "auto_delete" {
  type        = string
  default     = "DefaultAutoDelete"
  description = "AutoDelete tag for the resource group."
}


###################
##Naming Variables
###################
##################################
###Naming Convensions Variables
##################################
# -
# Naming Module Variables
# -
variable "env" {
  type        = string
  description = "(Required) Environment code. Example: `test`."
}

variable "au" {
  type        = string
  description = "(Required) Accounting Unit (AU) code. Example: `0233985`."
  validation {
    condition     = can(regex("^[[:digit:]]+$", var.au))
    error_message = "Value for \"au\" must be of numeric characters."
  }
}

variable "owner" {
  type        = string
  description = "(Required) Technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation. Example: `kv`."
  default     = "kv"
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: network, mgmt, build"
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: IT or mbb."
}

# -
# Mandatory Business Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Human readable name for the Application."
}

# variable "business_unit" {
#   type        = string
#   description = "(Required) Department that owns the resources."
# }

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
  default     = "key_vault"
}

# -
# Mandatory Finance Tags
# -
# variable "cost_center" {
#   type        = string
#   description = "(Required) Cost center that should bear the costs."
#   default     = ""
# }

variable "cost_allocation_unit" {
  type        = string
  default     = ""
  description = "(Required) Logical bucket to split shared platform cost."
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
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
  description = "(optional) Data classification level."
  default     = ""
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  validation {
    condition     = contains(["Yes", "No"], var.compliance_required)
    error_message = "Value must be Yes or No."
  }
  default = "No"
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
  validation {
    condition     = contains(["Live", "Non-Operational", "Decommissioned"], var.status)
    error_message = "Value must be one of: Live, Non-Operational, Decommissioned."
  }
  default = "Live"
}

# -
# Optional Naming Variables
# -
variable "org" {
  type        = string
  description = "(Optional) Company/business unit code. Example: `mbb`."
  default     = "mbb"
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw]."
  }
  default = "sea"
}

variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness."
  default     = null
}

variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness."
  default     = null
}

variable "additional_tags" {
  description = "(Optional) Additional base tags."
  type        = map(string)
  default     = null
}

variable "base_name" {
  type        = string
  description = "(Optional) Application/Infrastructure base name."
  default     = null
}

variable "max_length" {
  type        = number
  description = "(Optional) Set the maximum length of the generated name."
  default     = 24
}

variable "no_dashes" {
  type        = bool
  description = "(Optional) When set to true, it will remove all '-' separators from the generated name."
  default     = true
}

variable "add_random" {
  type        = bool
  description = "(Optional) When set to true, it will add a random number at the name's end."
  default     = false
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the random number generated."
  default     = 2
}

# -
# Optional Tags for Key Vault
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

# variable "app_id" {
#   type        = string
#   description = "(Optional) Application ID from CMDB."
#   default     = ""
# }

# variable "auto_delete" {
#   type        = string
#   description = "(Optional) Should resource be auto-deleted? (Yes/No)."
#   default     = ""
# }

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
  description = "(Optional) List of emails for notifications."
  default     = [""]
}

variable "region" {
  type        = string
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

# -
# Additional Optional Tag Variables
# -
variable "service" {
  type        = string
  description = "(Required) Service name or identifier."
}

variable "integration_id" {
  type        = string
  description = "(Optional) Integration ID for the resource."
  default     = ""
}

variable "experiment_phase" {
  type        = string
  description = "(Optional) Experiment phase for sandbox environments."
  default     = ""
}

variable "os" {
  type        = string
  description = "(Optional) Operating System type."
  default     = ""
}

variable "last_vm_accessed" {
  type        = string
  description = "(Optional) Last VM access timestamp."
  default     = ""
}

variable "retention" {
  type        = string
  description = "(Optional) Data retention policy."
  default     = ""
}

variable "sandbox_type" {
  type        = string
  description = "(Optional) Type of sandbox environment."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch policy configuration."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Maintenance window schedule."
  default     = ""
}