# AI Landing Zone Pattern — RBAC Reference

This document lists **every role assignment** the `AI_Patterns` pattern provisions, the
identity it grants, the scope, and why. It complements the main [README.md](README.md).

All names below carry the `{env}` / `{region_code}` / `{iterator}` tokens that the workflow
substitutes at deploy time (e.g. `{env}`→`dev`, `{region_code}`→`sea`, `{iterator}`→`014`).

---

## Identities (User-Assigned Managed Identities)

| Identity (UMI) | Belongs to | Used for |
|----------------|-----------|----------|
| `{org}-id-aif-aishared` | **Shared AI Foundry identity** — the Foundry account (and both projects) | Control-plane + data-plane access to Storage, Cosmos, Search; CMK on the Foundry KV |
| `{org}-id-sa-aishared` | Storage account (aishared) | CMK wrap/unwrap on the shared KV |
| `{org}-id-sa-aifoundry` | Storage account (aifoundry) | CMK wrap/unwrap on the shared KV |
| `{org}-id-cosmos-aicommon` | Cosmos DB (aicommon) | CMK wrap/unwrap on the shared KV |
| `{org}-id-redis-aicommon` | Managed Redis (aicommon) | CMK wrap/unwrap on the shared KV |
| `{org}-id-cr-aishared` | Container Registry (aishared) | CMK wrap/unwrap on the shared KV |
| `{org}-uami-rsv-aishared` | Recovery Services Vault (aishared) | CMK wrap/unwrap on the shared KV |
| `{org}-uami-bvault-aishared` | Backup Vault (aishared) | CMK wrap/unwrap on the shared KV |
| `{org}-uami-bvault-aifoundry` | Backup Vault (aifoundry) | CMK wrap/unwrap on the Foundry KV |

**Key Vaults:** `{org}-kv-aishared` (shared — holds most CMK keys) and `{org}-kv-aifoundry`
(dedicated — holds the Foundry account CMK key).

---

## Layer 1 — CMK Key Vault crypto roles

