# AI Foundry Projects (+ diagnostics)
module "project" {
  source = "./modules/project"

  ai_foundry_projects = var.ai_foundry_projects
  location            = module.module_foundry.location
  account_ids         = local.account_ids
}
