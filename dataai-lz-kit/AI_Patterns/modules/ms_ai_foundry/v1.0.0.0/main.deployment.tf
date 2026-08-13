# AI Foundry Model Deployments
module "deployment" {
  source = "./modules/deployment"

  ai_foundry_deployments = var.ai_foundry_deployments
  name                   = module.module_foundry.name
  account_ids            = local.account_ids
}
