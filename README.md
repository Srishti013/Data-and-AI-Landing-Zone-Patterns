# Data + AI Landing Zone Kit

A standardized, org- and region-agnostic Infrastructure-as-Code kit for deploying
**Azure Data** and **AI** landing zones via a GitHub issue-driven pipeline. Any
project can adopt it by setting a handful of repo variables — no code edits.

---

## 1. What it deploys

**Data landing zone** (`Data_Patterns/`)
- Resource groups, spoke VNet + subnets, NSGs, route tables, hub peering
- Key Vault with **customer-managed key (CMK)**
- ADLS Gen2 Storage, Azure SQL, Azure Data Factory (managed VNet), Event Grid
- Microsoft Fabric capacity, private endpoints + private DNS, Recovery/Backup vault, App Insights

**AI landing zone** (`AI_Patterns/`) — aligned to the Microsoft AI landing-zone essentials:

| Essential | Included |
|---|---|
| Hub-Spoke networking (VNet, NSG, RT, Private DNS, Private Endpoints) | ✅ |
| Keyless credential architecture (User-Assigned Managed Identity everywhere) | ✅ |
| Azure APIM core ingress (internal AI gateway) | ✅ |
| Azure Cosmos DB (NoSQL session/audit store) | ✅ |
| Azure AI Search (vector caching) | ✅ |
| AI Foundry hub + model deployments + Responsible-AI policy | ✅ |
| AI Foundry **Projects per BU** | ⚠️ excluded by default (app-tier filter) — re-enable via `var.ai_foundry_projects` |
| Azure Policy guardrails ("Policies IP") | ❌ separate governance layer, not in this kit |

---

## 2. Repository structure

```
.
├─ Data_Patterns/     # Data spoke (Terraform + vendored modules/)
├─ AI_Patterns/       # AI spoke (Terraform + vendored modules/)
├─ scripts/           # runner-cloud-init.yaml (self-hosted runner bootstrap)
├─ .github/
│  ├─ workflows/      # data-pattern, ai-pattern (the spokes)
│  └─ ISSUE_TEMPLATE/ # deploy-data, deploy-ai
└─ .gitignore
```