Config: `role_assignments_config_cmk` · Module: [`module "role_assignments_cmk"`](main.tf#L341)
(`role_assignments`). Each entry grants a resource's UMI a **key-vault crypto role** on the
CMK Key Vault so the resource can wrap/unwrap its customer-managed encryption key. Scope =
`module.key_vault[scope_key].resource_id`.

| Key | Identity | Scope (Key Vault) | Role |
|-----|----------|-------------------|------|
| `cmk-sa-aishared` | `{org}-id-sa-aishared` | `{org}-kv-aishared` | Key Vault Crypto Service Encryption User |
| `cmk-sa-aifoundry` | `{org}-id-sa-aifoundry` | `{org}-kv-aishared` | Key Vault Crypto Service Encryption User |
| `cmk-aif-aifoundry` | `{org}-id-aif-aishared` | `{org}-kv-aifoundry` | Key Vault Crypto Service Encryption User |
| **`cmk-aif-aifoundry-crypto-user`** | `{org}-id-aif-aishared` | `{org}-kv-aifoundry` | **Key Vault Crypto User** |
| `cmk-cosmos-aicommon` | `{org}-id-cosmos-aicommon` | `{org}-kv-aishared` | Key Vault Crypto Service Encryption User |
| `cmk-redis-aicommon` | `{org}-id-redis-aicommon` | `{org}-kv-aishared` | Key Vault Crypto Service Encryption User |
| `cmk-cr-aishared` | `{org}-id-cr-aishared` | `{org}-kv-aishared` | Key Vault Crypto Service Encryption User |
| `cmk-rsv-aishared` | `{org}-uami-rsv-aishared` | `{org}-kv-aishared` | Key Vault Crypto Service Encryption User |
| `cmk-bvault-aishared` | `{org}-uami-bvault-aishared` | `{org}-kv-aishared` | Key Vault Crypto Service Encryption User |
| `cmk-bvault-aifoundry` | `{org}-uami-bvault-aifoundry` | `{org}-kv-aifoundry` | Key Vault Crypto Service Encryption User |

> **⚠️ The two Foundry-KV grants are both required.** A CMK-encrypted Foundry account needs its
> UMI (`{org}-id-aif-aishared`) to hold **both** roles on `{org}-kv-aifoundry`:
> - **Key Vault Crypto Service Encryption User** — at-rest wrap/unwrap (the account creates fine).
> - **Key Vault Crypto User** — full key data-plane (encrypt/decrypt/sign/wrap/unwrap/get). This
>   is the role the **gpt-5.1 model-deployment content-safety validation** path uses. Without it,
>   deployment fails `400 "Failed to validate policies for model gpt-5.1/2025-11-13"` even though
>   the account itself provisions successfully.

---

## Layer 2 — AI Foundry control-plane roles (resource-group scope)

Config: `role_assignments_config_foundry` · Module: [`module "role_assignments_foundry"`](main.tf#L369)
(`role_assignments`). Grants the **shared Foundry identity** the ARM control-plane roles it
needs on the `aishared` / `aicommon` resource groups. Scope =
`module.resource_group[scope_key].resource_id` (RG-scoped, so it covers every resource in that RG).

| Key | Identity | Scope (Resource Group) | Role |
|-----|----------|------------------------|------|
| `aif-aishared_on_aishared_rg_search` | `{org}-id-aif-aishared` | `{org}-rg-aishared` | Search Service Contributor |
| `aif-aishared_on_aishared_rg_cosmos_operator` | `{org}-id-aif-aishared` | `{org}-rg-aishared` | Cosmos DB Operator |
| `aif-aishared_on_aicommon_rg_cosmos_operator` | `{org}-id-aif-aishared` | `{org}-rg-aicommon` | Cosmos DB Operator |
| `aif-aishared_on_aishared_rg_blob_contributor` | `{org}-id-aif-aishared` | `{org}-rg-aishared` | Storage Blob Data Contributor |
| `aif-aishared_on_aishared_rg_blob_owner` | `{org}-id-aif-aishared` | `{org}-rg-aishared` | Storage Blob Data Owner |

> The RG-scoped Storage Blob grants cover the Foundry account's BYO storage
> (`{org}-sa-aifoundry`, which lives in `{org}-rg-aishared`) — no per-resource storage grant needed.

---

## Layer 3 — Cosmos DB data-plane (SQL) role

Config: `cosmosdb_sql_role_assignments` · Resource:
[`azurerm_cosmosdb_sql_role_assignment.foundry_cosmos_data_plane`](main.tf#L1555). Control-plane
`Cosmos DB Operator` (Layer 2) does **not** grant data access — this SQL role does.

| Key | Identity | Scope (Cosmos account) | Role |
|-----|----------|------------------------|------|
| `aif-aishared_on_cosmos-aicommon` | `{org}-id-aif-aishared` | `{org}-cosmos-aicommon` (account scope) | Cosmos DB Built-in Data Contributor (`…/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002`) |

---

## Layer 4 — Inline Key Vault role assignments (data-plane, optional)

The `key_vault` module accepts an inline `role_assignments` map per vault (resolved by
literal `principal_id` **or** `umi_key`) — see the `merge()` in [main.tf](main.tf#L270).
**Currently none are defined** in `variables.tfvars`, so this layer is empty; it exists for
future per-vault data-plane grants (e.g. Key Vault Secrets User) without touching module code.

---

## Ordering & propagation

- **`time_sleep.rbac_wait_cmk` (60s)** — [main.tf](main.tf#L356) waits after the CMK role
  assignments before any CMK consumer (Storage/ACR/Redis/Cosmos/Backup/Foundry) performs key
  operations, so Azure AD RBAC has propagated to the key vault data plane.
- The `key_vault` module also sets `wait_for_rbac_before_key_operations = { create = "60s" }`
  so the runner identity can create key material after its own vault RBAC lands.
- `module.role_assignments_cmk` depends on `user_managed_identities` + `key_vault`;
  `module.role_assignments_foundry` depends on `user_managed_identities` + `resource_group`.

---

## Deploy SPN vs. provisioned RBAC

The assignments above are **created by** the deploy service principal — which therefore needs
**RBAC Administrator** (or User Access Administrator) on the workload subscriptions, plus **Key
Vault Administrator** for data-plane key operations. See the main
[README.md §Prerequisites](README.md) for the full deploy-SPN role set.

---

## Excluded (app-tier) RBAC

The dev-ai-latest `ai_rbac` stack also grants **AEA/ESPI app-layer** roles (function apps → AI
Search / Cosmos / Storage). These are **intentionally excluded** here — this pattern deploys the
shared base infra only, consolidating the reference's three per-project identities into the single
shared `{org}-id-aif-aishared` identity.
