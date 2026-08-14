[[_TOC_]]

# Document Change Log

| Status | <span style="background:green;padding: 0px 5px;text-align:center;color:white;">**READY**</span> |
| --- | --- |
| Version | 1 |
| Created By | Pooja Pradhan |
| Reviewed By | Amit Kumar |

# About this product version

## Product State: Released

## Product Category

- Integration

## Notable changes in this version

### v1

- Initial version to deploy Azure API Management policy templates (`apim_policies`).

## Upgrade Path

- Not available as this is the initial version.

# Product Description

## Overview

- This module provides a library of reusable, pre-approved XML policy templates for Azure API Management.
- Templates are parameterised using `${}` substitution variables and rendered at deployment time via the `apim_api` module's `policy_template` + `policy_vars` inputs.
- Policies cover correlation ID propagation, JWT validation, mTLS, IP filtering, rate limiting, quota, CORS, URI rewriting, security headers, and backend timeout/retry with logging.
- Two global mandated policy files are included for internal and external APIM instances.

## Note

- This module contains only XML template files — it does not deploy any Terraform resources directly.
- Templates must be referenced by path from the consuming module (e.g., `apim_api`) using `${path.module}`-relative paths.

## Network Topology (wherever applicable)

- This module does not create networking resources. Policy templates are applied to existing APIM entities.

## Azure Service(s) in Scope

- Azure API Management (policy configuration)

## Azure Services Needed (Pre-Requisites)

- Existing Azure API Management service
- Existing APIM APIs and operations (managed via `apim_api`)

## Optional Azure services Used (Customer Choice)

- Azure Application Insights (referenced in `10-backend-timeout-retry-log.xml`)

## Limitations

- All template variables must be supplied in `policy_vars` — missing keys cause a Terraform render error.
- Policy scope (global, product, API, operation) is determined by where the template is applied, not by the template itself.

# Product Security

- In Progress

# Product Usage Guidance

## Overview

- Reference policy template files from the `apim_api` module using the `policy.policy_template` and `policy.policy_vars` inputs on an API or operation.

## Pre-requisites

### Dependencies and Versions

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | >= 4.0, < 5.0 |

### Github Package

