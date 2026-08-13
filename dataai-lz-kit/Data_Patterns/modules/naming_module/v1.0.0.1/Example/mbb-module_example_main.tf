module "module_rg" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
  # Local use
  source = "../" # path of your local repo

  # Required naming inputs
  env                = "core"
  au                 = "00121"
  owner              = "test@test.com"
  resource_type_code = "rg"
  product_version    = "1.0.0"
  app_code           = "mgmt"
  bu                 = "it"

  # Optional naming inputs
  org             = "mbb"
  region_code     = "sea"
  base_name       = "module"
  additional_name = ""
  iterator        = "001"

  # Required mandatory tags
  environment         = "Prod"
  business_owner      = "Head of Cloud Engineering and Automation"
  business_unit       = "GTD-ISD"
  criticality         = "Medium"
  cost_center         = "383-80572"
  data_classification = "Business Sensitive"
  compliance          = "BNM RMIT"

  # Optional tags
  region              = "SEA"
  description         = "Naming module resource group example"
  notification_emails = ["mss_ceat@maybank.com"]
  compliance_required = "Yes"

  # Additional tags
  additional_tags = {
    app_id  = "XXYY"
    test_by = "emberger"
  }

  # Optional tuning
  max_length = 64
  no_dashes  = false
  add_random = true
  rnd_length = 4
}

# Test by creating a Resource Group with the module's outputs
resource "azurerm_resource_group" "this" {
  name     = module.module_rg.name
  location = module.module_rg.location

  tags = module.module_rg.tags
}
