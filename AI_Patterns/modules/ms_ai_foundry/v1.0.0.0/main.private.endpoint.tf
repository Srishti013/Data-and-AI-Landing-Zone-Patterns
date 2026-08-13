# Private Endpoint for the AI Foundry account
module "private_endpoint" {
  source = "./modules/private_endpoint"

  private_endpoint_config = var.private_endpoint_config
  account_ids             = local.account_ids
  tags                    = module.module_foundry.tags
}