**Modules are vendored** (committed under each stack's `modules/`) — no private registry / `oras` pull is used.

---

## 3. Design principles

- **Org-agnostic** — resource names come from the `org` field; platform references use an `{org}` token rewritten by the workflow. Enter any org code (e.g. `acme`).
- **Region-agnostic** — `{region_code}` / `{location}` tokens; `location_by_region_code` covers the naming enum `[ea, sea, eu, myw, sg, idc]`.
- **Portable identity** — no hardcoded tenant, subscription, group or principal IDs; all supplied via repo variables/secrets.
- **Keyless** — UAMI + `disableLocalAuth`; no connection strings or API keys.
- **Private by default** — private endpoints + private DNS + hub peering.

---

## 4. Prerequisites (must already exist)

> This kit deploys the Data/AI **spokes**. It assumes the platform **connectivity hub** and **Log Analytics Workspace** are already in place (create them however your org normally does).

1. **Connectivity hub** — a VNet `{org}-vnet-pvt-network-pd-{region_code}-01` in RG `{org}-rg-private-network-pd-{region_code}-01`, with the privatelink DNS zones (vaultcore, database, blob, dfs, queue, file, openai, cognitiveservices, services.ai, documents, search, azurecr, azure-api.net) linked to it, and a DNS Private Resolver inbound endpoint (its IP goes in the deploy issue form's **DNS Resolver IP** field).
2. **Log Analytics Workspace** — `{org}-law-ops-pd-{region_code}-01` in RG `{org}-rg-mgmt-pd-{region_code}-01`.
3. **Terraform state** — a Storage Account + container + resource group.
4. **Self-hosted runner** — an Ubuntu VM in the hub's PE subnet (so private-endpoint DNS resolves during `apply`). Bootstrap it with `scripts/runner-cloud-init.yaml` (installs terraform, az, jq, checkov, tflint, tfsec + the runner agent). By default the workflows target any `self-hosted, Linux, X64` runner; to pin them to a specific runner pool, set the `RUNNER_LABELS` repo variable (JSON array, e.g. `["self-hosted","Linux","X64","my-pool"]`) and register the runner with those labels.

---

## 5. Configuration

**Repo Secrets** (Settings → Secrets and variables → Actions → Secrets)

| Secret | Purpose |
|---|---|
| `AZURE_CLIENT_ID` | OIDC app registration (SPN) client id |
| `AZURE_TENANT_ID` | Tenant id (also fills the APIM JWT `{tenant}`) |
| `TFSTATE_SUBSCRIPTION_ID` | Subscription hosting the state account |
| `GH_TOKEN` | PAT (`repo` scope) for the auto-close-issue step |

**Repo Variables**

| Variable | Purpose |
|---|---|
| `WORKLOAD_SUBSCRIPTION_ID` | Subscription the spoke deploys into |
| `TFSTATE_STORAGE_ACCOUNT` / `TFSTATE_CONTAINER` / `TFSTATE_RESOURCE_GROUP` | State backend |
| `BASTION_CIDR` *(optional)* | AzureBastionSubnet CIDR for the Allow-Bastion-RDP-SSH NSG rule; leave unset to drop that rule entirely (no bastion needed) |
| `SQL_ADMIN_UPN` / `SQL_ADMIN_OBJECT_ID` | Azure AD SQL admin (both spokes) |
| `FABRIC_ADMIN_UPN` *(optional)* | Fabric capacity admin (falls back to `SQL_ADMIN_UPN`) |
| `PURVIEW_ID` *(optional)* | If set, links ADF to your Purview account; empty = no Purview |
| `RUNNER_LABELS` *(optional)* | JSON array of runner labels to target (default `["self-hosted","Linux","X64"]`) |

**SPN RBAC**: Contributor + User Access Administrator on the workload sub; Network + Private DNS Zone Contributor on the hub; Log Analytics Contributor on management; Storage Blob Data Contributor on the state account.

> **Optional Azure Policy guardrail layer** (`AI_Patterns/policies`, triggered by `Deploy AI LZ policies = Yes`): the SPN additionally needs **Resource Policy Contributor** on the workload sub to create the policy definitions and subscription assignments. The existing **User Access Administrator** already covers the remediation role assignments that the `Modify` policies create for their managed identities. Contributor alone cannot write to `Microsoft.Authorization/*`, so without Resource Policy Contributor the policy apply fails with `AuthorizationFailed`.

**Resource providers**: register (or use provider `resource_provider_registrations = "extended"`): Microsoft.Network, Storage, KeyVault, ManagedIdentity, Authorization, Insights, OperationalInsights, EventGrid, DataFactory, DataProtection, Sql, RecoveryServices, Fabric, CognitiveServices, ApiManagement, DocumentDB, Search, Cache, ContainerRegistry, App, ContainerService.

---

## 6. Deploy

Open a GitHub issue from the template:
- **Deploy Data** → title `[DEPLOY-DATA]:` — set Organisation Code, Region, Iterator, and CIDRs (within/aligned to your address plan, not overlapping the hub).
- **Deploy AI** → title `[DEPLOY-AI]:` — same, plus the Foundry agent/PE subnet ranges.

The workflow parses the issue, tokenizes the tfvars, and runs `init → plan → apply` on the self-hosted runner using the vendored modules.

**Recommended order:** Data spoke, then AI spoke (the hub + LAW already exist).

---

## 7. Notes & limitations

- The issue **Region** dropdown maps *Malaysia West* / *Southeast Asia*; add a `case` entry + template option for other regions (region code must be in the naming enum).
- **Fabric capacity (F4)** and **gpt-5.x** deployments depend on subscription quota/availability — verify with `az cognitiveservices usage list` / provider registration.
- AI Foundry **Projects**, project connections, and capability hosts are deferred by default; re-enable together if you need the agent service.
- Internal tfvars map keys and vendored module folder names retain their original prefixes — these are code identifiers and are never deployed to Azure.
