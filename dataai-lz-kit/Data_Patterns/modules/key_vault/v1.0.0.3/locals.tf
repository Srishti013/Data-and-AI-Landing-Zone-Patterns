# TODO: insert locals here.
locals {
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}

# Private endpoint application security group associations
locals {
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }

  # Tags are now managed by the naming module
  # mandatory_tags = {
  #   BusinessUnit       = var.business_unit
  #   DataClassification = var.data_classification
  #   Criticality        = var.criticality
  #   Environment        = var.environment
  #   CostCenter         = var.cost_center
  #   AppId              = var.app_id
  #   AppName            = var.app_name
  #   AppSupport         = var.app_support
  #   Tier               = var.tier
  #   ProductName        = var.product_name
  #   ProductVersion     = var.product_version
  #   AutoshutDown       = var.autoshutdown
  #   SandboxOwner       = var.sandbox_owner
  #   DeleteAfter        = var.delete_after
  #   AutoDelete         = var.auto_delete
  # }
}
