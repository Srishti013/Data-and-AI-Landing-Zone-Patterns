# Example Usage of MBB Naming Module v1.0.0.1

## Basic Resource Group Example

```hcl
module "naming" {
  source = "../mbb_naming_module/v1.0.0.1"

  # Required Naming Variables
  resource_type_code = "rg"
  app_code          = "demo" 
  env               = "d"
  
  # 8 Mandatory Tags
  environment        = "Development"
  business_owner     = "John Doe"
  business_unit      = "IT"
  criticality        = "Medium"
  cost_center        = "12345"
  data_classification = "Internal"
  compliance         = "None"
  
  # 3 Optional Tags
  region      = "Southeast Asia"
  description = "Demo resource group for testing"
  notification_emails = ["admin@example.com", "support@example.com"]
}

resource "azurerm_resource_group" "example" {
  name     = module.naming.name
  location = module.naming.location
  tags     = module.naming.tags
}
```

## Storage Account Example

```hcl
module "naming_storage" {
  source = "../mbb_naming_module/v1.0.0.1"

  # Required Naming Variables
  resource_type_code = "st"
  app_code          = "data" 
  env               = "p"
  
  # 8 Mandatory Tags
  environment        = "Production"
  business_owner     = "Jane Smith"
  business_unit      = "Data Engineering"
  criticality        = "High"
  cost_center        = "67890"
  data_classification = "Confidential"
  compliance         = "SOX"
  
  # 3 Optional Tags
  region      = "Singapore"
  description = "Production data storage"
  notification_emails = ["dataops@example.com"]
  
  # Naming options
  region_code = "sg"  # Singapore region
  add_random = true
  no_dashes  = true  # Storage accounts don't allow dashes
}

resource "azurerm_storage_account" "example" {
  name                     = module.naming_storage.name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = module.naming_storage.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = module.naming_storage.tags
}
```

## Key Benefits of v1.0.0.1

1. **Simplified**: Only 11 total tags vs 30+ in v1.0.0.0
2. **Focused**: Contains only essential business and operational tags
3. **Consistent**: Same naming convention as v1.0.0.0
4. **Validated**: Email validation for notification_emails
5. **Clean**: No unused variables or complex tag filtering

## Migration from v1.0.0.0

When migrating from v1.0.0.0 to v1.0.0.1, update your module calls to:

1. Remove unused tag variables
2. Map existing tags to the 8 mandatory + 3 optional tags
3. Update source path to v1.0.0.1
4. Ensure all 8 mandatory tags are provided

## Simplified Tag Structure Output

The module generates these tags:
```
Environment        = "Development"
BusinessOwner      = "John Doe"  
BusinessUnit       = "IT"
Criticality        = "Medium"
CostCenter         = "12345"
DataClassification = "Internal"
Compliance         = "None"
Owner              = "John Doe"  # Auto-mapped from business_owner
CreatedOn          = "2024-01-15 10:30 UTC"  # Auto-generated
Region             = "Southeast Asia"  # Optional
Description        = "Demo resource group"  # Optional
NotificationEmails = "admin@example.com,support@example.com"  # Optional
```