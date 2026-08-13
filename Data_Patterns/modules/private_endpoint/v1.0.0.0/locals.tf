locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
  mandatory_tags = {
    BusinessUnit       = var.business_unit
    DataClassification = var.data_classification
    Criticality        = var.criticality
    Environment        = var.environment
    CostCenter         = var.cost_center
    AppId              = var.app_id
    AppName            = var.app_name
    AppSupport         = var.app_support
    Tier               = var.tier
    ProductName        = var.product_name
    ProductVersion     = var.product_version
    AutoshutDown       = var.autoshutdown
    SandboxOwner       = var.sandbox_owner
    DeleteAfter        = var.delete_after
    AutoDelete         = var.auto_delete
  }
}
