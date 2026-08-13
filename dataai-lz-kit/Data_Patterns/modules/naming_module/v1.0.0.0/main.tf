# - Generate randomization (if asked)
# -
resource "random_id" "this" {
  count       = var.add_random == true ? 1 : 0
  byte_length = 3
}

# -
# - Generate Timestamp for the date created_on
# -
resource "time_static" "this" {}


locals {
  # -
  # - Generate the Azure Location name
  # -
  location_names = {
    "sea" = "Southeast Asia",
    "ea"  = "East Asia",
    "eu"  = "East US",
    "sg"  = "Singapore",
    "myw" = "Malaysia West",
    "idc" = "Indonesia Central"
  }

  # -
  # - Generate name separator (dash or no dash)
  # -
  separator = var.no_dashes == true ? "" : "-"

  # -
  # - Generate Random suffix (Defaults: number type, 3 digits, 0 padding)
  # -
  random_suffix = var.add_random == true ? format("%0${var.rnd_length}s", substr(random_id.this[0].dec, 0, var.rnd_length)) : ""

  # -
  # - Cascade that generates the Resource name
  # -

  # Build mandatory prefix
  resource_name_pref1 = join(local.separator, [var.org, var.resource_type_code, var.app_code, var.env, var.region_code])

  # Add base name, if any
  resource_name_pref2 = var.base_name != null && var.base_name != "" ? join(local.separator, [local.resource_name_pref1, var.base_name]) : local.resource_name_pref1

  # Add additional name, if any
  resource_name_pref3 = var.additional_name != null && var.additional_name != "" ? join(local.separator, [local.resource_name_pref2, var.additional_name]) : local.resource_name_pref2

  # Add iterator, if any
  resource_name_pref4 = var.iterator != null && var.iterator != "" ? join(local.separator, [local.resource_name_pref3, var.iterator]) : local.resource_name_pref3

  # Ensure remove dashes (some may come from witihn the variables' values)
  resource_name_pref5 = var.no_dashes == true ? replace(local.resource_name_pref4, "-", "") : local.resource_name_pref4

  # Trim to max length and generate completed resource name
  resource_name_pref6 = length(local.resource_name_pref5) > var.max_length ? substr(local.resource_name_pref5, 0, var.max_length) : local.resource_name_pref5


  # If selected, add the random id at the end by replacing the var.rnd_length last characters of the name
  resource_name = var.add_random == true ? "${substr(local.resource_name_pref5, 0, (var.max_length - (var.rnd_length + length(local.separator))))}${local.separator}${local.random_suffix}" : local.resource_name_pref5

  # -
  # - Generate Common tags
  # -
  mandatory_tags = {
    # Business Tags (Mandatory for Resources)
    AppName       = var.app_name
    AppSupport    = var.app_support
    BusinessUnit  = var.business_unit
    Country       = var.country
    BusinessOwner = var.business_owner
    Type          = var.type

    # DevOps Tags (Mandatory for Resources)
    ProductName    = var.product_name
    ProductVersion = var.product_version

    # Finance Tags (Mandatory for Resources)
    CostCenter         = var.cost_center
    CostAllocationUnit = var.cost_allocation_unit
    BudgetID           = var.budget_id
    BudgetLimit        = var.budget_limit
    CostAlertThreshold = var.cost_alert_threshold

    # Governance Tags (Mandatory for Resources)
    DataClassification = var.data_classification
    ComplianceRequired = var.compliance_required
    Compliance         = var.compliance

    # Operation Tags (Mandatory for Resources)
    Criticality = var.criticality
    Environment = var.environment
    Owner       = var.owner
    Status      = var.status

    # System Generated
    CreatedOn = formatdate("YYYY-MM-DD hh:mm ZZZ", time_static.this.rfc3339)
  }

  optional_tags = {
    # Optional Governance Tags
    DeleteAfter = var.delete_after
    Tier        = var.tier

    # Optional Operation Tags
    AppId              = var.app_id
    AutoDelete         = var.auto_delete
    AutoshutDown       = var.auto_shutdown
    Description        = var.description
    SandboxPurpose     = var.sandbox_purpose
    ReviewRequired     = var.review_required
    AutomationPolicy   = var.automation_policy
    BackupPolicy       = var.backup_policy
    DisasterRecovery   = var.disaster_recovery
    ExperimentPhase    = var.experiment_phase
    LastVMAccessed     = var.last_vm_accessed
    MaintenanceWindow  = var.maintenance_window
    NotificationEmails = join(",", var.notification_emails)
    OS                 = var.os
    PatchPolicy        = var.patch_policy
    Region             = var.region
    Retention          = var.retention
    SandboxType        = var.sandbox_type
    Service            = var.service

    # Subscription-only tags (optional when used in resource context)
    LandingZone  = var.landing_zone
    PlatformArea = var.platform_area
  }

  # Filter out empty optional tags
  filtered_optional_tags = {
    for k, v in local.optional_tags : k => v
    if v != null && v != ""
  }

  # Merge mandatory tags with filtered optional tags and additional tags
  generated_tags = merge(local.mandatory_tags, local.filtered_optional_tags)

  # Add additional_tags
  base_tags = merge(local.generated_tags, var.additional_tags != null ? var.additional_tags : {})
}
