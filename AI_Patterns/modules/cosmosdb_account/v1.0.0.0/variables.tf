variable "resource_group_name" {
  type        = string
  description = "The resource group where the Cosmos DB account will be deployed."
}

variable "offer_type" {
  type        = string
  default     = "Standard"
  description = "The offer type for the Cosmos DB account."

  validation {
    condition     = contains(["Standard"], var.offer_type)
    error_message = "offer_type must be Standard."
  }
}

variable "kind" {
  type        = string
  default     = "GlobalDocumentDB"
  description = "The kind of Cosmos DB account. For NoSQL (SQL API), use GlobalDocumentDB."

  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "kind must be one of GlobalDocumentDB, MongoDB, or Parse."
  }
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = false
  description = "Whether automatic failover is enabled."
}

variable "multiple_write_locations_enabled" {
  type        = bool
  default     = false
  description = "Whether multiple write locations are enabled."
}

variable "free_tier_enabled" {
  type        = bool
  default     = false
  description = "Whether Free Tier is enabled for the account."
}

variable "create_mode" {
  type        = string
  default     = null
  description = "The creation mode for the Cosmos DB account. Possible values are Default and Restore."

  validation {
    condition     = var.create_mode == null ? true : contains(["Default", "Restore"], var.create_mode)
    error_message = "create_mode must be Default or Restore."
  }
}

variable "default_identity_type" {
  type        = string
  default     = null
  description = "The default identity for accessing Key Vault. Possible values are FirstPartyIdentity, SystemAssignedIdentity, or UserAssignedIdentity=<user assigned identity resource id>."

  validation {
    condition     = var.default_identity_type == null ? true : can(regex("^(FirstPartyIdentity|SystemAssignedIdentity|UserAssignedIdentity=.+)$", var.default_identity_type))
    error_message = "default_identity_type must be FirstPartyIdentity, SystemAssignedIdentity, or UserAssignedIdentity=<user assigned identity resource id>."
  }
}

variable "partition_merge_enabled" {
  type        = bool
  default     = false
  description = "Whether partition merge is enabled."
}

variable "burst_capacity_enabled" {
  type        = bool
  default     = false
  description = "Whether burst capacity is enabled."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether public network access is enabled."
}

variable "is_virtual_network_filter_enabled" {
  type        = bool
  default     = false
  description = "Whether virtual network filtering is enabled."
}

variable "ip_range_filter" {
  type        = set(string)
  default     = []
  description = "IP range filter for firewall rules (set of CIDRs)."
}

