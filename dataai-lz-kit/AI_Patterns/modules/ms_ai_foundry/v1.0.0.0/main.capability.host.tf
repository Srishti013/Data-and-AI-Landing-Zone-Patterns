# Capability Hosts (account + project) + post-capability-host role assignments
module "capability_host" {
  source = "./modules/capability_host"

  account_ids                      = local.account_ids
  project_ids                      = module.project.project_ids
  project_internal_ids             = module.project.project_internal_ids
  account_capability_hosts         = var.account_capability_hosts
  project_capability_hosts         = var.project_capability_hosts
  project_cosmos_role_assignments  = var.project_cosmos_role_assignments
  post_ch_storage_role_assignments = var.post_ch_storage_role_assignments
  wait_after_account_creation      = var.wait_after_account_creation

  depends_on = [
    module.project,
    module.project_connection,
    module.account_connection,
    module.rbac
  ]
}
