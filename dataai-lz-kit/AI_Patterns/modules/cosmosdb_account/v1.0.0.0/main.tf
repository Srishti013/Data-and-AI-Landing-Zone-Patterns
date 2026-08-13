module "module_cosmos" {
  source = "../../naming_module/v1.0.0.0"

  # Basic naming parameters
  env                = var.env
  org                = var.org
  region_code        = var.region_code
  base_name          = var.base_name
  additional_name    = var.additional_name
  iterator           = var.iterator
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = var.resource_type_code
  max_length         = var.max_length
  no_dashes          = var.no_dashes
  add_random         = var.add_random
  rnd_length         = var.rnd_length

  # Mandatory Business Tags
  app_name       = var.app_name
  app_support    = var.app_support
  business_unit  = var.business_unit
  country        = var.country
  business_owner = var.business_owner
  type           = var.type

  # Mandatory DevOps Tags
  product_name    = var.product_name
  product_version = var.product_version

  # Mandatory Finance Tags
  cost_center          = var.cost_center
  cost_allocation_unit = var.cost_allocation_unit
  budget_id            = var.budget_id
  budget_limit         = var.budget_limit
  cost_alert_threshold = var.cost_alert_threshold

  # Mandatory Governance Tags
  data_classification = var.data_classification
  compliance_required = var.compliance_required
  compliance          = var.compliance

  # Mandatory Operation Tags
  criticality = var.criticality
  environment = var.environment
  status      = var.status

  # Optional Tags (pass through if provided)
  delete_after        = var.delete_after
  tier                = var.tier
  app_id              = var.app_id
  auto_delete         = var.auto_delete
  auto_shutdown       = var.auto_shutdown
  description         = var.description
  backup_policy       = var.backup_policy
  disaster_recovery   = var.disaster_recovery
  notification_emails = var.notification_emails
  region              = var.region

  # Additional custom tags
  additional_tags = var.additional_tags
}

