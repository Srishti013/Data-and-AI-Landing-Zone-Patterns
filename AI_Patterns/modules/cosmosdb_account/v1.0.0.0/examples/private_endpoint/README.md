# Cosmos DB with Private Endpoint Example

This example demonstrates how to deploy an Azure Cosmos DB account with a private endpoint for secure connectivity.

## Overview

This example creates:
- A Cosmos DB account (NoSQL/SQL API) with public network access disabled
- A virtual network and subnet for the private endpoint
- A private endpoint connecting the Cosmos DB to the subnet
- A private DNS zone for Cosmos DB SQL API (`privatelink.documents.azure.com`)
- DNS zone configuration to resolve private endpoint addresses

## Private Endpoint Subresource Names

The `subresource_name` parameter specifies which Cosmos DB API to connect to via the private endpoint:

| API Type | Subresource Name |
|----------|------------------|
| NoSQL (SQL API) | `Sql` |
| MongoDB | `MongoDB` |
| Cassandra | `Cassandra` |
| Table | `Table` |
| Gremlin | `Gremlin` |

## Private DNS Zones

Each Cosmos DB API type requires a specific private DNS zone:

| API Type | Private DNS Zone |
|----------|------------------|
| SQL/NoSQL | `privatelink.documents.azure.com` |
| MongoDB | `privatelink.mongo.cosmos.azure.com` |
| Cassandra | `privatelink.cassandra.cosmos.azure.com` |
| Table | `privatelink.table.cosmos.azure.com` |
| Gremlin | `privatelink.gremlin.cosmos.azure.com` |

## Key Features

### Private Endpoint Configuration
```hcl
private_endpoints = {
  pe_sql = {
    name                            = "pe-cosmos-sql"
    subnet_resource_id              = azurerm_subnet.example.id
    subresource_name                = "Sql"
    private_dns_zone_resource_ids   = [azurerm_private_dns_zone.cosmos_sql.id]
    private_dns_zone_group_name     = "default"
    private_service_connection_name = "psc-cosmos-sql"
    network_interface_name          = "nic-pe-cosmos-sql"
  }
}
```

### Optional Features

**Static IP Configuration:**
```hcl
ip_configurations = {
  static_ip = {
    name               = "static-ip-config"
    private_ip_address = "10.0.1.10"
  }
}
```

**Application Security Group Association:**
```hcl
application_security_group_associations = {
  asg1 = "/subscriptions/.../applicationSecurityGroups/asg-cosmos"
}
```

**Unmanaged DNS Zone Groups (for Azure Policy):**
```hcl
private_endpoints_manage_dns_zone_group = false
```

## Usage

1. Update the resource group name and other parameters to match your environment
2. Run `terraform init` to initialize the module
3. Run `terraform planTo` review the changes
4. Run `terraform apply` to create the resources

## Security Considerations

- **Public Access**: Set `public_network_access_enabled = false` to ensure all access goes through the private endpoint
- **Network Isolation**: The private endpoint provides secure connectivity within your virtual network
- **DNS Resolution**: Private DNS zones ensure that Cosmos DB endpoints resolve to private IP addresses within your network

## Outputs

- `cosmos_private_endpoints`: Details about the created private endpoints
- `cosmos_endpoint`: The Cosmos DB account endpoint URL
