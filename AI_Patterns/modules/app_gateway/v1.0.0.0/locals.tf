locals {
  frontend_ip_configuration_name         = "${module.module_appgw.name}-feip"
  frontend_ip_configuration_private_name = "${module.module_appgw.name}-fepvt-ip"
  gateway_ip_configuration_name          = "${module.module_appgw.name}-gwipc"
  identity_required                      = var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0
  managed_identities = {
    type = (
      var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" :
      var.managed_identities.system_assigned ? "SystemAssigned" :
      "UserAssigned"
    )
    identity_ids = (
      length(var.managed_identities.user_assigned_resource_ids) > 0 ? var.managed_identities.user_assigned_resource_ids : null
    )
  }
  public_ip_name                     = "pip-${module.module_appgw.name}"
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  # Tags are now handled by the naming module
}
