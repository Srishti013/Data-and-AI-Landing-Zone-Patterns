# Resource Group Module - Updated for Comprehensive Tagging

## Overview

The `resource_group` module has been updated to integrate with the enhanced `naming_module` that enforces comprehensive tagging standards.

## What Changed

### 1. **Enhanced Integration with Naming Module**
The module now passes all mandatory and optional tag variables to the naming module, which handles:
- Tag generation with validation
- Automatic filtering of empty optional tags
- Tag merging with additional_tags

### 2. **New Mandatory Variables**
Added comprehensive mandatory tag variables:

#### Business Tags
- `app_name` - Human readable application name
- `app_support` - Support team email (validated)
- `business_unit` - Department that owns the resources
- `business_owner` - Contact name of the owner
- `type` - Infrastructure or business service type

#### DevOps Tags
- `product_name` - Terraform module name (defaults to "resource_group")
- `product_version` - Module version

#### Finance Tags
- `cost_center` - Cost center bearing the costs
- `cost_allocation_unit` - Logical bucket for shared costs
- `budget_id` - Budget or GL code
- `budget_limit` - Maximum budget allocated
- `cost_alert_threshold` - Cost threshold for alerts

#### Governance Tags
- `data_classification` - Data classification level (Public/Internal/Confidential/Restricted)
- `compliance_required` - Whether compliance is required (Yes/No)
- `compliance` - Specific standards (defaults to "None")

#### Operation Tags
- `criticality` - Workload SLA requirements (Low/Medium/High/Critical)
- `environment` - Environment (dev/test/uat/stage/prod)
- `status` - Status (Live/Non-Operational/Decommissioned)

### 3. **Optional Variables**
Added optional tag variables for resource groups:
- `delete_after` - Date for deletion
- `tier` - Network tier
- `app_id` - Application ID from CMDB
- `auto_delete` - Auto-delete flag
- `auto_shutdown` - Auto-shutdown configuration
- `description` - Brief description
- `sandbox_purpose` - Sandbox purpose
- `review_required` - Review needed flag
- `backup_policy` - Backup policy
- `disaster_recovery` - DR requirements
- `notification_emails` - Notification email list
- `region` - Cloud region

### 4. **Simplified Tag Management**
- Removed `locals.mandatory_tags` - tags now come from the naming module
- Tags are automatically merged: `naming_module.tags + additional_tags + tags`
- Empty optional tags are filtered out automatically

## Usage

### Complete Example

```hcl
module "resource_group" {
  source = "path/to/resource_group/v1.0.0.0"

  # Naming parameters
  env                = "dev"
  org                = "{org}"
  region_code        = "sea"
  base_name          = "myapp"
  au                 = "00121"
  app_code           = "webapp"
  bu                 = "it"
  owner              = "devops@example.com"
  resource_type_code = "rg"

  # Mandatory Business Tags
  app_name       = "My Application"
  app_support    = "support@example.com"
  business_unit  = "IT Department"
  country        = "MY"
  business_owner = "John Doe"
  type           = "Application"

  # Mandatory DevOps Tags
  product_version = "1.0.0"

  # Mandatory Finance Tags
  cost_center          = "CC-12345"
  cost_allocation_unit = "CAU-IT-001"
  budget_id            = "BDG-2025-001"
  budget_limit         = "50000"
  cost_alert_threshold = "40000"

  # Mandatory Governance Tags
  data_classification = "Internal"
  compliance_required = "Yes"
  compliance          = "ISO 27001"

  # Mandatory Operation Tags
  criticality = "High"
  environment = "dev"
  status      = "Live"

  # Optional tags
  tier                = "web-tier"
  backup_policy       = "Daily"
  notification_emails = "alerts@example.com"
}
```

### Minimal Example

```hcl
module "resource_group_minimal" {
  source = "path/to/resource_group/v1.0.0.0"

  # Basic naming
  env                = "dev"
  au                 = "00121"
  app_code           = "app"
  bu                 = "it"
  owner              = "owner@example.com"
  resource_type_code = "rg"
  base_name          = "minimal"

  # Mandatory tags (minimal required)
  app_name            = "Minimal App"
  app_support         = "support@example.com"
  business_unit       = "IT"
  country             = "MY"
  business_owner      = "John Doe"
  product_version     = "1.0.0"
  cost_center         = "CC-12345"
  cost_allocation_unit = "CAU-IT"
  budget_id           = "BDG-2025"
  budget_limit        = "10000"
  cost_alert_threshold = "8000"
  data_classification  = "Internal"
  criticality         = "Medium"
  environment         = "dev"
}
```

## Migration Guide

### For Existing Deployments

1. **Update your module calls** to include all mandatory tag variables
2. **Remove manual tag definitions** - tags now come from the naming module
3. **Review default values** - some tags have sensible defaults:
   - `type` = "Infrastructure"
   - `product_name` = "resource_group"
   - `compliance_required` = "No"
   - `compliance` = "None"
   - `status` = "Live"

### Breaking Changes

⚠️ **This is a breaking change**. Existing module calls will fail without the new mandatory variables.

**Before:**
```hcl
module "rg" {
  source = "..."
  env    = "dev"
  # ... basic vars only
}
```

**After:**
```hcl
module "rg" {
  source = "..."
  env    = "dev"
  # ... basic vars ...
  
  # NEW: All mandatory tags required
  app_name            = "My App"
  app_support         = "support@example.com"
  business_unit       = "IT"
  # ... etc
}
```

## Validation

The module includes built-in validation for:
- ✅ Email format for `app_support`
- ✅ Enum values for `data_classification`, `criticality`, `environment`, `status`
- ✅ Yes/No values for boolean-style tags
- ✅ All mandatory tags must be provided

## Benefits

1. **Consistent Tagging** - All resource groups follow the same tagging standard
2. **Automatic Validation** - Invalid tag values are caught at plan time
3. **Cost Management** - Finance tags enable better cost tracking
4. **Compliance** - Governance tags support compliance requirements
5. **Operational Excellence** - Operation tags improve resource management

## Examples

See the [examples/comprehensive-tagging](./examples/comprehensive-tagging/) directory for complete working examples.

## Support

For questions or issues:
1. Review the naming module documentation: `naming_module/v1.0.0.0/examples/TAGGING_STRATEGY.md`
2. Check the examples in this module
3. Refer to the governance standards
