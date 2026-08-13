##############################################
## Event Grid System Topic Event Subscription
##############################################
module "system_topic_event_subscriptions" {
  for_each = var.eventgrid_system_topic_event_subscriptions
  source   = "./modules/system_subscription"

  eventgrid_system_topic_event_subscription_name                = each.value.eventgrid_system_topic_event_subscription_name
  eventgrid_system_topic_event_subscription_system_topic        = azurerm_eventgrid_system_topic.this.name
  eventgrid_system_topic_event_subscription_resource_group_name = each.value.eventgrid_system_topic_event_subscription_resource_group_name

  eventgrid_system_topic_event_subscription_expiration_time_utc                  = try(each.value.eventgrid_system_topic_event_subscription_expiration_time_utc, null)
  eventgrid_system_topic_event_subscription_event_delivery_schema                = try(each.value.eventgrid_system_topic_event_subscription_event_delivery_schema, null)
  eventgrid_system_topic_event_subscription_eventhub_endpoint_id                 = try(each.value.eventgrid_system_topic_event_subscription_eventhub_endpoint_id, null)
  eventgrid_system_topic_event_subscription_hybrid_connection_endpoint_id        = try(each.value.eventgrid_system_topic_event_subscription_hybrid_connection_endpoint_id, null)
  eventgrid_system_topic_event_subscription_service_bus_queue_endpoint_id        = try(each.value.eventgrid_system_topic_event_subscription_service_bus_queue_endpoint_id, null)
  eventgrid_system_topic_event_subscription_service_bus_topic_endpoint_id        = try(each.value.eventgrid_system_topic_event_subscription_service_bus_topic_endpoint_id, null)
  eventgrid_system_topic_event_subscription_included_event_types                 = try(each.value.eventgrid_system_topic_event_subscription_included_event_types, null)
  eventgrid_system_topic_event_subscription_labels                               = try(each.value.eventgrid_system_topic_event_subscription_labels, null)
  eventgrid_system_topic_event_subscription_advanced_filtering_on_arrays_enabled = try(each.value.eventgrid_system_topic_event_subscription_advanced_filtering_on_arrays_enabled, null)

  eventgrid_system_topic_event_subscription_storage_queue_endpoint = try(
    each.value.eventgrid_system_topic_event_subscription_storage_queue_endpoint,
    null
  )

  eventgrid_system_topic_event_subscription_azure_function_endpoint = try(
    each.value.eventgrid_system_topic_event_subscription_azure_function_endpoint,
    null
  )

  eventgrid_system_topic_event_subscription_webhook_endpoint = try(
    each.value.eventgrid_system_topic_event_subscription_webhook_endpoint,
    null
  )

  eventgrid_system_topic_event_subscription_subject_filter = try(
    each.value.eventgrid_system_topic_event_subscription_subject_filter,
    null
  )

  eventgrid_system_topic_event_subscription_delivery_identity = try(
    each.value.eventgrid_system_topic_event_subscription_delivery_identity,
    null
  )

  eventgrid_system_topic_event_subscription_delivery_property = try(
    each.value.eventgrid_system_topic_event_subscription_delivery_property,
    null
  )

  eventgrid_system_topic_event_subscription_dead_letter_identity = try(
    each.value.eventgrid_system_topic_event_subscription_dead_letter_identity,
    null
  )

  eventgrid_system_topic_event_subscription_storage_blob_dead_letter_destination = try(
    each.value.eventgrid_system_topic_event_subscription_storage_blob_dead_letter_destination,
    null
  )

  eventgrid_system_topic_event_subscription_retry_policy = try(
    each.value.eventgrid_system_topic_event_subscription_retry_policy,
    null
  )

  eventgrid_system_topic_event_subscription_advanced_filter = try(
    each.value.eventgrid_system_topic_event_subscription_advanced_filter,
    null
  )
}