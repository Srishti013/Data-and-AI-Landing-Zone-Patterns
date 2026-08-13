#############################################
## Event Grid System Topic Subscriptions
#############################################
resource "azurerm_eventgrid_system_topic_event_subscription" "this" {
  name                = var.eventgrid_system_topic_event_subscription_name
  system_topic        = var.eventgrid_system_topic_event_subscription_system_topic
  resource_group_name = var.eventgrid_system_topic_event_subscription_resource_group_name

  expiration_time_utc                  = try(var.eventgrid_system_topic_event_subscription_expiration_time_utc, null)
  event_delivery_schema                = try(var.eventgrid_system_topic_event_subscription_event_delivery_schema, null)
  eventhub_endpoint_id                 = try(var.eventgrid_system_topic_event_subscription_eventhub_endpoint_id, null)
  hybrid_connection_endpoint_id        = try(var.eventgrid_system_topic_event_subscription_hybrid_connection_endpoint_id, null)
  service_bus_queue_endpoint_id        = try(var.eventgrid_system_topic_event_subscription_service_bus_queue_endpoint_id, null)
  service_bus_topic_endpoint_id        = try(var.eventgrid_system_topic_event_subscription_service_bus_topic_endpoint_id, null)
  included_event_types                 = try(var.eventgrid_system_topic_event_subscription_included_event_types, null)
  labels                               = try(var.eventgrid_system_topic_event_subscription_labels, null)
  advanced_filtering_on_arrays_enabled = try(var.eventgrid_system_topic_event_subscription_advanced_filtering_on_arrays_enabled, null)

  dynamic "storage_queue_endpoint" {
    for_each = var.eventgrid_system_topic_event_subscription_storage_queue_endpoint == null ? [] : [var.eventgrid_system_topic_event_subscription_storage_queue_endpoint]

    content {
      storage_account_id = storage_queue_endpoint.value.storage_account_id
      queue_name         = storage_queue_endpoint.value.queue_name

      queue_message_time_to_live_in_seconds = try(
        storage_queue_endpoint.value.queue_message_time_to_live_in_seconds,
        null
      )
    }
  }

  dynamic "azure_function_endpoint" {
    for_each = var.eventgrid_system_topic_event_subscription_azure_function_endpoint == null ? [] : [var.eventgrid_system_topic_event_subscription_azure_function_endpoint]

    content {
      function_id = azure_function_endpoint.value.function_id

      max_events_per_batch = try(
        azure_function_endpoint.value.max_events_per_batch,
        null
      )

      preferred_batch_size_in_kilobytes = try(
        azure_function_endpoint.value.preferred_batch_size_in_kilobytes,
        null
      )
    }
  }

  dynamic "webhook_endpoint" {
    for_each = var.eventgrid_system_topic_event_subscription_webhook_endpoint == null ? [] : [var.eventgrid_system_topic_event_subscription_webhook_endpoint]

    content {
      url = webhook_endpoint.value.url

      base_url = try(
        webhook_endpoint.value.base_url,
        null
      )

      max_events_per_batch = try(
        webhook_endpoint.value.max_events_per_batch,
        null
      )

      preferred_batch_size_in_kilobytes = try(
        webhook_endpoint.value.preferred_batch_size_in_kilobytes,
        null
      )

      active_directory_tenant_id = try(
        webhook_endpoint.value.active_directory_tenant_id,
        null
      )

      active_directory_app_id_or_uri = try(
        webhook_endpoint.value.active_directory_app_id_or_uri,
        null
      )
    }
  }

  dynamic "subject_filter" {
    for_each = var.eventgrid_system_topic_event_subscription_subject_filter == null ? [] : [var.eventgrid_system_topic_event_subscription_subject_filter]

    content {
      subject_begins_with = try(subject_filter.value.subject_begins_with, null)
      subject_ends_with   = try(subject_filter.value.subject_ends_with, null)
      case_sensitive      = try(subject_filter.value.case_sensitive, null)
    }
  }

  dynamic "delivery_identity" {
    for_each = var.eventgrid_system_topic_event_subscription_delivery_identity == null ? [] : [var.eventgrid_system_topic_event_subscription_delivery_identity]

    content {
      type = delivery_identity.value.type

      user_assigned_identity = try(
        delivery_identity.value.user_assigned_identity,
        null
      )
    }
  }

  dynamic "delivery_property" {
    for_each = var.eventgrid_system_topic_event_subscription_delivery_property == null ? [] : var.eventgrid_system_topic_event_subscription_delivery_property

    content {
      header_name = delivery_property.value.header_name
      type        = delivery_property.value.type
      value       = try(delivery_property.value.value, null)
      source_field = try(
        delivery_property.value.source_field,
        null
      )
      secret = try(delivery_property.value.secret, null)
    }
  }

  dynamic "dead_letter_identity" {
    for_each = var.eventgrid_system_topic_event_subscription_dead_letter_identity == null ? [] : [var.eventgrid_system_topic_event_subscription_dead_letter_identity]

    content {
      type = dead_letter_identity.value.type

      user_assigned_identity = try(
        dead_letter_identity.value.user_assigned_identity,
        null
      )
    }
  }

  dynamic "storage_blob_dead_letter_destination" {
    for_each = var.eventgrid_system_topic_event_subscription_storage_blob_dead_letter_destination == null ? [] : [var.eventgrid_system_topic_event_subscription_storage_blob_dead_letter_destination]

    content {
      storage_account_id          = storage_blob_dead_letter_destination.value.storage_account_id
      storage_blob_container_name = storage_blob_dead_letter_destination.value.storage_blob_container_name
    }
  }

  dynamic "retry_policy" {
    for_each = var.eventgrid_system_topic_event_subscription_retry_policy == null ? [] : [var.eventgrid_system_topic_event_subscription_retry_policy]

    content {
      max_delivery_attempts = retry_policy.value.max_delivery_attempts
      event_time_to_live    = retry_policy.value.event_time_to_live
    }
  }

  dynamic "advanced_filter" {
    for_each = var.eventgrid_system_topic_event_subscription_advanced_filter == null ? [] : [var.eventgrid_system_topic_event_subscription_advanced_filter]

    content {
      dynamic "bool_equals" {
        for_each = try(advanced_filter.value.bool_equals, null) == null ? [] : advanced_filter.value.bool_equals
        content {
          key   = bool_equals.value.key
          value = bool_equals.value.value
        }
      }

      dynamic "number_greater_than" {
        for_each = try(advanced_filter.value.number_greater_than, null) == null ? [] : advanced_filter.value.number_greater_than
        content {
          key   = number_greater_than.value.key
          value = number_greater_than.value.value
        }
      }

      dynamic "number_greater_than_or_equals" {
        for_each = try(advanced_filter.value.number_greater_than_or_equals, null) == null ? [] : advanced_filter.value.number_greater_than_or_equals
        content {
          key   = number_greater_than_or_equals.value.key
          value = number_greater_than_or_equals.value.value
        }
      }

      dynamic "number_less_than" {
        for_each = try(advanced_filter.value.number_less_than, null) == null ? [] : advanced_filter.value.number_less_than
        content {
          key   = number_less_than.value.key
          value = number_less_than.value.value
        }
      }

      dynamic "number_less_than_or_equals" {
        for_each = try(advanced_filter.value.number_less_than_or_equals, null) == null ? [] : advanced_filter.value.number_less_than_or_equals
        content {
          key   = number_less_than_or_equals.value.key
          value = number_less_than_or_equals.value.value
        }
      }

      dynamic "number_in" {
        for_each = try(advanced_filter.value.number_in, null) == null ? [] : advanced_filter.value.number_in
        content {
          key    = number_in.value.key
          values = number_in.value.values
        }
      }

      dynamic "number_not_in" {
        for_each = try(advanced_filter.value.number_not_in, null) == null ? [] : advanced_filter.value.number_not_in
        content {
          key    = number_not_in.value.key
          values = number_not_in.value.values
        }
      }

      dynamic "number_in_range" {
        for_each = try(advanced_filter.value.number_in_range, null) == null ? [] : advanced_filter.value.number_in_range
        content {
          key    = number_in_range.value.key
          values = number_in_range.value.values
        }
      }

      dynamic "number_not_in_range" {
        for_each = try(advanced_filter.value.number_not_in_range, null) == null ? [] : advanced_filter.value.number_not_in_range
        content {
          key    = number_not_in_range.value.key
          values = number_not_in_range.value.values
        }
      }

      dynamic "string_begins_with" {
        for_each = try(advanced_filter.value.string_begins_with, null) == null ? [] : advanced_filter.value.string_begins_with
        content {
          key    = string_begins_with.value.key
          values = string_begins_with.value.values
        }
      }

      dynamic "string_not_begins_with" {
        for_each = try(advanced_filter.value.string_not_begins_with, null) == null ? [] : advanced_filter.value.string_not_begins_with
        content {
          key    = string_not_begins_with.value.key
          values = string_not_begins_with.value.values
        }
      }

      dynamic "string_ends_with" {
        for_each = try(advanced_filter.value.string_ends_with, null) == null ? [] : advanced_filter.value.string_ends_with
        content {
          key    = string_ends_with.value.key
          values = string_ends_with.value.values
        }
      }

      dynamic "string_not_ends_with" {
        for_each = try(advanced_filter.value.string_not_ends_with, null) == null ? [] : advanced_filter.value.string_not_ends_with
        content {
          key    = string_not_ends_with.value.key
          values = string_not_ends_with.value.values
        }
      }

      dynamic "string_contains" {
        for_each = try(advanced_filter.value.string_contains, null) == null ? [] : advanced_filter.value.string_contains
        content {
          key    = string_contains.value.key
          values = string_contains.value.values
        }
      }

      dynamic "string_not_contains" {
        for_each = try(advanced_filter.value.string_not_contains, null) == null ? [] : advanced_filter.value.string_not_contains
        content {
          key    = string_not_contains.value.key
          values = string_not_contains.value.values
        }
      }

      dynamic "string_in" {
        for_each = try(advanced_filter.value.string_in, null) == null ? [] : advanced_filter.value.string_in
        content {
          key    = string_in.value.key
          values = string_in.value.values
        }
      }

      dynamic "string_not_in" {
        for_each = try(advanced_filter.value.string_not_in, null) == null ? [] : advanced_filter.value.string_not_in
        content {
          key    = string_not_in.value.key
          values = string_not_in.value.values
        }
      }

      dynamic "is_not_null" {
        for_each = try(advanced_filter.value.is_not_null, null) == null ? [] : advanced_filter.value.is_not_null
        content {
          key = is_not_null.value.key
        }
      }

      dynamic "is_null_or_undefined" {
        for_each = try(advanced_filter.value.is_null_or_undefined, null) == null ? [] : advanced_filter.value.is_null_or_undefined
        content {
          key = is_null_or_undefined.value.key
        }
      }
    }
  }
}