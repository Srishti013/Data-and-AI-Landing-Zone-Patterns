# AI Foundry RAI Policies
module "rai_policy" {
  source = "./modules/rai_policy"

  ai_foundry_rai_policy = var.ai_foundry_rai_policy
  name                  = module.module_foundry.name
  account_ids           = local.account_ids
}
