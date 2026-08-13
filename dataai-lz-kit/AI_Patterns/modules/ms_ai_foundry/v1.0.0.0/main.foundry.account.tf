########################
##MS Foundry
########################
resource "azapi_resource" "ai_foundry" {
  for_each = var.ai_foundry_accounts != null ? var.ai_foundry_accounts : {}

  type                      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name                      = module.module_foundry.name
  parent_id                 = each.value.parent_id
  location                  = module.module_foundry.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices"


    sku = {
      name = each.value.sku_name
    }

    identity = merge(
      {
        type = each.value.identity_type
      },
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], each.value.identity_type) ? {
        userAssignedIdentities = {
          (each.value.identity_id) = {}
        }
      } : {}
    )

    properties = merge(
      {
        disableLocalAuth       = each.value.disableLocalAuth
        allowProjectManagement = each.value.allowProjectManagement
        customSubDomainName    = each.value.customSubDomainName
        publicNetworkAccess    = each.value.publicNetworkAccess

        # Managed VNet - Network Injection
        restrictOutboundNetworkAccess = each.value.restrict_outbound_network_access
      },

      each.value.encryption != null ? {
        encryption = {
          keySource = each.value.encryption.key_source

          keyVaultProperties = {
            keyVaultUri      = each.value.encryption.key_vault_uri
            keyName          = each.value.encryption.key_name
            keyVersion       = each.value.encryption.key_version
            identityClientId = each.value.encryption.identity_client_id
          }
        }
      } : {},

      # VNet injection for Standard Agents - only include useMicrosoftManagedNetwork if true
      each.value.network_injections != null && length(each.value.network_injections) > 0 ? {
        networkInjections = [
          for ni in each.value.network_injections : merge(
            {
              scenario    = ni.scenario
              subnetArmId = ni.subnet_arm_id
            },
            ni.use_microsoft_managed_network == true ? {
              useMicrosoftManagedNetwork = true
            } : {}
          )
        ]
      } : {},
      length(each.value.allowed_fqdn_list) > 0 ? {
        allowedFqdnList = each.value.allowed_fqdn_list
      } : {},
      each.value.network_acls != null ? {
        networkAcls = {
          bypass        = each.value.network_acls.bypass
          defaultAction = each.value.network_acls.default_action
          ipRules = [
            for rule in each.value.network_acls.ip_rules : {
              value = rule
            }
          ]
          virtualNetworkRules = [
            for rule in each.value.network_acls.virtual_network_rules : {
              id                               = rule
              ignoreMissingVnetServiceEndpoint = true
            }
          ]
        }
      } : {},
      length(each.value.user_owned_storage) > 0 ? {
        userOwnedStorage = [
          for uos in each.value.user_owned_storage : merge(
            { resourceId = uos.resource_id },
            uos.identity_client_id != null ? { identityClientId = uos.identity_client_id } : {}
          )
        ]
      } : {}
    )
  }
}

