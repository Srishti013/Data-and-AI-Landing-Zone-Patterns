########################################
## Role Assignments
## (Account identity → Storage, Search, Cosmos)
########################################
resource "azurerm_role_assignment" "foundry_account" {
  for_each = var.role_assignments != null ? var.role_assignments : {}

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = try(each.value.description, "")
}

########################################
## Cosmos DB SQL Role Assignments
## (Account identity - data plane access)
########################################
resource "azurerm_cosmosdb_sql_role_assignment" "foundry_account" {
  for_each = var.cosmos_role_assignments != null ? var.cosmos_role_assignments : {}

  resource_group_name = each.value.resource_group_name
  account_name        = each.value.cosmos_account_name
  role_definition_id  = each.value.role_definition_id
  principal_id        = each.value.principal_id
  scope               = each.value.scope
}

########################################
## Wait for Role Assignments to propagate
########################################
resource "time_sleep" "wait_for_rbac" {
  count = length(var.role_assignments) > 0 || length(var.cosmos_role_assignments) > 0 ? 1 : 0

  depends_on = [
    azurerm_role_assignment.foundry_account,
    azurerm_cosmosdb_sql_role_assignment.foundry_account
  ]
  create_duration = var.wait_after_role_assignments
}

########################################
## Project Role Assignments
## (Project identity → Storage, Search, Cosmos
##  BEFORE capability host creation)
########################################
resource "azurerm_role_assignment" "project" {
  for_each = var.project_role_assignments != null ? var.project_role_assignments : {}

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = try(each.value.description, "")
}

########################################
## Wait for Project Role Assignments
########################################
resource "time_sleep" "wait_for_project_rbac" {
  count = length(var.project_role_assignments) > 0 ? 1 : 0

  depends_on = [
    azurerm_role_assignment.project,
  ]
  create_duration = var.wait_after_role_assignments
}

