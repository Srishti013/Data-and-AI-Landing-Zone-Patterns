# =============================================================================
# Policy assignment catalog (subscription scope). One row per policy from the
# MCSB v2 guardrail matrix. Built-in rows carry a builtin_id; custom rows carry
# a custom_key that maps to definitions/<key>.json (authored in batches).
#
# Row shape (all fields required; use null where N/A):
#   name            - assignment name, <= 24 chars, unique
#   display_name    - shown in the compliance UI
#   builtin_id      - built-in policy definition GUID, or null for custom
#   custom_key      - definitions/<key>.json (no extension), or null for built-in
#   effect          - Deny | Modify | DeployIfNotExists | Audit (drives identity/role)
#   parameters_json - JSON string of assignment parameters, or null for defaults
#
# NOTE: DeployIfNotExists "diagnostic settings" rows from the matrix are SKIPPED
# (matrix: "skill v4.4.0 skips this row pending platform decision" + they need a
# Log Analytics target). Deny / Modify / Audit rows are included.
# =============================================================================

locals {
  policy_catalog = [
    # ----- Azure AI Foundry (Microsoft.CognitiveServices/accounts, kind=AIServices) -----
    { name = "aif-deny-pna", display_name = "AI Foundry: Disable public network access", builtin_id = null, custom_key = "deny-ai-foundry-public-network-access", effect = "Deny", parameters_json = null },
    { name = "aif-deny-localauth", display_name = "AI Foundry: Disable local authentication", builtin_id = null, custom_key = "deny-ai-foundry-local-auth-disabled", effect = "Deny", parameters_json = null },
    { name = "aif-deny-outbound", display_name = "AI Foundry: Restrict outbound network access", builtin_id = null, custom_key = "deny-ai-foundry-outbound-network-restricted", effect = "Deny", parameters_json = null },
    { name = "aif-deny-netdeny", display_name = "AI Foundry: Default-deny network ACLs", builtin_id = null, custom_key = "deny-ai-foundry-network-default-deny", effect = "Deny", parameters_json = null },
    { name = "aif-mod-pna", display_name = "AI Foundry: Auto-disable public network access", builtin_id = "47ba1dd7-28d9-4b07-a8d5-9813bed64e0c", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "aif-mod-localauth", display_name = "AI Foundry: Auto-disable local authentication", builtin_id = "14de9e63-1b31-492e-a5a3-c3f7fd57f555", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "aif-managed-id", display_name = "AI Foundry: Use a managed identity", builtin_id = "fe3fd216-4f83-4fc1-8984-2bbec80a3418", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "aif-approved-models", display_name = "AI Foundry: Only approved models", builtin_id = "aafe3651-cb78-4f68-9f81-e7e41509110f", custom_key = null, effect = "Deny", parameters_json = null },

    # ----- Azure OpenAI (Microsoft.CognitiveServices/accounts, kind=OpenAI) -----
    { name = "aoai-deny-pna", display_name = "Azure OpenAI: Disable public network access", builtin_id = null, custom_key = "deny-azure-openai-public-network-access", effect = "Deny", parameters_json = null },
    { name = "aoai-deny-netdeny", display_name = "Azure OpenAI: Default-deny network ACLs", builtin_id = null, custom_key = "deny-azure-openai-network-acls-default-deny", effect = "Deny", parameters_json = null },
    { name = "aoai-deny-localauth", display_name = "Azure OpenAI: Disable local authentication", builtin_id = null, custom_key = "deny-azure-openai-disable-local-auth", effect = "Deny", parameters_json = null },
    { name = "aoai-deny-outbound", display_name = "Azure OpenAI: Restrict outbound network access", builtin_id = null, custom_key = "deny-azure-openai-restrict-outbound-network", effect = "Deny", parameters_json = null },
    { name = "aoai-deny-cmk", display_name = "Azure OpenAI: Customer-managed key", builtin_id = null, custom_key = "deny-azure-openai-customer-managed-key", effect = "Deny", parameters_json = null },

    # ----- Azure AI Search (Microsoft.Search/searchServices) - all built-in -----
    { name = "srch-deny-pna", display_name = "AI Search: Disable public network access", builtin_id = "ee980b6d-0eca-4501-8d54-f6290fd512c3", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "srch-mod-pna", display_name = "AI Search: Auto-disable public network access", builtin_id = "9cee519f-d9c1-4fd9-9f79-24ec3449ed30", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "srch-deny-localauth", display_name = "AI Search: Disable API key auth", builtin_id = "6300012e-e9a4-4649-b41f-a85f5c43be91", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "srch-mod-localauth", display_name = "AI Search: Auto-disable API key auth", builtin_id = "4eb216f2-9dba-4979-86e6-5d7e63ce3b75", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "srch-deny-cmk", display_name = "AI Search: Enforce customer-managed keys", builtin_id = "356da939-f20a-4bb9-86f8-5db445b0e354", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "srch-deny-privlink", display_name = "AI Search: Private-link-capable SKU", builtin_id = "a049bf77-880b-470f-ba6d-9f21c530cf83", custom_key = null, effect = "Deny", parameters_json = null },

    # ----- Azure Container Apps + Environments (Microsoft.App/*) -----
    { name = "ca-https-only", display_name = "Container Apps: HTTPS only", builtin_id = "0e80e269-43a4-4ae9-b5bc-178126b8a5cb", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ca-disable-external", display_name = "Container Apps: Disable external network access", builtin_id = "783ea2a8-b8fd-46be-896a-9ae79643a0b1", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ca-managed-id", display_name = "Container Apps: Enable managed identity", builtin_id = "b874ab2d-72dd-47f1-8cb5-4a306478a4e7", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ca-vnet-injection", display_name = "Container Apps Env: VNet injection", builtin_id = "8b346db6-85af-419b-8557-92cee2c0f9bb", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ca-env-pna-disabled", display_name = "Container Apps Env: Disable public network access", builtin_id = "d074ddf8-01a5-4b5e-a2b8-964aed452c0a", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ca-volume-mount", display_name = "Container Apps: Configure writable volume mount", builtin_id = "7c9f3fbb-739d-4844-8e42-97e3be6450e0", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ca-env-deny-pna", display_name = "Container Apps Env: Deny public network access (custom)", builtin_id = null, custom_key = "deny-container-apps-env-public-network-access", effect = "Deny", parameters_json = null },

    # ----- Azure API Management (Microsoft.ApiManagement/service) -----
    { name = "apim-deny-pna", display_name = "APIM: Disable public network access", builtin_id = null, custom_key = "deny-api-management-public-network-access", effect = "Audit", parameters_json = null },
    { name = "apim-internal", display_name = "APIM: Deploy into a VNet (internal mode)", builtin_id = "ef619a2c-cc4d-4d03-b2ba-8c94a834d85b", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "apim-mgmt-endpoint", display_name = "APIM: Disable direct management API endpoint", builtin_id = "b741306c-968e-4b67-b916-5675e5c709f4", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "apim-protocols", display_name = "APIM: Encrypted protocols only", builtin_id = "ee7495e7-3ba7-40b6-bfee-c29e22cc75d4", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "apim-backend-cert", display_name = "APIM: Validate backend certificate", builtin_id = "92bb331d-ac71-416a-8c91-02f2cb734ce4", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "apim-kv-named-values", display_name = "APIM: Secret named values in Key Vault", builtin_id = "f1cc7827-022c-473e-836e-5a51cae0b249", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "apim-stv2", display_name = "APIM: Use stv2 compute platform", builtin_id = "1dc2fc00-2245-4143-99f4-874c937f13ef", custom_key = null, effect = "Deny", parameters_json = null },

    # ----- Azure Application Gateway (WAF) (Microsoft.Network/applicationGateways) -----
    { name = "agw-waf-enabled", display_name = "App Gateway WAF: WAF enabled", builtin_id = "564feb30-bf6a-4854-b4bb-0d2d2d1e6c66", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "agw-waf-v2-sku", display_name = "App Gateway WAF: WAF_v2 SKU (custom)", builtin_id = null, custom_key = "deny-app-gateway-waf-waf-v2-sku", effect = "Deny", parameters_json = null },
    { name = "agw-waf-prevention", display_name = "App Gateway WAF: Prevention mode", builtin_id = "12430be1-6cc8-4527-a9a8-e3d38f250096", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "agw-waf-request-body", display_name = "App Gateway WAF: Inspect request bodies", builtin_id = "ca85ef9a-741d-461d-8b7a-18c2da82c666", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "agw-waf-bot", display_name = "App Gateway WAF: Bot protection", builtin_id = "ebea0d86-7fbd-42e3-8a46-27e7568c2525", custom_key = null, effect = "Deny", parameters_json = null },

    # ----- Azure Container Registry (Microsoft.ContainerRegistry/registries) -----
    { name = "acr-deny-pna", display_name = "ACR: Disable public network access", builtin_id = "0fdf0491-d080-4575-b627-ad0e843cba0f", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "acr-mod-pna", display_name = "ACR: Auto-disable public network access", builtin_id = "a3701552-92ea-433e-9d17-33b7f1208fc9", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "acr-premium-sku", display_name = "ACR: Premium SKU (private link)", builtin_id = "bd560fc0-3c69-498a-ae9f-aa8eb7de0e13", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "acr-admin-disabled", display_name = "ACR: Disable local admin account", builtin_id = "dc921057-6b28-4fbe-9b83-f7bec05db6c2", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "acr-anon-pull", display_name = "ACR: Disable anonymous pull", builtin_id = "9f2dea28-e834-476c-99c5-3507b4728395", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "acr-export-disabled", display_name = "ACR: Disable registry exports", builtin_id = "524b0254-c285-4903-bee6-bb8126cde579", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "acr-net-deny", display_name = "ACR: Default-deny network rule set", builtin_id = "d0793b48-0edc-4296-a390-4c75d1bdfd71", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "acr-quarantine", display_name = "ACR: Image quarantine (custom)", builtin_id = null, custom_key = "deny-container-registry-quarantine-policy", effect = "Deny", parameters_json = null },

    # ----- Azure Storage Account (Microsoft.Storage/storageAccounts) - all built-in -----
    { name = "st-deny-pna", display_name = "Storage: Disable public network access", builtin_id = "b2982f36-99f2-4db5-8eff-283140c09693", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-mod-pna", display_name = "Storage: Auto-disable public network access", builtin_id = "a06d0189-92e8-4dba-b0c4-08d7669fce7d", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "st-blob-public", display_name = "Storage: Disallow anonymous blob access", builtin_id = "4fa4b6c0-31ca-4c0d-b10d-24b96f62a751", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-https", display_name = "Storage: HTTPS only", builtin_id = "404c3081-a854-4457-ae30-26a93ef643f9", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-tls", display_name = "Storage: TLS 1.2+", builtin_id = "fe83a0eb-a853-422d-aac2-1bffd182c5d0", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-shared-key", display_name = "Storage: Prevent shared key access", builtin_id = "8c6a50c6-9ffd-4ae7-986f-5fa6111f9a54", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-net-deny", display_name = "Storage: Default-deny network rules", builtin_id = "34c877ad-507e-4c82-993e-3452a6e0ad3c", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-infra-encryption", display_name = "Storage: Infrastructure encryption", builtin_id = "4733ea7b-a883-42fe-8cac-97454c2a9e4a", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-cross-tenant", display_name = "Storage: Prevent cross-tenant replication", builtin_id = "92a89a79-6c52-4a7e-a03f-61306fc49312", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "st-sas-expiry", display_name = "Storage: SAS 7-day max validity", builtin_id = "7aa1c9d5-3d7e-4579-8117-d85e99211757", custom_key = null, effect = "Deny", parameters_json = null },

    # ----- Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts) -----
    { name = "cos-deny-pna", display_name = "Cosmos DB: Disable public network access", builtin_id = "797b37f7-06b8-444c-b1ad-fc62867f335a", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "cos-mod-pna", display_name = "Cosmos DB: Auto-disable public network access", builtin_id = "da69ba51-aaf1-41e5-8651-607cd0b37088", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "cos-local-auth", display_name = "Cosmos DB: Disable key-based auth", builtin_id = "5450f5bd-9c72-4390-a9c4-a7aba4edfdd2", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "cos-mod-local-auth", display_name = "Cosmos DB: Auto-disable key-based auth", builtin_id = "dc2d41d1-4ab1-4666-a3e1-3d51c43e0049", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "cos-no-open-dc", display_name = "Cosmos DB: No open Azure datacentre traffic", builtin_id = "12339a85-a25c-4f17-9f82-4766f13f5c4c", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "cos-key-metadata", display_name = "Cosmos DB: Disable key metadata writes (custom)", builtin_id = null, custom_key = "deny-cosmos-db-key-metadata-writes-disabled", effect = "Deny", parameters_json = null },
    { name = "cos-tls", display_name = "Cosmos DB: TLS 1.2 (custom)", builtin_id = null, custom_key = "deny-cosmos-db-minimum-tls", effect = "Deny", parameters_json = null },

    # ----- Azure SQL (Microsoft.Sql/servers[/databases]) - consolidated custom -----
    { name = "sql-deny-pna", display_name = "SQL: Disable public network access", builtin_id = null, custom_key = "deny-azure-sql-public-network-access", effect = "Deny", parameters_json = null },
    { name = "sql-aad-only", display_name = "SQL: Azure AD-only authentication", builtin_id = null, custom_key = "deny-azure-sql-aad-only-authentication", effect = "Deny", parameters_json = null },
    { name = "sql-aad-only-admins", display_name = "SQL: Azure AD-only authentication (administrators alias)", builtin_id = null, custom_key = "deny-azure-sql-aad-only-authentication-administrators", effect = "Deny", parameters_json = null },
    { name = "sql-tls", display_name = "SQL: Minimum TLS 1.2", builtin_id = null, custom_key = "deny-azure-sql-tls-minimum-version", effect = "Deny", parameters_json = null },
    { name = "sql-outbound", display_name = "SQL: Restrict outbound network access", builtin_id = null, custom_key = "deny-azure-sql-outbound-network-restriction", effect = "Deny", parameters_json = null },
    { name = "sql-private-endpoint", display_name = "SQL: Require private endpoint (audit)", builtin_id = null, custom_key = "audit-azure-sql-private-endpoint", effect = "Audit", parameters_json = null },
    { name = "sql-tde", display_name = "SQL Database: Transparent Data Encryption", builtin_id = null, custom_key = "deny-azure-sql-database-tde", effect = "Deny", parameters_json = null },
    { name = "sql-backup-redundancy", display_name = "SQL Database: Geo-redundant backup", builtin_id = null, custom_key = "deny-azure-sql-database-backup-redundancy", effect = "Deny", parameters_json = null },

    # ----- Azure Key Vault (Microsoft.KeyVault/vaults) -----
    { name = "kv-deny-pna", display_name = "Key Vault: Disable public network access", builtin_id = "405c5871-3e91-4644-8a63-58e19d68ff5b", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-private-link", display_name = "Key Vault: Private link only", builtin_id = "a6abeaec-4d90-4a02-805f-6b26c4d3fbe9", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-net-deny", display_name = "Key Vault: Default-deny network ACLs", builtin_id = "55615ac9-af46-4a59-874e-391cc3dfb490", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-rbac", display_name = "Key Vault: RBAC permission model", builtin_id = "12d4fa5e-1f9f-4c21-97a9-b99b3c6611b5", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-soft-delete", display_name = "Key Vault: Enable soft delete", builtin_id = "1e66c121-a66a-4b1f-9b83-0fd99bf0fc2d", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-purge-protection", display_name = "Key Vault: Enable purge protection", builtin_id = "0b60c0b2-2dc2-4e1c-b5c9-abbed971de53", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-key-expiration", display_name = "Key Vault: Keys must expire", builtin_id = "152b15f7-8e1f-4c1f-ab71-8c010ba5dbc0", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-secret-expiration", display_name = "Key Vault: Secrets must expire", builtin_id = "98728c90-32c7-4049-8429-847dc0f4fe37", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "kv-mod-firewall", display_name = "Key Vault: Auto-enable firewall", builtin_id = "ac673a9a-f77d-4846-b2d8-a57f8e1c01dc", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "kv-retention", display_name = "Key Vault: Soft-delete retention >= 90d (custom)", builtin_id = null, custom_key = "deny-key-vault-soft-delete-retention", effect = "Deny", parameters_json = null },

    # ----- Azure Managed Redis (Microsoft.Cache/redisEnterprise) - all custom -----
    { name = "redis-deny-pna", display_name = "Managed Redis: Disable public network access", builtin_id = null, custom_key = "deny-managed-redis-public-network-access", effect = "Deny", parameters_json = null },
    { name = "redis-tls", display_name = "Managed Redis: Require encrypted client protocol", builtin_id = null, custom_key = "deny-managed-redis-encrypted-protocol", effect = "Deny", parameters_json = null },
    { name = "redis-privlink", display_name = "Managed Redis: Private link only (audit)", builtin_id = null, custom_key = "audit-managed-redis-private-link-required", effect = "Audit", parameters_json = null },
    { name = "redis-entra", display_name = "Managed Redis: Entra ID auth (audit)", builtin_id = null, custom_key = "audit-managed-redis-entra-id-authentication", effect = "Audit", parameters_json = null },
    { name = "redis-cmk", display_name = "Managed Redis: CMK (audit)", builtin_id = null, custom_key = "audit-managed-redis-cmk", effect = "Audit", parameters_json = null },

    # ----- Azure Log Analytics (Microsoft.OperationalInsights/workspaces) -----
    { name = "la-disable-local-auth", display_name = "Log Analytics: Entra ID auth only", builtin_id = "e15effd4-2278-4c65-a0da-4d6f6d1890e2", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "la-pna-ingestion", display_name = "Log Analytics: Disable public ingestion", builtin_id = "6c53d030-cc64-46f0-906d-2bc061cd1334", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "la-pna-query", display_name = "Log Analytics: Disable public query (custom)", builtin_id = null, custom_key = "deny-log-analytics-public-network-access-query", effect = "Deny", parameters_json = null },
    { name = "la-mod-pna", display_name = "Log Analytics: Auto-disable public access", builtin_id = "d3ba9c42-9dd5-441a-957c-274031c750c0", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "la-retention", display_name = "Log Analytics: Retention >= 90d (custom)", builtin_id = null, custom_key = "deny-log-analytics-retention-minimum", effect = "Deny", parameters_json = null },
    { name = "la-resource-only", display_name = "Log Analytics: Resource-context access (custom)", builtin_id = null, custom_key = "deny-log-analytics-resource-only-permissions", effect = "Deny", parameters_json = null },

    # ----- Application Insights (Microsoft.Insights/components) -----
    { name = "ai-disable-local-auth", display_name = "App Insights: Entra ID auth only", builtin_id = "199d5677-e4d9-4264-9465-efe1839c06bd", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ai-pna-ingestion", display_name = "App Insights: Disable public ingestion", builtin_id = "1bc02227-0cb6-4e11-8f53-eb0b22eab7e8", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ai-pna-query", display_name = "App Insights: Disable public query (custom)", builtin_id = null, custom_key = "deny-application-insights-public-network-access-query", effect = "Deny", parameters_json = null },
    { name = "ai-mod-pna", display_name = "App Insights: Auto-disable public access", builtin_id = "dddfa1af-dcd6-42f4-b5b0-e1db01e0b405", custom_key = null, effect = "Modify", parameters_json = null },
    { name = "ai-workspace-based", display_name = "App Insights: Workspace-based ingestion", builtin_id = "d550e854-df1a-4de9-bf44-cd894b39a95e", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "ai-byo-storage", display_name = "App Insights: BYO storage for profiler", builtin_id = "0c4bd2e8-8872-4f37-a654-03f6f38ddc76", custom_key = null, effect = "Deny", parameters_json = null },

    # ----- Private DNS + Virtual Networks -----
    { name = "pdns-registration", display_name = "Private DNS: Disable auto-registration (custom)", builtin_id = null, custom_key = "deny-private-dns-registration-disabled", effect = "Deny", parameters_json = null },
    { name = "vnet-private-subnets", display_name = "VNet: Subnets must be private", builtin_id = "7bca8353-aa3b-429b-904a-9229c4385837", custom_key = null, effect = "Deny", parameters_json = null },
    { name = "vnet-subnet-nsg", display_name = "VNet: Every subnet needs an NSG (audit, custom)", builtin_id = null, custom_key = "audit-virtual-network-subnet-nsg-required", effect = "Audit", parameters_json = null },
  ]
}