| Name | Source | Version |
|------|--------|---------|
| apim_policies | [IAC link](https://github.com/your-org/iac-modules/tree/main/modules/apim_policies) | v1.0.0.0 |

## Sample pipeline code snippet to use the product

### How to use this product in Terraform

```main.tf
module "apim_api" {
  source = "../../modules/apim_api/v1.0.0.0"

  apim_name           = var.apim_name
  resource_group_name = var.resource_group_name

  apis = {
    "orders" = {
      display_name = "Orders API"
      path         = "orders"
      service_url  = "https://backend-orders.internal.local"

      # API-level policy — correlation ID propagation
      policy = {
        policy_template = "${path.module}/../../modules/apim_policies/v1.0.0.0/01-correlation.xml"
        policy_vars = {
          correlation_variable_name = "corrId"
          correlation_header_name   = "x-correlation-id"
          header_exists_action      = "override"
        }
      }

      operations = {
        "get-orders" = {
          display_name = "Get Orders"
          method       = "GET"
          url_template = "/"

          # Operation-level policy — rate limiting
          policy = {
            policy_template = "${path.module}/../../modules/apim_policies/v1.0.0.0/05-rate-limit-by-key.xml"
            policy_vars = {
              rate_limit_calls               = "100"
              rate_limit_period              = "60"
              rate_limit_counter_key         = "@(context.Subscription.Id)"
            }
          }
        }
      }
    }
  }
}
```

## Policy Template Reference

### Included Templates

| File | Policy Type | Description |
|------|-------------|-------------|
| `01-correlation.xml` | API / Operation | Propagates a correlation ID header through inbound, backend, and outbound flows |
| `02-validate-jwt.xml` | API / Operation | Validates a JWT bearer token against an OpenID Connect endpoint |
| `03-mtls-client-cert.xml` | API / Operation | Enforces mutual TLS by validating the client certificate |
| `04-ip-allowlist.xml` | API / Operation | Restricts access by IP address filter (allow or deny) |
| `05-rate-limit-by-key.xml` | API / Operation | Rate-limits requests by a configurable counter key |
| `06-quota-by-key.xml` | API / Operation | Enforces a call quota by a configurable counter key |
| `07-cors.xml` | API / Operation | Configures CORS allowed origins, methods, and headers |
| `08-rewrite-uri.xml` | API / Operation | Rewrites the incoming request URI before forwarding to the backend |
| `09-security-headers.xml` | API / Operation | Injects security response headers (HSTS, X-Content-Type-Options, etc.) |
| `10-backend-timeout-retry-log.xml` | API / Operation | Sets backend timeout, retry behaviour, and request/response logging |
| `global_mandated_ExternalAPIM_policies.xml` | Global | Mandated global policy for external-facing APIM instances |
| `global_manadated_InternalAPIM_policies.xml` | Global | Mandated global policy for internal APIM instances |

### Template Variables Reference

| Template | Variable | Description |
|----------|----------|-------------|
| `01-correlation.xml` | `correlation_variable_name` | APIM context variable name to store the correlation ID |
| `01-correlation.xml` | `correlation_header_name` | HTTP header name for the correlation ID (e.g., `x-correlation-id`) |
| `01-correlation.xml` | `header_exists_action` | Header action when it already exists (`override`, `skip`, `append`) |
| `02-validate-jwt.xml` | `jwt_header_name` | HTTP header carrying the JWT (e.g., `Authorization`) |
| `02-validate-jwt.xml` | `jwt_failed_status_code` | HTTP status code returned on validation failure (e.g., `401`) |
| `02-validate-jwt.xml` | `jwt_failed_message` | Error message returned on validation failure |
| `02-validate-jwt.xml` | `jwt_require_expiry` | Whether expiry claim is required (`true`/`false`) |
| `02-validate-jwt.xml` | `jwt_scheme` | Expected token scheme (e.g., `Bearer`) |
| `02-validate-jwt.xml` | `openid_config_url` | OpenID Connect discovery URL |
| `02-validate-jwt.xml` | `jwt_audience` | Expected JWT audience value |
| `02-validate-jwt.xml` | `jwt_issuer` | Expected JWT issuer value |
| `03-mtls-client-cert.xml` | `mtls_failure_status_code` | HTTP status code returned when certificate is invalid |
| `03-mtls-client-cert.xml` | `mtls_failure_reason` | Reason phrase returned when certificate is invalid |
| `04-ip-allowlist.xml` | `ip_filter_action` | Filter action (`allow` or `forbid`) |
| `04-ip-allowlist.xml` | `ip_ranges_block` | XML `<address>` or `<address-range>` elements to include |
| `05-rate-limit-by-key.xml` | `rate_limit_calls` | Number of calls allowed in the renewal period |
| `05-rate-limit-by-key.xml` | `rate_limit_period` | Renewal period in seconds |
| `05-rate-limit-by-key.xml` | `rate_limit_counter_key` | Policy expression used as the counter key |
| `06-quota-by-key.xml` | `quota_calls` | Maximum number of calls in the quota period |
| `06-quota-by-key.xml` | `quota_period` | Quota renewal period in seconds |
| `06-quota-by-key.xml` | `quota_counter_key` | Policy expression used as the quota counter key |
| `07-cors.xml` | `cors_allowed_origins_block` | XML `<origin>` elements for allowed origins |
| `07-cors.xml` | `cors_preflight_max_age` | Preflight result cache duration in seconds |
| `07-cors.xml` | `cors_allowed_methods_block` | XML `<method>` elements for allowed HTTP methods |
| `08-rewrite-uri.xml` | `rewrite_template` | URI template to rewrite to |
| `08-rewrite-uri.xml` | `rewrite_copy_unmatched_params` | Whether to copy unmatched query params (`true`/`false`) |
| `09-security-headers.xml` | `security_header_exists_action` | Header action for security headers (`override`, `skip`) |
| `09-security-headers.xml` | `hsts_value` | Value for `Strict-Transport-Security` header |
| `10-backend-timeout-retry-log.xml` | `backend_timeout_seconds` | Backend forwarding timeout in seconds |
| `10-backend-timeout-retry-log.xml` | `retry_condition` | Policy expression for retry condition |
| `10-backend-timeout-retry-log.xml` | `retry_count` | Number of retry attempts |
| `10-backend-timeout-retry-log.xml` | `retry_interval_seconds` | Interval between retries in seconds |

## Terraform Module Documentation

### Inputs

Not applicable — this module contains XML policy templates only and does not expose Terraform variables.

### Resources

Not applicable — this module contains XML policy templates only and does not deploy Terraform resources.

### Outputs

Not applicable — this module contains XML policy templates only and has no Terraform outputs.

## Overview

This is the () standardized implementation of **Azure API Management Policies** module.  
This module enforces reusable **policy templates, fragments, and policy documents** across APIM instances

## What's in v1.0.0.0

Initial baseline release for enterprise APIM policy management with hardcoded security baselines.



## Module Configuration

This module supports the following configurations:

- **Global policies** – Applied to all APIs (e.g., base authentication, logging)
- **Product policies** – Applied to all APIs within a product
- **API-level policies** – Applied to all operations within an API
- **Operation-level policies** – Applied to specific API endpoints
- **Policy fragments** – Reusable policy XML snippets (e.g., custom validation, rate-limiting formulas)
- **Policy templates** – Pre-approved policy patterns for common scenarios

---

## Requirements

The following requirements are needed by this module:

- Terraform >= 1.9, < 2.0
- Azure Provider >= 4.0
- Existing APIM instance (created by `internal_apim` or `External_apim`)
- Required providers as defined in `versions.tf`

---

## Policy Structure

### Global Policies (APIM Level)

Applied to ALL APIs and operations in the APIM instance:

```xml
<policies>
  <inbound>
    <!-- Authentication: JWT validation for all APIs -->
    <validate-jwt openid-config-url="..." audiences="..." />
    
    <!-- Rate limiting: Global throttle -->
    <rate-limit calls="1000" renewal-period="60" />
    
    <!-- Security headers enforcement -->
    <set-header name="X-Request-ID" exists-action="override">
      <value>@(Guid.NewGuid())</value>
    </set-header>
    
    <!-- Correlation ID for tracing -->
    <set-header name="X-Correlation-ID" exists-action="override">
      <value>@(context.Request.Headers.GetValueOrDefault("X-Correlation-ID", Guid.NewGuid().ToString()))</value>
    </set-header>
    
    <!-- Strict Transport Security -->
    <set-header name="Strict-Transport-Security" exists-action="override">
      <value>max-age=31536000; includeSubDomains</value>
    </set-header>
  </inbound>
  
  <outbound>
    <!-- Remove sensitive headers -->
    <set-header name="Server" exists-action="delete" />
    <set-header name="X-Powered-By" exists-action="delete" />
    
    <!-- Log all responses -->
    <log-to-eventhub logger-id="central-logger" />
  </outbound>
  
  <on-error>
    <!-- Error handling and logging -->
    <log-to-eventhub logger-id="error-logger" />
  </on-error>
</policies>
```

### Product Policies

Applied to all APIs within a product (scope: Product):

```xml
<policies>
  <inbound>
    <!-- Product-specific rate limit (stricter than global) -->
    <rate-limit calls="500" renewal-period="60" counter-key="subscription" />
    
    <!-- Subscription key validation -->
    <validate-status-code>200 201 202 400 401 403 404 500</validate-status-code>
  </inbound>
</policies>
```

### API-Level Policies

Applied to all operations within an API:

```xml
<policies>
  <inbound>
    <!-- API version enforcement -->
    <set-header name="API-Version" exists-action="override">
      <value>v1.0.0</value>
    </set-header>
    
    <!-- Content-type validation -->
    <validate-content-type allowed-content-types="application/json" />
    
    <!-- Request payload size limit (10MB) -->
    <set-header name="Content-Length" exists-action="override">
      <value>@(Math.Min(long.Parse(context.Request.Headers.GetValueOrDefault("Content-Length", "10485760")), 10485760))</value>
    </set-header>
  </inbound>
  
  <backend>
    <!-- Timeout: 30 seconds -->
    <forward-request timeout="30" />
  </backend>
  
  <outbound>
    <!-- Mask sensitive data in responses -->
    <replace-string from="creditCardNumber" to="XXXX-XXXX-XXXX-XXXX" />
    <replace-string from="ssn" to="XXX-XX-XXXX" />
  </outbound>
</policies>
```

### Operation-Level Policies

Applied to specific endpoints (e.g., POST operations):

```xml
<policies>
  <inbound>
    <!-- Stricter rate limit for write operations -->
    <rate-limit calls="50" renewal-period="60" counter-key="subscription" />
    
    <!-- Require OAuth2 scope for POST -->
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
      <openid-config url="https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration" />
      <required-claims>
        <claim name="scope">
          <value>api://myapi/write</value>
        </claim>
      </required-claims>
    </validate-jwt>
  </inbound>
</policies>
```

---

## Policy Fragments (Reusable Components)

Policy fragments are stored and referenced across multiple policies:

### Rate Limit Fragment

```xml
<!-- Fragment: rate-limit-standard -->
<rate-limit calls="1000" renewal-period="60" counter-key="caller-ip" />
```

**Usage in Policy:**
```xml
<policies>
  <inbound>
    <include-fragment fragment-id="rate-limit-standard" />
  </inbound>
</policies>
```

### JWT Validation Fragment

```xml
<!-- Fragment: validate-jwt-standard -->
<validate-jwt 
  openid-config-url="https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration" 
  audiences="api://myapi" 
  failed-validation-httpcode="401" />
```

### Security Headers Fragment

```xml
<!-- Fragment: security-headers -->
<set-header name="X-Content-Type-Options" exists-action="override">
  <value>nosniff</value>
</set-header>
<set-header name="X-Frame-Options" exists-action="override">
  <value>DENY</value>
</set-header>
<set-header name="X-XSS-Protection" exists-action="override">
  <value>1; mode=block</value>
</set-header>
<set-header name="Content-Security-Policy" exists-action="override">
  <value>default-src 'self'</value>
</set-header>
```

---

## Policy Scope Hierarchy

```
┌────────────────────────────────────┐
│  Global Policies (All APIs)        │  ← Applies to entire APIM
├────────────────────────────────────┤
│  ↓
├────────────────┬───────────────────┤
│  Product A     │  Product B        │  ← Product-level policies
├────────────────┼───────────────────┤
│  ↓             │  ↓
├─────────┬──────┼─────────┬──────────┤
│ API 1   │ API 2│ API 3   │ API 4   │  ← API-level policies
├─────────┼──────┼─────────┼──────────┤
│ GET     │ POST │ GET     │ DELETE   │  ← Operation-level policies
└─────────┴──────┴─────────┴──────────┘
```

**Evaluation Order:**
1. Global inbound policies execute first
2. Product inbound policies execute
3. API inbound policies execute
4. Operation inbound policies execute
5. Backend request is forwarded
6. Operation outbound policies execute
7. API outbound policies execute
8. Product outbound policies execute
9. Global outbound policies execute last

---

## Policy Variables

Policies reference dynamic variables from configuration:

```hcl
global_policy_vars = {
  rate_limit_calls       = "1000"
  rate_limit_period      = "60"
  rate_limit_counter_key = "subscription"
  
  quota_calls       = "10000"
  quota_period      = "3600"
  quota_counter_key = "subscription"
}
```

**Referenced in Policy XML:**
```xml
<rate-limit 
  calls="@(int.Parse(context.Variables["rate_limit_calls"]))" 
  renewal-period="@(int.Parse(context.Variables["rate_limit_period"]))" 
  counter-key="@((string)context.Variables["rate_limit_counter_key"])" />
```

---

## Common Policy Patterns

### Pattern 1: API Key + JWT Validation

```xml
<policies>
  <inbound>
    <!-- Require subscription key -->
    <check-header name="Ocp-Apim-Subscription-Key" failed-check-httpcode="401" />
    
    <!-- Validate JWT token -->
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
      <openid-config url="https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration" />
      <audiences>
        <audience>api://myapi</audience>
      </audiences>
    </validate-jwt>
  </inbound>
</policies>
```

### Pattern 2: IP Whitelisting + Rate Limiting

```xml
<policies>
  <inbound>
    <!-- Allow only specific IPs -->
    <ip-filter action="allow">
      <address>10.0.0.0/8</address>
      <address>172.16.0.0/12</address>
    </ip-filter>
    
    <!-- Rate limit per IP -->
    <rate-limit-by-key calls="100" renewal-period="60" counter-key="@(context.Request.IpAddress)" />
  </inbound>
</policies>
```

### Pattern 3: Request Transformation + Logging

```xml
<policies>
  <inbound>
    <!-- Log request -->
    <log-to-eventhub logger-id="request-logger">
      @{
        return new {
          timestamp = DateTime.UtcNow,
          api = context.Api.Name,
          operation = context.Operation.Name,
          requestId = context.RequestId,
          ipAddress = context.Request.IpAddress
        };
      }
    </log-to-eventhub>
    
    <!-- Transform request -->
    <set-body>@{
      var body = context.Request.Body.As<JObject>();
      body["processedBy"] = "APIM";
      body["timestamp"] = DateTime.UtcNow.ToString("o");
      return body.ToString();
    }</set-body>
  </inbound>
</policies>
```

---


<!-- END_TF_DOCS -->
