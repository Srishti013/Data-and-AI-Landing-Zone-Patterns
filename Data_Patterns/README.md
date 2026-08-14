# Data Landing Zone (`Data_Patterns`)

Consolidated, single-stack Terraform for the **Data Landing Zone**, deployed
through a GitHub **issue-template** workflow — the same pattern used by the AI
landing zone (`data&AI_Patterns` + `.github/workflows/data-AI-pattern.yml`).

It collapses the five standalone reference roots (see the git-ignored
`ex-data/` — `data_shared`, `data_storage`, `data_ingestion`, `data_analytics`,
`data_rbac`) into **one** Terraform stack that builds the whole landing zone in
a single `apply`. Cross-folder dependencies that the reference resolves with
data sources are resolved here directly from module outputs.

## How to deploy

1. Merge this folder, `.github/ISSUE_TEMPLATE/deploy-data.yml`,
   `.github/workflows/data-pattern.yml` and `modulesdata.json` to the repo
   **default branch** (`main`). Issue-triggered workflows always run from the
   default branch, so changes only take effect once merged.
2. Open a new issue using **“Data Landing Zone Deployment Request”**. The title
   must start with `[DEPLOY-DATA]:`.
3. Select **Subscription / Environment / Region** and fill the naming + tag
   fields. Opening the issue triggers `data-pattern.yml`.

The workflow rewrites `variables.tfvars` from the issue selections (see
*Tokenisation* below), pulls the pinned modules from GHCR (via
`modulesdata.json`), then runs `init` / `plan` / `apply` against the selected
subscription.

## What it deploys

| Layer (reference root) | Resources |
| --- | --- |
| Shared (`data_shared`) | 5 resource groups (datashared/datastorage/dataingestion/dataanalytics/datagovernance), 3 NSGs, VNet + 3 subnets, route table, Key Vault (Premium, 2 CMK keys), Application Insights, SQL Server + database (TDE/CMK) + PE, KV admin-password secret |
| Storage (`data_storage`) | ADLS Gen2 storage account (ZRS, HNS, CMK) + blob/dfs private endpoints, CMK RBAC, Event Grid System Topic (BlobCreated → AI ESPI queue) |
| Ingestion (`data_ingestion`) | Azure Data Factory (managed VNet, system + user MI, Purview link, Azure + self-hosted IRs, managed PEs to SQL/ADLS) + dataFactory/portal private endpoints |
| Analytics (`data_analytics`) | Microsoft Fabric capacity (F16) |
| RBAC (`data_rbac`) | ADF (UMI + system MI) and Purview MSI role assignments over KV / ADLS / ADF |

## Files

| File | Purpose |
| --- | --- |
| `providers.tf` | Default provider (deployment sub via `var.subscription_id`) + `pvt_dns_zones_sub` / `law_sub` aliased providers + backend. |
| `variables.tf` | Scalars + `type = any` resource maps. |
| `locals.tf` | Subscription lookup, `location_by_region_code`, RBAC scope map, ADF system-principal map. |
| `data.tf` | Subscriptions, client config, shared Private DNS zones, central LAW, ADF system identities. |
| `main.tf` | All module blocks. |
| `outputs.tf` | Key resource ids. |
| `variables.tfvars` | Tokenised resource definitions. |

## Tokenisation

The workflow’s **Update tfvars** step:

- **Global value substitution** on `""` fields: `subscription_id`, `env`,
  `region_code`, `org`, `au`, `bu`, `owner`, `iterator`, `environment`,
  `region`, `business_owner`, `business_unit`, `criticality`, `cost_center`,
  `data_classification`, `compliance`, `app_name`, `budget_id`, `status`,
  `app_support`.
- **Token substitution** of `{env}` / `{region_code}` in map keys and name
  fields.

`app_code` / `resource_type_code` / `service` stay literal so each resource
gets a distinct name. `user_principal_name` / `object_id` / `log_analytics_*` are not
substituted and keep their literal values.

## State backend

`storage_account_name={org}satfmgmtpdmyw02`, `container_name={org}tfstatelz`,
`resource_group_name={org}-rg-mgmt-pd-myw-01`, key
`dataApp-<env_short>-<region_code>.tfstate` (one state per env+region).

## Environment / region mapping

| Environment | Code | Region | Code |
| --- | --- | --- | --- |
| Dev | `dev` | Malaysia West | `myw` |
| SIT | `sit` | Southeast Asia | `sea` |
| UAT | `uat` | | |
| Prod | `pd` | | |

## Notes / opt-in wiring

- **VNet / subnet CIDRs** are set in `variables.tfvars` (default data ranges
  `10.247.41.0/24` + `10.247.42.0/25`). Adjust per environment before deploying
  to a different address space — they are not rewritten by the workflow.
- **Event Grid System Topic** (ADLS `BlobCreated` → AI ESPI storage queue) is
  **cross-subscription**: the target queue + its storage account live in the AI
  landing-zone subscription (`{org}-ai-sub-tier4-<env>-<region>-01`). It is wired
  per the build sheet, but requires: (a) the AI ESPI storage/queue to already
  exist in the target environment, and (b) the deploying identity to have role-
  assignment rights in the AI subscription. The AI sub GUID in
  `role_assignments_config_egst` / the queue endpoint defaults to the **SIT** AI
  sub — update it (and the `{org}-uami-egst-data-...` scope) for other environments,
  or comment the two blocks out for a standalone test where the AI queue is absent.
- **Purview MSI** role assignments and the **self-hosted IR** cross-env link use
  literal ids for the reference environment. Update `principal_id` /
  `resource_id` for the target environment, or remove.
- **Private DNS zones** for all private endpoints are resolved from the shared
  zones in the platform network subscription (`pvt_dns_zones_sub`).

## Adding a subscription

Add the display name to the Subscription dropdown in
`.github/ISSUE_TEMPLATE/deploy-data.yml` **and** the `SUBSCRIPTION → ID` case
block in `.github/workflows/data-pattern.yml` (labels must match exactly).