variable "virtual_network_rules" {
  type = list(object({
    id                                   = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default     = []
  description = "List of virtual network rules for the account."
}

variable "analytical_storage_enabled" {
  type        = bool
  default     = false
  description = "Whether analytical storage is enabled."
}

variable "analytical_storage" {
  type = object({
    schema_type = string
  })
  default     = null
  description = "Analytical storage configuration."
}

variable "capacity" {
  type = object({
    total_throughput_limit = number
  })
  default     = null
  description = "Capacity configuration for total throughput limit."
}

variable "minimal_tls_version" {
  type        = string
  default     = "Tls12"
  description = "The minimal TLS version for the account (Tls, Tls11, Tls12)."

  validation {
    condition     = contains(["Tls", "Tls11", "Tls12"], var.minimal_tls_version)
    error_message = "minimal_tls_version must be Tls, Tls11, or Tls12."
  }
}

variable "local_authentication_disabled" {
  type        = bool
  default     = true
  description = "Whether local authentication (keys) is disabled."
}

variable "key_vault_key_id" {
  type        = string
  default     = null
  description = "The Key Vault key ID for customer-managed keys."
}

variable "managed_hsm_key_id" {
  type        = string
  default     = null
  description = "The Managed HSM key ID for customer-managed keys."
}

variable "access_key_metadata_writes_enabled" {
  type        = bool
  default     = false
  description = "Whether write operations on metadata via account keys are enabled."
}

variable "mongo_server_version" {
  type        = string
  default     = null
  description = "The server version of a MongoDB account."

  validation {
    condition     = var.mongo_server_version == null ? true : contains(["7.0", "6.0", "5.0", "4.2", "4.0", "3.6", "3.2"], var.mongo_server_version)
    error_message = "mongo_server_version must be one of 7.0, 6.0, 5.0, 4.2, 4.0, 3.6, or 3.2."
  }
}

variable "network_acl_bypass_for_azure_services" {
  type        = bool
  default     = false
  description = "Whether Azure services can bypass network ACLs."
}

variable "network_acl_bypass_ids" {
  type        = set(string)
  default     = []
  description = "List of resource IDs for network ACL bypass."
}

variable "capabilities" {
  type        = set(string)
  default     = []
  description = "Set of Cosmos DB capabilities (e.g., EnableServerless, EnableAnalyticalStorage)."
}

variable "consistency_policy" {
  type = object({
    consistency_level       = string
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  default     = null
  description = "Consistency policy for the Cosmos DB account."

  validation {
    condition     = var.consistency_policy == null || contains(["Strong", "BoundedStaleness", "Session", "ConsistentPrefix", "Eventual"], try(var.consistency_policy.consistency_level, ""))
    error_message = "consistency_level must be one of Strong, BoundedStaleness, Session, ConsistentPrefix, or Eventual."
  }
  validation {
    condition = var.consistency_policy == null || (
      try(var.consistency_policy.consistency_level, "") != "BoundedStaleness" || (
        try(var.consistency_policy.max_interval_in_seconds, null) != null && try(var.consistency_policy.max_staleness_prefix, null) != null
      )
    )
    error_message = "For BoundedStaleness, max_interval_in_seconds and max_staleness_prefix must be set."
  }
}

variable "geo_locations" {
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
  default     = []
  description = "List of geo-locations for the account. If empty, the primary location is used."
}

variable "backup" {
  type = object({
    type                = string
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    tier                = optional(string)
    storage_redundancy  = optional(string)
  })
  default     = null
  description = "Backup configuration for the account (Periodic or Continuous)."
}

variable "cors_rules" {
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = optional(number)
  }))
  default     = []
  description = "List of CORS rules for the account."
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default     = null
  description = "Managed identity configuration for the account."
}

variable "restore" {
  type = object({
    source_cosmosdb_account_id = string
    restore_timestamp_in_utc   = string
    database = optional(list(object({
      name             = string
      collection_names = optional(list(string))
    })))
    gremlin_database = optional(list(object({
      name        = string
      graph_names = optional(list(string))
    })))
    tables_to_restore = optional(list(string))
  })
  default     = null
  description = "Restore configuration for the account when create_mode is Restore."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = "Timeouts for Cosmos DB account operations."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "private_endpoints" {
  type = map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    subresource_name                        = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of private endpoints to create on the Cosmos DB account. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `subresource_name` - The service name of the private endpoint. Possible values are `Sql` (for NoSQL/SQL API), `MongoDB`, `Cassandra`, `Table`, or `Gremlin`.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_associations` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of the Cosmos DB account.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.
DESCRIPTION
  nullable    = false
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the Cosmos DB account."
}

variable "sql_databases" {
  type = map(object({
    name       = string
    throughput = optional(number)
    autoscale_settings = optional(object({
      max_throughput = number
    }))
    containers = optional(map(object({
      name                  = string
      partition_key_paths   = list(string)
      partition_key_version = optional(number, 1)
      throughput            = optional(number)
      autoscale_settings = optional(object({
        max_throughput = number
      }))
      default_ttl            = optional(number)
      analytical_storage_ttl = optional(number)
      indexing_policy = optional(object({
        indexing_mode = optional(string, "consistent")
        included_paths = optional(list(object({
          path = string
        })), [{ path = "/*" }])
        excluded_paths = optional(list(object({
          path = string
        })), [{ path = "/\"_etag\"/?" }])
        composite_indexes = optional(list(list(object({
          path  = string
          order = string
        }))), [])
        spatial_indexes = optional(list(object({
          path = string
        })), [])
      }))
      unique_keys = optional(list(object({
        paths = list(string)
      })), [])
      conflict_resolution_policy = optional(object({
        mode                          = string
        conflict_resolution_path      = optional(string)
        conflict_resolution_procedure = optional(string)
      }))
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
Map of SQL databases and their containers to create in the Cosmos DB account.

- `name` - The name of the SQL database.
- `throughput` - (Optional) The throughput of the SQL database (RU/s). Must be set in increments of 100. Cannot be set if autoscale_settings is used.
- `autoscale_settings` - (Optional) Autoscale settings for the database.
  - `max_throughput` - The maximum throughput of the SQL database (RU/s).
- `containers` - (Optional) Map of containers to create in this database.
  - `name` - The name of the SQL container.
  - `partition_key_paths` - List of paths for the partition key.
  - `partition_key_version` - (Optional) The version of the partition key. Default is 1.
  - `throughput` - (Optional) The throughput of the SQL container (RU/s).
  - `autoscale_settings` - (Optional) Autoscale settings for the container.
  - `default_ttl` - (Optional) The default time to live of documents in this container.
  - `analytical_storage_ttl` - (Optional) The default time to live for analytical store.
  - `indexing_policy` - (Optional) The indexing policy for the container.
  - `unique_keys` - (Optional) List of unique key constraints.
  - `conflict_resolution_policy` - (Optional) The conflict resolution policy for the container.
DESCRIPTION
}
