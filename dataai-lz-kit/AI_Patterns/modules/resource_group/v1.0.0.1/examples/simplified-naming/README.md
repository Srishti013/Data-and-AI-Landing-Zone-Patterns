# Example: Resource Group with Simplified Naming Module v1.0.0.1

This example demonstrates how to use the MBB Resource Group Module v1.0.0.1 with the simplified naming module.

## Configuration

```hcl
module "resource_group_example" {
  source = "../../"

  # Required Naming Variables
  env      = "p"
  app_code = "demo"
  bu       = "IT"
  au       = "12345"
  
  # Optional Naming Variables
  region_code = "sg"  # Singapore
  base_name   = "example"
  
  # 8 Mandatory Tags for v1.0.0.1 Naming Module (mapped from existing vars)
  # environment         = var.env (mapped automatically)
  # business_owner      = var.owner (mapped automatically)
  business_unit       = "IT Department"
  criticality         = "High"
  cost_center         = "CC-12345"
  data_classification = "Internal"
  compliance          = "SOX"
  
  # 3 Optional Tags for v1.0.0.1 Naming Module
  region              = "Singapore"
  description         = "Example production resource group"
  notification_emails = ["admin@company.com"]
  
  # Additional Required Tags
  app_name    = "Demo Application"
  budget_id   = "BUD-2024-001"
  status      = "Live"
  app_support = "support@company.com"
  
  # Additional Optional Tags
  automation_policy = "Standard"
  review_required   = "Yes"
  backup_policy     = "Daily"
  disaster_recovery = "Standard"
}
```

## Expected Results

- **Resource Group Name**: `mbb-rg-demo-p-sg-example`
- **Location**: `Singapore`
- **Tags**: 
  - 8 core naming module tags
  - 4 additional required tags
  - 4 additional optional tags
  - System generated CreatedOn tag