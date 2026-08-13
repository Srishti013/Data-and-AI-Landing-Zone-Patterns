# variable "location" {
#   type        = string
#   description = <<DESCRIPTION
#     (Required) Specifies the supported Azure location for the resource to be deployed. 
#     Changing this forces a new resource to be created.
#   DESCRIPTION
#   nullable    = false
# }

# variable "name" {
#   type        = string
#   description = "(Required) Specifies the name of the Route Table. Changing this forces a new resource to be created."
#   nullable    = false
# }

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the resource. Changing this forces a new resource to be created."
  nullable    = false
}

variable "bgp_route_propagation_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Boolean flag which controls propagation of routes learned by BGP on that route table. Defaults to true."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
    (Optional) This variable controls whether or not telemetry is enabled for the module.
    For more information see <https://aka.ms/avm/telemetryinfo>.
    If it is set to false, then no telemetry will be collected.
  DESCRIPTION
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
    (Optional) Controls the Resource Lock configuration for this resource. The following properties can be specified:

    - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
    - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
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
    (Optional) A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

    - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
    - `principal_id` - The ID of the principal to assign the role to.
    - `description` - The description of the role assignment.
    - `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
    - `condition` - The condition which will be used to scope the role assignment.
    - `condition_version` - The version of the condition syntax. Valid values are '2.0'.

    > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "routes" {
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default     = {}
  description = <<DESCRIPTION
    (Optional) A map of route objects to create on the route table. 

    - `name` - (Required) The name of the route.
    - `address_prefix` - (Required) The destination to which the route applies. Can be CIDR (such as 10.1.0.0/16) or Azure Service Tag (such as ApiManagement, AzureBackup or AzureMonitor) format.
    - `next_hop_type` - (Required) The type of Azure hop the packet should be sent to. Possible values are VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None.
    - `next_hop_in_ip_address` - (Optional) Contains the IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance

    Example Input:

```terraform
routes = {
    route1 = {
      name           = "test-route-vnetlocal"
      address_prefix = "10.2.0.0/32"
      next_hop_type  = "VnetLocal"
    }
}
```
DESCRIPTION

  validation {
    condition     = length([for route in var.routes : route.name]) == length(distinct([for route in var.routes : route.name]))
    error_message = "Each route name must be unique within the route table."
  }
  validation {
    condition     = alltrue([for route in var.routes : contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type)])
    error_message = "next_hop_type must be one of 'VirtualNetworkGateway', 'VnetLocal', 'Internet', 'VirtualAppliance' or 'None' for all routes."
  }
  validation {
    condition     = alltrue([for route in var.routes : route.next_hop_type != "VirtualAppliance" ? route.next_hop_in_ip_address == null : true])
    error_message = "If next_hop_type is not VirtualAppliance, next_hop_in_ip_address must be null."
  }
}

variable "subnet_resource_ids" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
    (Optional) A map of string subnet ID's to associate the route table to.
    Each value in the map must be supplied in the form of an Azure resource ID: 
```yaml annotate 
/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}
```
Example Input:
```terraform
subnet_resource_ids = {
    subnet1 = azurerm_subnet.this.id,
    subnet2 = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}"
}
```
DESCRIPTION
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
  default     = "route_tables"
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
  default     = ""
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
  default     = ""
  description = "(Required) Maximum budget allocated."
}

variable "cost_alert_threshold" {
  type        = string
  default     = ""
  description = "(Required) Cost threshold for triggering alerts."
}

# -
# Mandatory Governance Tags
# -
variable "data_classification" {
  type        = string
  default     = ""
  description = "(Required) Data classification level."
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
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

variable "env" {
  type        = string
  description = "(Required) <CN> environment code. Example: `test`. <br></br>&#8226; Value of `env` must be one of: `[nonprod,prod,core,int,uat,stage,dev,test,p,np]`."
  validation {
    condition     = contains(["nonprod", "prod", "core", "int", "uat", "stage", "dev", "test", "p", "d", "u", "sb"], var.env)
    error_message = "Value of \"env\" must be one of: [nonprod,prod,core,int,uat,stage,dev,test,sb]."
  }
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
  default     = 80 # Route table has a 80-character limit
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the `random_number` generated."
  default     = 2
}

# -
# Additional Optional Tags
# -
variable "automation_policy" {
  type        = string
  description = "(Optional) Automation policy for resource management."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Maintenance window schedule."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch management policy."
  default     = ""
}

variable "review_required" {
  type        = string
  description = "(Optional) Review requirement."
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

variable "service" {
  type        = string
  description = "(Optional) Service category or type."
  default     = ""
}
