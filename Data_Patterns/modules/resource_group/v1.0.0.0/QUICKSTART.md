# Quick Start - Updated Resource Group Module

## What's New? 🆕

The `resource_group` module now enforces **comprehensive tagging** with 25+ mandatory tags across Business, DevOps, Finance, Governance, and Operation categories.

## Minimal Working Example

```hcl
module "my_rg" {
  source = "path/to/resource_group/v1.0.0.0"

  # --- Basic Naming ---
  env                = "dev"
  au                 = "00121"
  app_code           = "myapp"
  bu                 = "it"
  owner              = "owner@example.com"
  resource_type_code = "rg"
  base_name          = "application"

  # --- Mandatory Business Tags ---
  app_name       = "My Application"
  app_support    = "support@example.com"  # Must be valid email
  business_unit  = "IT Department"
  country        = "MY"
  business_owner = "John Doe"

  # --- Mandatory DevOps Tags ---
  product_version = "1.0.0"  # Your app/infrastructure version

  # --- Mandatory Finance Tags ---
  cost_center          = "CC-12345"
  cost_allocation_unit = "CAU-IT-001"
  budget_id            = "BDG-2025-001"
  budget_limit         = "50000"
  cost_alert_threshold = "40000"

  # --- Mandatory Governance Tags ---
  data_classification = "Internal"  # Public | Internal | Confidential | Restricted

  # --- Mandatory Operation Tags ---
  criticality = "Medium"  # Low | Medium | High | Critical
  environment = "dev"     # dev | test | uat | stage | prod | nonprod | core
}
```

## What You Get

This creates a resource group with:
- ✅ **Standardized name** following {org} conventions
- ✅ **Azure location** mapped from region code
- ✅ **25+ tags** automatically applied and validated
- ✅ **Compliance** with governance standards

## Common Optional Tags

Add these if needed for your resource group:

```hcl
  # Optional tags
  tier                = "web-tier"
  app_id              = "APP-12345"
  auto_delete         = "No"
  description         = "My application resource group"
  backup_policy       = "Daily"
  disaster_recovery   = "RTO-4h"
  notification_emails = "alerts@example.com"
```

## Default Values

These tags have defaults (override if needed):
- `type` = "Infrastructure"
- `product_name` = "resource_group"
- `compliance_required` = "No"
- `compliance` = "None"
- `status` = "Live"

## Validation Rules

✅ **Email format** - `app_support` must be a valid email  
✅ **Data classification** - Must be: Public, Internal, Confidential, or Restricted  
✅ **Criticality** - Must be: Low, Medium, High, or Critical  
✅ **Environment** - Must be: dev, test, uat, stage, prod, nonprod, or core  
✅ **Status** - Must be: Live, Non-Operational, or Decommissioned  

## Complete Documentation

- **📖 Full Migration Guide**: [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
- **📋 Update Summary**: [UPDATE_SUMMARY.md](./UPDATE_SUMMARY.md)
- **💡 Tagging Strategy**: `../../naming_module/v1.0.0.0/examples/TAGGING_STRATEGY.md`
- **🔧 Examples**: [examples/comprehensive-tagging/](./examples/comprehensive-tagging/)

## Need Help?

1. Check the [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) for detailed examples
2. Review the tagging strategy documentation in the naming module
3. Run `terraform plan` to see validation errors before applying

---

**Status**: ✅ Ready to use - All validations passing
