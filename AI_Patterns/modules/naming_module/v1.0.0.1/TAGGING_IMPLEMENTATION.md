# MBB Naming Module - Tagging Implementation Summary

## Changes Made

The mbb_naming_module has been updated to enforce a comprehensive tagging strategy aligned with Maybank's governance requirements.

## What Was Added

### 1. **Comprehensive Tag Variables** (variables.tf)
Added 40+ new tag variables across 5 categories:

#### Mandatory Tags for Resources:
- **Business**: AppName, AppSupport, BusinessUnit, Country, BusinessOwner, Type
- **DevOps**: ProductName, ProductVersion  
- **Finance**: CostCenter, CostAllocationUnit, BudgetID, BudgetLimit, CostAlertThreshold
- **Governance**: DataClassification, ComplianceRequired, Compliance
- **Operation**: Criticality, Environment, Owner, Status

#### Optional Tags:
- **Governance**: DeleteAfter, Tier, ReviewRequired
- **Operation**: AppId, AutoDelete, AutoshutDown, BackupPolicy, DisasterRecovery, MaintenanceWindow, NotificationEmails, OS, PatchPolicy, Region, Retention, SandboxType, Service, and more
- **Subscription-Only**: LandingZone, PlatformArea

### 2. **Enhanced Tag Generation Logic** (main.tf)
- Creates `mandatory_tags` block with all required tags
- Creates `optional_tags` block for optional tags
- Filters out empty optional tags automatically
- Merges all tags with `additional_tags` for final output

### 3. **Built-in Validation**
- Email format validation for `app_support`
- Enum validation for:
  - `data_classification`: Public, Internal, Confidential, Restricted
  - `criticality`: Low, Medium, High, Critical
  - `environment`: dev, test, uat, stage, prod, nonprod, core
  - `status`: Live, Non-Operational, Decommissioned
  - `compliance_required`, `auto_delete`, `review_required`: Yes/No

### 4. **Sensible Defaults**
- `data_classification` = "Internal"
- `criticality` = "Medium"
- `status` = "Live"
- `type` = "Infrastructure"
- `compliance_required` = "No"
- `compliance` = "None"
- `country` = "th"

### 5. **Examples and Documentation**
Created comprehensive examples in `/examples` folder:
- `resource_group_example.tf` - Complete RG deployment with tags
- `virtual_machine_example.tf` - VM deployment with optional tags
- `subscription_tagging.md` - Subscription-level tagging guide
- `TAGGING_STRATEGY.md` - Complete tagging documentation

## Key Features

### ✅ Scope-Aware Tagging
- **Resource-level deployments**: Only resource-applicable tags are mandatory
- **RG-level deployments**: RG-specific tags required
- **Subscription-level**: Subscription tags (LandingZone, PlatformArea) required

### ✅ Automatic Filtering
Empty optional tags are automatically filtered out, keeping tag sets clean.

### ✅ Backward Compatibility
Existing functionality preserved:
- Name generation logic unchanged
- Location mapping still works
- `additional_tags` still supported

## Usage Example

```hcl
module "naming" {
  source = "../../mbb_naming_module/v1.0.0.0"

  # Existing naming parameters
  env                = "dev"
  org                = "mbb"
  region_code        = "sea"
  base_name          = "app"
  resource_type_code = "rg"
  au                 = "00121"
  app_code           = "webapp"
  bu                 = "it"
  owner              = "owner@maybank.com"

  # NEW: Mandatory Business Tags
  app_name       = "My Application"
  app_support    = "support@maybank.com"
  business_unit  = "IT Department"
  country        = "MY"
  business_owner = "John Doe"
  type           = "Application"

  # NEW: Mandatory DevOps Tags
  product_name    = "mbb_resource_group"
  product_version = "1.0.0"

  # NEW: Mandatory Finance Tags
  cost_center          = "CC-12345"
  cost_allocation_unit = "CAU-IT"
  budget_id            = "BDG-2025"
  budget_limit         = "50000"
  cost_alert_threshold = "40000"

  # NEW: Mandatory Governance Tags
  data_classification = "Internal"
  compliance_required = "Yes"
  compliance          = "ISO 27001"

  # NEW: Mandatory Operation Tags
  criticality = "High"
  environment = "dev"
  status      = "Live"

  # Optional tags (only if needed)
  tier      = "web-tier"
  app_id    = "APP-12345"
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.name
  location = module.naming.location
  tags     = module.naming.tags  # Now includes 20+ mandatory tags
}
```

## Migration Guide

### For Existing Modules Using mbb_naming_module

1. **Add mandatory tag variables** to your module calls
2. **Update module calls** with the new required tags
3. **Optional**: Add relevant optional tags for your resource type

### Breaking Changes
⚠️ **Warning**: This is a breaking change. Existing module calls will fail validation without the new mandatory tags.

### Recommended Approach
1. Update one module at a time
2. Use sensible defaults where applicable
3. Refer to examples for guidance

## Files Modified

1. `variables.tf` - Added 40+ new tag variables with validation
2. `main.tf` - Enhanced tag generation with filtering logic
3. `examples/` - Added 4 new example files
4. Created this summary document

## Next Steps

1. ✅ Test the module with a sample deployment
2. ✅ Update dependent modules (like mbb_resource_group)
3. ✅ Document migration path for existing deployments
4. ✅ Create Terraform validation tests

## Questions or Issues?

Refer to:
- [TAGGING_STRATEGY.md](./examples/TAGGING_STRATEGY.md) for complete tag documentation
- [Examples folder](./examples/) for usage patterns
- Module's README.md for technical details
