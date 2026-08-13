output "eventgrid_system_topic_id" {
  description = "Event Grid System Topic ID"
  value       = azurerm_eventgrid_system_topic.this.id
}

output "eventgrid_system_topic_name" {
  description = "Event Grid System Topic name"
  value       = azurerm_eventgrid_system_topic.this.name
}

output "eventgrid_system_topic_resource_group" {
  description = "Event Grid System Topic resource group"
  value       = azurerm_eventgrid_system_topic.this.resource_group_name
}

output "eventgrid_system_topic_location" {
  description = "Event Grid System Topic location"
  value       = azurerm_eventgrid_system_topic.this.location
}
