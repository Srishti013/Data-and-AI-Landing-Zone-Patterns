module "resource_group_example" {
  source = "../../"

  # Required Naming Variables  
  env                = "p"
  app_code           = "demo"
  bu                 = "IT"
  au                 = "12345"
  owner              = "platform-team@company.com"
  resource_type_code = "rg"
  product_version    = "1.0.0"

  # Required Finance Variables
  cost_center          = "CC-12345"
  budget_id            = "BUD-2024-001"
  budget_limit         = "10000"
  cost_alert_threshold = "8000"

  # Optional Naming Variables
  region_code = "sg" # Singapore
  base_name   = "example"

  # Required Business Tags
  app_name       = "Demo Application"
  app_support    = "support@company.com"
  business_unit  = "IT Department"
  business_owner = "John Doe"

  # Required Governance Tags
  data_classification = "Internal"
  compliance          = "SOX"

  # Required Operation Tags
  criticality = "High"
  environment = "Production"
  status      = "Live"

  # Optional Tags
  region              = "Singapore"
  description         = "Example production resource group"
  notification_emails = ["admin@company.com"]

  # Additional Optional Tags (v1.0.0.1 specific)
  automation_policy = "Standard"
  review_required   = "Yes"
  backup_policy     = "Daily"
  disaster_recovery = "Standard"
}

output "resource_group_name" {
  value = module.resource_group_example.name
}

output "resource_group_id" {
  value = module.resource_group_example.resource_id
}