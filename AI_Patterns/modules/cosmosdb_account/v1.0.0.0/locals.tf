locals {
  consistency_policy = var.consistency_policy != null ? var.consistency_policy : {
    consistency_level       = "Session"
    max_interval_in_seconds = null
    max_staleness_prefix    = null
  }

  geo_locations = length(var.geo_locations) > 0 ? var.geo_locations : [
    {
      location          = module.module_cosmos.location
      failover_priority = 0
      zone_redundant    = false
    }
  ]

  vnet_filter_enabled = var.is_virtual_network_filter_enabled || length(var.virtual_network_rules) > 0

  # Private endpoint application security group associations
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
}
