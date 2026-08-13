output "id" {
  description = "Private endpoint ARM id (null when not created)."
  value       = try(azurerm_private_endpoint.ai_foundry[0].id, null)
}