resource "azurerm_cosmosdb_account" "this" {
  name                = module.module_cosmos.name
  location            = module.module_cosmos.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind

  automatic_failover_enabled            = var.automatic_failover_enabled
  multiple_write_locations_enabled      = var.multiple_write_locations_enabled
  free_tier_enabled                     = var.free_tier_enabled
  public_network_access_enabled         = var.public_network_access_enabled
  is_virtual_network_filter_enabled     = local.vnet_filter_enabled
  ip_range_filter                       = var.ip_range_filter
  analytical_storage_enabled            = var.analytical_storage_enabled
  partition_merge_enabled               = var.partition_merge_enabled
  burst_capacity_enabled                = var.burst_capacity_enabled
  minimal_tls_version                   = var.minimal_tls_version
  local_authentication_disabled         = var.local_authentication_disabled
  key_vault_key_id                      = var.key_vault_key_id
  managed_hsm_key_id                    = var.managed_hsm_key_id
  access_key_metadata_writes_enabled    = var.access_key_metadata_writes_enabled
  mongo_server_version                  = var.mongo_server_version
  network_acl_bypass_for_azure_services = var.network_acl_bypass_for_azure_services
  network_acl_bypass_ids                = var.network_acl_bypass_ids
  create_mode                           = var.create_mode
  default_identity_type                 = var.default_identity_type
  tags                                  = merge(module.module_cosmos.tags, var.tags)

  consistency_policy {
    consistency_level       = local.consistency_policy.consistency_level
    max_interval_in_seconds = local.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = local.consistency_policy.max_staleness_prefix
  }

  dynamic "capabilities" {
    for_each = var.capabilities

    content {
      name = capabilities.value
    }
  }

  dynamic "geo_location" {
    for_each = local.geo_locations

    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = try(geo_location.value.zone_redundant, null)
    }
  }

  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules

    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = try(virtual_network_rule.value.ignore_missing_vnet_service_endpoint, false)
    }
  }

  dynamic "analytical_storage" {
    for_each = var.analytical_storage == null ? [] : [var.analytical_storage]

    content {
      schema_type = analytical_storage.value.schema_type
    }
  }

  dynamic "capacity" {
    for_each = var.capacity == null ? [] : [var.capacity]

    content {
      total_throughput_limit = capacity.value.total_throughput_limit
    }
  }

  dynamic "backup" {
    for_each = var.backup == null ? [] : [var.backup]

    content {
      type                = backup.value.type
      interval_in_minutes = backup.value.interval_in_minutes
      retention_in_hours  = backup.value.retention_in_hours
      tier                = backup.value.tier
      storage_redundancy  = backup.value.storage_redundancy
    }
  }

  dynamic "cors_rule" {
    for_each = var.cors_rules

    content {
      allowed_headers    = cors_rule.value.allowed_headers
      allowed_methods    = cors_rule.value.allowed_methods
      allowed_origins    = cors_rule.value.allowed_origins
      exposed_headers    = cors_rule.value.exposed_headers
      max_age_in_seconds = cors_rule.value.max_age_in_seconds
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "restore" {
    for_each = var.restore == null ? [] : [var.restore]

    content {
      source_cosmosdb_account_id = restore.value.source_cosmosdb_account_id
      restore_timestamp_in_utc   = restore.value.restore_timestamp_in_utc
      tables_to_restore          = restore.value.tables_to_restore

      dynamic "database" {
        for_each = restore.value.database == null ? [] : restore.value.database

        content {
          name             = database.value.name
          collection_names = database.value.collection_names
        }
      }

      dynamic "gremlin_database" {
        for_each = restore.value.gremlin_database == null ? [] : restore.value.gremlin_database

        content {
          name        = gremlin_database.value.name
          graph_names = gremlin_database.value.graph_names
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    ignore_changes = [
      key_vault_key_id,
      default_identity_type,
    ]
  }
}

# SQL Databases
resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = var.sql_databases

  name                = each.value.name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = try(each.value.autoscale_settings, null) == null ? each.value.throughput : null

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []

    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }
}

# SQL Containers
resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = merge([
    for db_key, db in var.sql_databases : {
      for container_key, container in db.containers : "${db_key}_${container_key}" => merge(container, {
        database_key  = db_key
        database_name = db.name
      })
    }
  ]...)

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  account_name           = azurerm_cosmosdb_account.this.name
  database_name          = azurerm_cosmosdb_sql_database.this[each.value.database_key].name
  partition_key_paths    = each.value.partition_key_paths
  partition_key_version  = each.value.partition_key_version
  throughput             = try(each.value.autoscale_settings, null) == null ? each.value.throughput : null
  default_ttl            = each.value.default_ttl
  analytical_storage_ttl = each.value.analytical_storage_ttl

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []

    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  dynamic "indexing_policy" {
    for_each = try(each.value.indexing_policy, null) != null ? [each.value.indexing_policy] : []

    content {
      indexing_mode = try(indexing_policy.value.indexing_mode, "consistent")

      dynamic "included_path" {
        for_each = try(indexing_policy.value.included_paths, [])

        content {
          path = included_path.value.path
        }
      }

      dynamic "excluded_path" {
        for_each = try(indexing_policy.value.excluded_paths, [])

        content {
          path = excluded_path.value.path
        }
      }

      dynamic "composite_index" {
        for_each = try(indexing_policy.value.composite_indexes, [])

        content {
          dynamic "index" {
            for_each = composite_index.value

            content {
              path  = index.value.path
              order = index.value.order
            }
          }
        }
      }

      dynamic "spatial_index" {
        for_each = try(indexing_policy.value.spatial_indexes, [])

        content {
          path = spatial_index.value.path
        }
      }
    }
  }

  dynamic "unique_key" {
    for_each = try(each.value.unique_keys, [])

    content {
      paths = unique_key.value.paths
    }
  }

  dynamic "conflict_resolution_policy" {
    for_each = try(each.value.conflict_resolution_policy, null) != null ? [each.value.conflict_resolution_policy] : []

    content {
      mode                          = conflict_resolution_policy.value.mode
      conflict_resolution_path      = try(conflict_resolution_policy.value.conflict_resolution_path, null)
      conflict_resolution_procedure = try(conflict_resolution_policy.value.conflict_resolution_procedure, null)
    }
  }

  depends_on = [azurerm_cosmosdb_sql_database.this]
}
