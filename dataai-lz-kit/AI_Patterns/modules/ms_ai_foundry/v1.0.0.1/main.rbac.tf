# Role Assignments (account + cosmos + project identities) with RBAC propagation waits
module "rbac" {
  source = "./modules/rbac"

  role_assignments            = var.role_assignments
  cosmos_role_assignments     = var.cosmos_role_assignments
  project_role_assignments    = var.project_role_assignments
  wait_after_role_assignments = var.wait_after_role_assignments

  depends_on = [module.private_endpoint]
}
