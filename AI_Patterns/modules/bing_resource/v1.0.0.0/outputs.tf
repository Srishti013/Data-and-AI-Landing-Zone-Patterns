#####################
# Bing Account IDs
#####################

output "bing_account_ids" {
  description = "Map of Bing account resource IDs"
  value = {
    for k, v in azapi_resource.bing_account :
    k => v.id
  }
}

######################
# Bing Account Names
######################

output "bing_account_names" {
  description = "Map of Bing account names"
  value = {
    for k, v in azapi_resource.bing_account :
    k => v.name
  }
}

########################
# Bing Account Details
########################

output "bing_account_details" {
  description = "Detailed Bing account information"
  value = {
    for k, v in azapi_resource.bing_account :
    k => {
      id       = v.id
      name     = v.name
      location = v.location
      type     = v.type
    }
  }
}