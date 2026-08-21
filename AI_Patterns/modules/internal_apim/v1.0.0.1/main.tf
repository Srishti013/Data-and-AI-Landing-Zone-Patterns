module "module_internal_apim" {
  source = "../../naming_module/v1.0.0.1"

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

  # Use v1.0.0.1 naming module interface
  product_version = "1.0.0.1"

  # Pass mandatory tags to naming module (8 mandatory tags)
  environment         = var.environment
  business_owner      = var.business_owner
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance

  # Pass optional tags to naming module (3 optional tags)
  region              = var.region
  description         = var.description
  notification_emails = var.notification_emails

  # Additional custom tags with ProductName and ProductVersion
  additional_tags = merge(
    var.additional_tags != null ? var.additional_tags : {},
    {
      # Mandatory tags passed as additional_tags
      Owner          = var.owner
      AppName        = var.app_name
      BudgetID       = var.budget_id
      Status         = var.status
      ProductName    = "internal_apim"
      ProductVersion = "1.0.0.1"
      Service        = var.service

      # Legacy tags maintained for compatibility
      Type               = var.type
      CostAllocationUnit = var.cost_allocation_unit
      BudgetLimit        = var.budget_limit
      CostAlertThreshold = var.cost_alert_threshold
      ComplianceRequired = var.compliance_required
    },
    var.delete_after != "" ? { DeleteAfter = var.delete_after } : {},
    var.tier != "" ? { Tier = var.tier } : {},
    var.app_id != "" ? { AppId = var.app_id } : {},
    var.auto_delete != "" ? { AutoDelete = var.auto_delete } : {},
    var.auto_shutdown != "" ? { AutoShutdown = var.auto_shutdown } : {},
    var.backup_policy != "" ? { BackupPolicy = var.backup_policy } : {},
    var.disaster_recovery != "" ? { DisasterRecovery = var.disaster_recovery } : {},
    var.integration_id != null && var.integration_id != "" ? { IntegrationID = var.integration_id } : {},
    var.experiment_phase != null && var.experiment_phase != "" ? { ExperimentPhase = var.experiment_phase } : {},
    var.os != null && var.os != "" ? { OS = var.os } : {},
    var.last_vm_accessed != null && var.last_vm_accessed != "" ? { LastVMAccessed = var.last_vm_accessed } : {},
    var.maintenance_window != null && var.maintenance_window != "" ? { MaintenanceWindow = var.maintenance_window } : {},
    var.patch_policy != null && var.patch_policy != "" ? { PatchPolicy = var.patch_policy } : {},
    var.retention != null && var.retention != "" ? { Retention = var.retention } : {},
    var.sandbox_type != null && var.sandbox_type != "" ? { SandboxType = var.sandbox_type } : {}
  )
}





