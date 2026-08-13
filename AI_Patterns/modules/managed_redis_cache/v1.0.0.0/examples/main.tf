resource "azurerm_resource_group" "this" {
  location = "malaysiawest"
  name     = "rg-amr-tst-01"
}

module "managed_redis" {
  source = "../"

  # Naming module required variables
  env                = "prod"
  au                 = "00121"
  app_code           = "mgmt"
  bu                 = "it"
  owner              = "CEAT"
  resource_type_code = "amr"

  # Optional naming variables
  org             = "mbb"
  region_code     = "myw"
  base_name       = null
  additional_name = null
  iterator        = "01"
  max_length      = 128
  no_dashes       = false
  add_random      = false
  rnd_length      = 2

  # Mandatory Tags (Business)
  app_name       = "Automation, Monitoring and Management"
  app_support    = "mss_ceat@maybank.com"
  business_unit  = "GTD-ISD"
  business_owner = "Head of Cloud Engineering and Automation"
  type           = "Infrastructure"

  # Mandatory Tags (DevOps)
  product_name    = "managed_redis"
  product_version = "1.0.0.0"

  # Mandatory Tags (Finance)
  cost_center          = "383-80572"
  cost_allocation_unit = "383-80572"
  budget_id            = "83254"
  budget_limit         = "TBD"
  cost_alert_threshold = "80"

  # Mandatory Tags (Governance)
  data_classification = "Business Sensitive"
  compliance_required = "Yes"
  compliance          = "BNM RMIT"

  # Mandatory Tags (Operation)
  criticality = "T1"
  environment = "Prod"
  status      = "Live"

  # Optional tags
  region              = "MYW"
  description         = "Azure Managed Redis for caching"
  notification_emails = ["mss_ceat@maybank.com"]
  delete_after        = ""
  tier                = ""
  app_id              = ""
  auto_delete         = ""
  auto_shutdown       = ""
  backup_policy       = ""
  disaster_recovery   = ""

  # Managed Redis specific variables
  resource_group_name       = azurerm_resource_group.this.name
  sku_name                  = var.sku_name
  high_availability_enabled = true
  public_network_access     = "Disabled"

  managed_redis_identity = length(var.user_assigned_identity_ids) > 0 ? {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  } : null

  default_database = {
    access_keys_authentication_enabled = false
    client_protocol                    = "Encrypted"
    clustering_policy                  = "OSSCluster"
    eviction_policy                    = "VolatileLRU"
    modules                            = []
  }

  additional_tags = null
}
