# Account-level (shared) connections
module "account_connection" {
  source = "./modules/account_connection"

  account_connections = var.account_connections
  account_ids         = local.account_ids

  depends_on = [module.project]
}
