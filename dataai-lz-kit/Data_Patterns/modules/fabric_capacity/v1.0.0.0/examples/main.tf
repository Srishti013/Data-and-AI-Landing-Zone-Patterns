locals {
  #deployment_region = module.regions.regions[random_integer.region_index.result].name
  deployment_region = "malaysiawest" #temporarily pinning on single region
  tags = {
    scenario = "Default"
  }
}

module "fabric_capacity" {
  source = "../"

  # Naming module required variables
  env                = "prod"
  au                 = "00121"
  app_code           = "mgmt"
  bu                 = "it"
  owner              = "CEAT"
  resource_type_code = "fc"

  # Optional naming variables
  org             = "mbb"
  region_code     = "myw"
  base_name       = null
  additional_name = null
  iterator        = "01"
  max_length      = 128
  no_dashes       = false
  add_random      = false
  rnd_length      = 2

  # Mandatory Tags (8 mandatory tags for naming module)
  environment         = "Prod"
  business_owner      = "Head of Cloud Engineering and Automation"
  business_unit       = "GTD-ISD"
  criticality         = "T1"
  cost_center         = "383-80572"
  data_classification = "Business Sensitive"
  compliance          = "BNM RMIT"

  # Additional mandatory tag variables
  app_name  = "Automation, Monitoring and Management"
  budget_id = "83254"
  status    = "Live"
  service   = "Fabric Capacity"

  # Optional tags
  region               = "MYW"
  description          = "Azure Fabric capacity for management"
  notification_emails  = ["mss_ceat@maybank.com"]
  app_support          = "mss_ceat@maybank.com"
  product_version      = "1.0.0.0"
  type                 = "Infrastructure"
  cost_allocation_unit = "383-80572"
  budget_limit         = "TBD"
  cost_alert_threshold = "80"
  compliance_required  = "true"

  # Optional conditional tags (set to "" to exclude)
  delete_after       = ""
  tier               = ""
  app_id             = ""
  auto_delete        = ""
  auto_shutdown      = ""
  disaster_recovery  = ""
  integration_id     = ""
  experiment_phase   = ""
  last_vm_accessed   = ""
  maintenance_window = ""
  patch_policy       = ""
  retention          = ""
  sandbox_type       = ""

  # Fabric Capacity specific variables
  resource_group_name    = var.resource_group_name
  administration_members = var.administration_members
  sku_name               = var.sku_name

  additional_tags = null
}
