# AI Foundry Project Connections (Cosmos DB, AI Search, Storage, etc.)
module "project_connection" {
  source = "./modules/project_connection"

  ai_foundry_project_connections = var.ai_foundry_project_connections
  project_ids                    = module.project.project_ids
}
