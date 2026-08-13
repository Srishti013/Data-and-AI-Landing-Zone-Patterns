################################################################
### Variables for Event Grid System Topic Event Subscription
################################################################

variable "eventgrid_system_topic_event_subscription_name" {
  description = "Name of the Event Grid System Topic Event Subscription"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_system_topic" {
  description = "Name of the Event Grid System Topic"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_resource_group_name" {
  description = "Resource Group name for the Event Grid System Topic Event Subscription"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_expiration_time_utc" {
  description = "Expiration time in UTC for the Event Subscription"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_event_delivery_schema" {
  description = "Event delivery schema for the Event Subscription"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_eventhub_endpoint_id" {
  description = "Event Hub endpoint ID"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_hybrid_connection_endpoint_id" {
  description = "Hybrid Connection endpoint ID"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_service_bus_queue_endpoint_id" {
  description = "Service Bus Queue endpoint ID"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_service_bus_topic_endpoint_id" {
  description = "Service Bus Topic endpoint ID"
  type        = string
  default     = null
}

variable "eventgrid_system_topic_event_subscription_included_event_types" {
  description = "Included event types"
  type        = list(string)
  default     = null
}

variable "eventgrid_system_topic_event_subscription_labels" {
  description = "Labels for the event subscription"
  type        = list(string)
  default     = null
}

variable "eventgrid_system_topic_event_subscription_advanced_filtering_on_arrays_enabled" {
  description = "Enable advanced filtering on arrays"
  type        = bool
  default     = null
}

variable "eventgrid_system_topic_event_subscription_storage_queue_endpoint" {
  description = "Storage Queue endpoint configuration"
  type = object({
    storage_account_id                    = string
    queue_name                            = string
    queue_message_time_to_live_in_seconds = optional(number)
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_azure_function_endpoint" {
  description = "Azure Function endpoint configuration"
  type = object({
    function_id                       = string
    max_events_per_batch              = optional(number)
    preferred_batch_size_in_kilobytes = optional(number)
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_webhook_endpoint" {
  description = "Webhook endpoint configuration"
  type = object({
    url                               = string
    base_url                          = optional(string)
    max_events_per_batch              = optional(number)
    preferred_batch_size_in_kilobytes = optional(number)
    active_directory_tenant_id        = optional(string)
    active_directory_app_id_or_uri    = optional(string)
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_subject_filter" {
  description = "Subject filter configuration"
  type = object({
    subject_begins_with = optional(string)
    subject_ends_with   = optional(string)
    case_sensitive      = optional(bool)
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_delivery_identity" {
  description = "Delivery identity configuration"
  type = object({
    type                   = string
    user_assigned_identity = optional(string)
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_delivery_property" {
  description = "Delivery property configuration"
  type = list(object({
    header_name  = string
    type         = string
    value        = optional(string)
    source_field = optional(string)
    secret       = optional(bool)
  }))
  default = null
}

variable "eventgrid_system_topic_event_subscription_dead_letter_identity" {
  description = "Dead letter identity configuration"
  type = object({
    type                   = string
    user_assigned_identity = optional(string)
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_storage_blob_dead_letter_destination" {
  description = "Storage blob dead letter destination configuration"
  type = object({
    storage_account_id          = string
    storage_blob_container_name = string
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_retry_policy" {
  description = "Retry policy configuration"
  type = object({
    max_delivery_attempts = number
    event_time_to_live    = number
  })
  default = null
}

variable "eventgrid_system_topic_event_subscription_advanced_filter" {
  description = "Advanced filter configuration"
  type = object({
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
  })
  default = null
}