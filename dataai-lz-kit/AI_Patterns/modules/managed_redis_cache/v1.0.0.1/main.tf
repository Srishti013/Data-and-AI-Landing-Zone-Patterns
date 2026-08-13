module "module_managed_redis" {
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

  # Optional Tags
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

resource "azurerm_managed_redis" "this" {
  name                      = module.module_managed_redis.name
  resource_group_name       = var.resource_group_name
  location                  = module.module_managed_redis.location
  sku_name                  = var.sku_name
  high_availability_enabled = var.high_availability_enabled
  public_network_access     = var.public_network_access
  tags                      = merge(module.module_managed_redis.tags, var.tags != null ? var.tags : {})

  dynamic "identity" {
    for_each = var.managed_redis_identity != null ? [var.managed_redis_identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }


  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []

    content {
      key_vault_key_id = customer_managed_key.value.key_version != null ? format(
        "https://%s.vault.azure.net/keys/%s/%s",
        basename(customer_managed_key.value.key_vault_resource_id),
        customer_managed_key.value.key_name,
        customer_managed_key.value.key_version,
        ) : format(
        "https://%s.vault.azure.net/keys/%s",
        basename(customer_managed_key.value.key_vault_resource_id),
        customer_managed_key.value.key_name,
      )

      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity != null ? customer_managed_key.value.user_assigned_identity.resource_id : null
    }
  }
  #   dynamic "customer_managed_key" {
  #     for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []

  #     content {
  #       key_vault_key_id = customer_managed_key.value.key_version != null ? format(
  #         "https://%s.vault.azure.net/keys/%s/%s",
  #         element(
  #           split(customer_managed_key.value.key_vault_resource_id, "/"),
  #           length(split(customer_managed_key.value.key_vault_resource_id, "/")) - 1,
  #         ),
  #         customer_managed_key.value.key_name,
  #         customer_managed_key.value.key_version,
  #       ) : format(
  #         "https://%s.vault.azure.net/keys/%s",
  #         element(
  #           split(customer_managed_key.value.key_vault_resource_id, "/"),
  #          length(split(customer_managed_key.value.key_vault_resource_id, "/")) - 1,
  #        ),
  #        customer_managed_key.value.key_name,
  #      )
  #      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity != null ? customer_managed_key.value.user_assigned_identity.resource_id : null
  #    }
  #  }

  default_database {
    access_keys_authentication_enabled            = var.default_database.access_keys_authentication_enabled
    client_protocol                               = var.default_database.client_protocol
    clustering_policy                             = var.default_database.clustering_policy
    eviction_policy                               = var.default_database.eviction_policy
    geo_replication_group_name                    = var.default_database.geo_replication_group_name
    persistence_append_only_file_backup_frequency = var.default_database.persistence_aof_backup_frequency
    persistence_redis_database_backup_frequency   = var.default_database.persistence_rdb_backup_frequency

    dynamic "module" {
      for_each = var.default_database.modules != null ? var.default_database.modules : []

      content {
        name = module.value.name
        args = module.value.args
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = coalesce(each.value.name, "diag-${azurerm_managed_redis.this.name}")
  target_resource_id             = azurerm_managed_redis.this.id
  log_analytics_workspace_id     = each.value.workspace_resource_id
  storage_account_id             = each.value.storage_account_resource_id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  partner_solution_id            = each.value.marketplace_partner_resource_id
  log_analytics_destination_type = each.value.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}
