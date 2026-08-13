output "resource" {
  description = <<-EOT
  This is the full output for the Managed Redis resource. This is the default output for the module following AVM standards.
  Examples:
  - module.managed_redis.resource.id
  - module.managed_redis.resource.name
  - module.managed_redis.resource.hostname
EOT
  sensitive   = true
  value       = azurerm_managed_redis.this
}

output "resource_id" {
  description = "The resource ID of the Managed Redis instance."
  value       = azurerm_managed_redis.this.id
}

output "diagnostic_setting_ids" {
  description = "A map of diagnostic setting keys to their resource IDs."
  value       = { for k, v in azurerm_monitor_diagnostic_setting.this : k => v.id }
}

output "hostname" {
  description = "DNS name of the Managed Redis cluster endpoint."
  value       = azurerm_managed_redis.this.hostname
}