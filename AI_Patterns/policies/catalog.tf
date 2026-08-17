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
  ]
}