resource "azurerm_api_management" "this" {
  location            = var.location
  name                = var.name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  # Client certificate settings
  # client_certificate_enabled = var.client_certificate_enabled
  client_certificate_enabled = false // {org} security policy to disabled client certificate authentication 
  # Gateway settings
  # gateway_disabled = var.gateway_disabled
  gateway_disabled = false
  min_api_version  = var.min_api_version
  # Notification sender email
  notification_sender_email = var.notification_sender_email
  # Public IP and network access settings
  # public_ip_address_id          = var.public_ip_address_id
  public_network_access_enabled = true // Azure forbids publicNetworkAccess=Disabled at APIM creation for Internal-mode APIM (no private endpoint); the gateway is already private via the VNet. apim-deny-pna is Audit-only.
  # public_network_access_enabled = var.public_network_access_enabled
  tags = var.tags
  # virtual_network_type          = var.virtual_network_type
  virtual_network_type = "Internal" // Forcing virtual network type to Internal for Internal APIM pattern. The value from tfvars will be ignored.
  # Availability Zones
  zones = var.zones

  # Additional locations
  dynamic "additional_location" {
    for_each = var.additional_location

    content {
      location             = additional_location.value.location
      capacity             = additional_location.value.capacity
      gateway_disabled     = additional_location.value.gateway_disabled
      public_ip_address_id = additional_location.value.public_ip_address_id
      zones                = additional_location.value.zones

      dynamic "virtual_network_configuration" {
        for_each = additional_location.value.virtual_network_configuration != null ? [additional_location.value.virtual_network_configuration] : []

        content {
          subnet_id = virtual_network_configuration.value.subnet_id
        }
      }
    }
  }
  # Certificates
  dynamic "certificate" {
    for_each = var.certificate

    content {
      encoded_certificate  = certificate.value.encoded_certificate
      store_name           = certificate.value.store_name
      certificate_password = certificate.value.certificate_password
    }
  }
  # Delegation settings
  dynamic "delegation" {
    for_each = var.delegation != null ? [var.delegation] : []

    content {
      subscriptions_enabled     = delegation.value.subscriptions_enabled
      url                       = delegation.value.url
      user_registration_enabled = delegation.value.user_registration_enabled
      validation_key            = delegation.value.validation_key
    }
  }
  # Hostname configuration
  dynamic "hostname_configuration" {
    for_each = var.hostname_configuration != null ? [var.hostname_configuration] : []

    content {
      dynamic "developer_portal" {
        for_each = hostname_configuration.value.developer_portal

        content {
          host_name                       = developer_portal.value.host_name
          certificate                     = developer_portal.value.certificate
          certificate_password            = developer_portal.value.certificate_password
          key_vault_id                    = developer_portal.value.key_vault_id
          negotiate_client_certificate    = developer_portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = developer_portal.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "management" {
        for_each = hostname_configuration.value.management

        content {
          host_name                       = management.value.host_name
          certificate                     = management.value.certificate
          certificate_password            = management.value.certificate_password
          key_vault_id                    = management.value.key_vault_id
          negotiate_client_certificate    = management.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = management.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "portal" {
        for_each = hostname_configuration.value.portal

        content {
          host_name                       = portal.value.host_name
          certificate                     = portal.value.certificate
          certificate_password            = portal.value.certificate_password
          key_vault_id                    = portal.value.key_vault_id
          negotiate_client_certificate    = portal.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = portal.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "proxy" {
        for_each = hostname_configuration.value.proxy

        content {
          host_name                       = proxy.value.host_name
          certificate                     = proxy.value.certificate
          certificate_password            = proxy.value.certificate_password
          default_ssl_binding             = proxy.value.default_ssl_binding
          key_vault_id                    = proxy.value.key_vault_id
          negotiate_client_certificate    = proxy.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = proxy.value.ssl_keyvault_identity_client_id
        }
      }
      dynamic "scm" {
        for_each = hostname_configuration.value.scm

        content {
          host_name                       = scm.value.host_name
          certificate                     = scm.value.certificate
          certificate_password            = scm.value.certificate_password
          key_vault_id                    = scm.value.key_vault_id
          negotiate_client_certificate    = scm.value.negotiate_client_certificate
          ssl_keyvault_identity_client_id = scm.value.ssl_keyvault_identity_client_id
        }
      }
    }
  }
  # Identity settings
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  # HTTP protocol settings
  # dynamic "protocols" {
  #   for_each = var.protocols != null ? [var.protocols] : []

  #   content {
  #     enable_http2 = protocols.value.enable_http2
  #   }
  # }
  protocols {
    enable_http2 = true
  } // Enforced by module security baseline - HTTPS only. The value from tfvars will be ignored.
  # Security settings
  dynamic "security" {
    # for_each = var.security != null ? [var.security] : []
    for_each = [1] // Force creation of security block to enforce security policy. The values from tfvars will be ignored and set as per the security policy.

    content {
      # backend_ssl30_enabled                               = security.value.enable_backend_ssl30
      # backend_tls10_enabled                               = security.value.enable_backend_tls10
      # backend_tls11_enabled                               = security.value.enable_backend_tls11
      # frontend_ssl30_enabled                              = security.value.enable_frontend_ssl30
      # frontend_tls10_enabled                              = security.value.enable_frontend_tls10
      # frontend_tls11_enabled                              = security.value.enable_frontend_tls11
      # tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled
      # tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = security.value.tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled
      # tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled
      # tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = security.value.tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled
      # tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_cbc_sha256_ciphers_enabled
      # tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes128_cbc_sha_ciphers_enabled
      # tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes128_gcm_sha256_ciphers_enabled
      # tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = security.value.tls_rsa_with_aes256_cbc_sha256_ciphers_enabled
      # tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = security.value.tls_rsa_with_aes256_cbc_sha_ciphers_enabled
      # tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = security.value.tls_rsa_with_aes256_gcm_sha384_ciphers_enabled
      # triple_des_ciphers_enabled                          = security.value.triple_des_ciphers_enabled

      #Security policy to enable TLS 1.2 & above security policy & to disable weak ciphers and protocols. The values from tfvars will be ignored and set as per the security policy.

      backend_ssl30_enabled = false
      backend_tls10_enabled = false
      backend_tls11_enabled = false

      frontend_ssl30_enabled = false
      frontend_tls10_enabled = false
      frontend_tls11_enabled = false

      tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = true
      tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = true
      tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = true
      tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = true

      tls_rsa_with_aes128_cbc_sha256_ciphers_enabled = true
      tls_rsa_with_aes128_cbc_sha_ciphers_enabled    = true
      tls_rsa_with_aes128_gcm_sha256_ciphers_enabled = true

      tls_rsa_with_aes256_cbc_sha256_ciphers_enabled = true
      tls_rsa_with_aes256_cbc_sha_ciphers_enabled    = true
      tls_rsa_with_aes256_gcm_sha384_ciphers_enabled = true

      triple_des_ciphers_enabled = false
    }

  }

  # Sign-in settings
  dynamic "sign_in" {
    for_each = var.sign_in != null ? [var.sign_in] : []

    content {
      enabled = sign_in.value.enabled
    }
  }
  # Sign-up settings
  dynamic "sign_up" {
    for_each = var.sign_up != null ? [var.sign_up] : []

    content {
      enabled = sign_up.value.enabled

      terms_of_service {
        consent_required = sign_up.value.terms_of_service.consent_required
        enabled          = sign_up.value.terms_of_service.enabled
        text             = sign_up.value.terms_of_service.text
      }
    }
  }
  # Tenant access settings
  dynamic "tenant_access" {
    for_each = var.tenant_access != null ? [var.tenant_access] : []

    content {
      enabled = tenant_access.value.enabled
    }
  }
  # This implementation uses a dynamic block with for_each to conditionally create the virtual_network_configuration block only when virtual_network_type is either "Internal" or "External".
  # If the type is "None", the block won't be included in the resource.
  dynamic "virtual_network_configuration" {
    for_each = contains(["Internal", "External"], "Internal") ? [1] : []

    content {
      subnet_id = var.virtual_network_subnet_id
    }
  }

  lifecycle {
    # This prevents errors when deleting products with subscriptions
    create_before_destroy = true
    # Optional: If you want to skip destroying default products
    ignore_changes = [
      # product
    ]
  }
}

# Lock resource
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_api_management.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete resource or child resources." : "Cannot modify the resource or its children."
}

# Role assignments
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_api_management.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}


