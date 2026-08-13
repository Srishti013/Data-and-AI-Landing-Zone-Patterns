#--------------------------------------------------------------
#   Provider to access the Test Subscription
#--------------------------------------------------------------
provider "azurerm" {
  # Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference
  alias = "testSubscription" # Comment/Remove this alias as it may not be needed

  environment = "public"
  partner_id  = "########" #Add your Public ID here

  tenant_id       = "<Put here your environment related values>"
  subscription_id = "<Put here your environment related values>"
  client_id       = "<Put here your environment related values>"
  client_secret   = "<Put here your environment related values>"

  features {}
}