# -########################
# Naming Module Variables
# -########################
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
  default     = "egst"
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: network, mgmt, build"
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: IT or {org}."
}

# -
# Mandatory Business Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Human readable name for the Application."
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
  default     = "event_system_topic"
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
  description = "(Optional) Company/business unit code. Example: `{org}`."
  default     = "{org}"
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
# Optional Tags for Event grid system topic
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

##########################################################
###Variable Event Grid System Topic
##########################################################

variable "eventgrid_system_topic_name" {
  description = "Name of the Event Grid System Topic"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_resource_group_name" {
  description = "Name of the resource group for Event Grid System Topic"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_location" {
  description = "Location of the Event Grid System Topic"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_type" {
  description = "Type of the Event Grid System Topic"
  type        = string
}

variable "eventgrid_system_topic_source_resource_id" {
  description = "Source resource ID for the Event Grid System Topic"
  type        = string
}

variable "eventgrid_system_topic_identity" {
  description = "Identity configuration for the Event Grid System Topic"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default  = null
  nullable = true
}



################################################################
### Variable for Event Grid System Topic Subscriptions
################################################################
# variable "eventgrid_system_topic_event_subscriptions" {
#   description = "Map of Event Grid System Topic Event Subscription definitions"

#   type = map(object({
#     eventgrid_system_topic_event_subscription_name                  = string
#     eventgrid_system_topic_event_subscription_resource_group_name   = string
#     eventgrid_system_topic_event_subscription_expiration_time_utc   = optional(string)
#     eventgrid_system_topic_event_subscription_event_delivery_schema = optional(string)
#     eventgrid_system_topic_event_subscription_eventhub_endpoint_id  = optional(string)

#     eventgrid_system_topic_event_subscription_storage_queue_endpoint = optional(object({
#       storage_account_id                    = optional(string)
#       queue_name                            = string
#       queue_message_time_to_live_in_seconds = optional(number)
#     }))
#   }))

#   default = {}
# }

################################################################
### Variable for Event Grid System Topic Subscriptions
################################################################
variable "eventgrid_system_topic_event_subscriptions" {
  description = "Map of Event Grid System Topic Event Subscription definitions"

  type = map(object({
    eventgrid_system_topic_event_subscription_name                = string
    eventgrid_system_topic_event_subscription_resource_group_name = string

    eventgrid_system_topic_event_subscription_expiration_time_utc                  = optional(string)
    eventgrid_system_topic_event_subscription_event_delivery_schema                = optional(string)
    eventgrid_system_topic_event_subscription_eventhub_endpoint_id                 = optional(string)
    eventgrid_system_topic_event_subscription_hybrid_connection_endpoint_id        = optional(string)
    eventgrid_system_topic_event_subscription_service_bus_queue_endpoint_id        = optional(string)
    eventgrid_system_topic_event_subscription_service_bus_topic_endpoint_id        = optional(string)
    eventgrid_system_topic_event_subscription_included_event_types                 = optional(list(string))
    eventgrid_system_topic_event_subscription_labels                               = optional(list(string))
    eventgrid_system_topic_event_subscription_advanced_filtering_on_arrays_enabled = optional(bool)

    eventgrid_system_topic_event_subscription_storage_queue_endpoint = optional(object({
      storage_account_id                    = string
      queue_name                            = string
      queue_message_time_to_live_in_seconds = optional(number)
    }))

    eventgrid_system_topic_event_subscription_azure_function_endpoint = optional(object({
      function_id                       = string
      max_events_per_batch              = optional(number)
      preferred_batch_size_in_kilobytes = optional(number)
    }))

    eventgrid_system_topic_event_subscription_webhook_endpoint = optional(object({
      url                               = string
      base_url                          = optional(string)
      max_events_per_batch              = optional(number)
      preferred_batch_size_in_kilobytes = optional(number)
      active_directory_tenant_id        = optional(string)
      active_directory_app_id_or_uri    = optional(string)
    }))

    eventgrid_system_topic_event_subscription_subject_filter = optional(object({
      subject_begins_with = optional(string)
      subject_ends_with   = optional(string)
      case_sensitive      = optional(bool)
    }))

    eventgrid_system_topic_event_subscription_delivery_identity = optional(object({
      type                   = string
      user_assigned_identity = optional(string)
    }))

    eventgrid_system_topic_event_subscription_delivery_property = optional(list(object({
      header_name  = string
      type         = string
      value        = optional(string)
      source_field = optional(string)
      secret       = optional(bool)
    })))

    eventgrid_system_topic_event_subscription_dead_letter_identity = optional(object({
      type                   = string
      user_assigned_identity = optional(string)
    }))

    eventgrid_system_topic_event_subscription_storage_blob_dead_letter_destination = optional(object({
      storage_account_id          = string
      storage_blob_container_name = string
    }))

    eventgrid_system_topic_event_subscription_retry_policy = optional(object({
      max_delivery_attempts = number
      event_time_to_live    = number
    }))

    eventgrid_system_topic_event_subscription_advanced_filter = optional(object({
      bool_equals = optional(list(object({
        key   = string
        value = bool
      })))

      number_greater_than = optional(list(object({
        key   = string
        value = number
      })))

      number_greater_than_or_equals = optional(list(object({
        key   = string
        value = number
      })))

      number_less_than = optional(list(object({
        key   = string
        value = number
      })))

      number_less_than_or_equals = optional(list(object({
        key   = string
        value = number
      })))

      number_in = optional(list(object({
        key    = string
        values = list(number)
      })))

      number_not_in = optional(list(object({
        key    = string
        values = list(number)
      })))

      number_in_range = optional(list(object({
        key    = string
        values = list(number)
      })))

      number_not_in_range = optional(list(object({
        key    = string
        values = list(number)
      })))

      string_begins_with = optional(list(object({
        key    = string
        values = list(string)
      })))

      string_not_begins_with = optional(list(object({
        key    = string
        values = list(string)
      })))

      string_ends_with = optional(list(object({
        key    = string
        values = list(string)
      })))

      string_not_ends_with = optional(list(object({
        key    = string
        values = list(string)
      })))

      string_contains = optional(list(object({
        key    = string
        values = list(string)
      })))

      string_not_contains = optional(list(object({
        key    = string
        values = list(string)
      })))

      string_in = optional(list(object({
        key    = string
        values = list(string)
      })))

      string_not_in = optional(list(object({
        key    = string
        values = list(string)
      })))

      is_not_null = optional(list(object({
        key = string
      })))

      is_null_or_undefined = optional(list(object({
        key = string
      })))
    }))
  }))

  default = {}
}