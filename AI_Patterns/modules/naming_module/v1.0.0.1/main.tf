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
    "myw" = "Malaysia West",
    "sg"  = "Singapore",
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
  # - Generate Simplified Tags - Only the required 8 mandatory + 3 optional tags
  # -
  mandatory_tags = {
    # 8 Mandatory Tags as specified
    Environment        = var.environment
    BusinessOwner      = var.business_owner
    BusinessUnit       = var.business_unit
    Criticality        = var.criticality
    CostCenter         = var.cost_center
    DataClassification = var.data_classification
    Compliance         = var.compliance
    Owner              = var.owner # Using business_owner for Owner tag

    # System Generated
    CreatedOn = formatdate("YYYY-MM-DD hh:mm ZZZ", time_static.this.rfc3339)
  }

  optional_tags = {
    # 3 Optional Tags as specified
    Region             = var.region
    Description        = var.description
    NotificationEmails = var.notification_emails != null ? (length(var.notification_emails) > 0 ? join(",", var.notification_emails) : "") : ""
    ComplianceRequired = var.compliance_required
  }

  # Filter out empty optional tags
  filtered_optional_tags = {
    for k, v in local.optional_tags : k => v
    if v != null && v != ""
  }

  # Merge mandatory tags with filtered optional tags
  generated_tags = merge(local.mandatory_tags, local.filtered_optional_tags)

  # Add additional_tags if provided
  base_tags = merge(local.generated_tags, var.additional_tags != null ? var.additional_tags : {})
}
