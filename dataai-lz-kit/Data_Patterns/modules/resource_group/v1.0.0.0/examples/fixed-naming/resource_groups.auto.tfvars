# Fixed resource_groups.auto.tfvars - corrected naming to avoid duplicate "shared"

resource_groups = {
  "mbb-rg-shared-sb-myw-01" = {
    env                = "sb"
    org                = "mbb"
    region_code        = "myw"
    base_name          = "" # REMOVED - no base_name to avoid duplication
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    app_code           = "shared" # This provides the "shared" in the name
    bu                 = "it"
    owner              = "infra@maybank.com"
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name       = "Shared Services"
    app_support    = "support@maybank.com"
    business_unit  = "IT"
    country        = "MY"
    business_owner = "Infra Team"
    type           = "Shared"

    product_name    = "mbb_resource_group"
    product_version = "1.0.0"

    cost_center          = "CC-10001"
    cost_allocation_unit = "CAU-IT-001"
    budget_id            = "BDG-2025-001"
    budget_limit         = "100000"
    cost_alert_threshold = "90000"

    data_classification = "Internal"
    compliance_required = "Yes"
    compliance          = "ISO 27001"

    criticality = "High"
    environment = "sb"
    status      = "Live"

    description = "Shared resource group for sandbox"
    region      = "Malaysia West"
  }

  "mbb-rg-app-sb-myw-01" = {
    env                = "sb"
    org                = "mbb"
    region_code        = "myw"
    base_name          = "" # REMOVED - no base_name to avoid duplication
    additional_name    = ""
    iterator           = "01"
    au                 = "00121"
    app_code           = "app" # This provides the "app" in the name
    bu                 = "it"
    owner              = "appteam@maybank.com"
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name       = "App Services"
    app_support    = "support@maybank.com"
    business_unit  = "IT"
    country        = "MY"
    business_owner = "App Team"
    type           = "Application"

    product_name    = "mbb_resource_group"
    product_version = "1.0.0"

    cost_center          = "CC-10002"
    cost_allocation_unit = "CAU-IT-002"
    budget_id            = "BDG-2025-002"
    budget_limit         = "80000"
    cost_alert_threshold = "70000"

    data_classification = "Internal"
    compliance_required = "Yes"
    compliance          = "ISO 27001"

    criticality = "High"
    environment = "sb"
    status      = "Live"

    description = "App resource group for sandbox"
    region      = "Malaysia West"
  }
}