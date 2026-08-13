locals {
  # AI Foundry account ARM ids (account resource lives in the root: main.foundry.account.tf)
  account_ids = { for k, v in azapi_resource.ai_foundry : k => v.id }
}
