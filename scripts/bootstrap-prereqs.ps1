#requires -Version 5.1
<#
.SYNOPSIS
  Idempotently (re)creates all prerequisites the Data/AI landing-zone workflows
  depend on, so the demo can be torn down and stood back up on demand.

  Creates, in the target subscription:
    1. Resource-provider registrations
    2. Terraform state backend (RG + Storage Account + container)
    3. GitHub OIDC service principal + federated credentials + RBAC
    4. Hub network (RG, VNet, subnets, Private DNS Resolver, all Private DNS
       Zones + VNet links)
    5. Management RG + Log Analytics Workspace
    6. (optional) the self-hosted runner VM

  Everything is idempotent: re-running skips resources that already exist.

.NOTES
  Requires: Azure CLI (logged in to the TARGET tenant), the dns-resolver az
  extension (auto-installed). Run this BEFORE any workflow - a workflow cannot
  create its own OIDC identity or runner.

.EXAMPLE
  ./bootstrap-prereqs.ps1 -SubscriptionId 05a4028e-... -GitHubOwner Srishti013 `
     -GitHubRepo Data-and-AI-Landing-Zone-Patterns
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$SubscriptionId,
  [Parameter(Mandatory)][string]$GitHubOwner,
  [Parameter(Mandatory)][string]$GitHubRepo,

  [string]$Location    = 'southeastasia',
  [string]$RegionCode  = 'sea',
  [string]$Org         = 'test',
  [string]$Env         = 'pd',
  [string]$Branch      = 'main',

  # Hub addressing (must not overlap the workload CIDRs used in deploy issues).
  [string]$VnetCidr            = '10.247.130.0/23',
  [string]$InboundDnsSubnetCidr= '10.247.130.192/27',
  [string]$PeSubnetCidr        = '10.247.131.0/26',
  [string]$ResolverInboundIp   = '10.247.130.196',

  # State backend. Storage account name is auto-generated if not supplied.
  [string]$StateResourceGroup  = 'rg-tfstate-lzdemo',
  [string]$StateStorageAccount = '',
  [string]$StateContainer      = 'tfstate',

  [string]$SpnName             = 'sp-lzdemo-github-oidc',

  [switch]$CreateRunnerVm,
  [string]$RunnerVmSize        = 'Standard_B2s',
  [string]$RunnerAdminUser     = 'azureuser'
)

$ErrorActionPreference = 'Stop'
function Say($m){ Write-Host "==> $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "    $m" -ForegroundColor Green }

# ---------------------------------------------------------------------------
# 0. Context
# ---------------------------------------------------------------------------
Say "Setting subscription $SubscriptionId"
az account set --subscription $SubscriptionId | Out-Null
$tenantId = az account show --query tenantId -o tsv

# Derived resource names (mirror the demo naming convention).
$netRg      = "$Org-rg-private-network-$Env-$RegionCode-01"
$vnetName   = "$Org-vnet-pvt-network-$Env-$RegionCode-01"
$inSubnet   = "$Org-snet-inbound-dns-$Env-$RegionCode-01"
$peSubnet   = "$Org-snet-pe-nw-$Env-$RegionCode-01"
$resolver   = "$Org-dnspr-nw-$Env-$RegionCode-01"
$inEndpoint = "$Org-in-dnspr-nw-$Env-$RegionCode-01"
$mgmtRg     = "$Org-rg-mgmt-$Env-$RegionCode-01"
$law        = "$Org-law-ops-$Env-$RegionCode-01"
$runnerVm   = "$Org-vm-runner-$Env-$RegionCode-01"

# ---------------------------------------------------------------------------
# 1. Resource providers
# ---------------------------------------------------------------------------
Say "Registering resource providers"
$rps = @(
  'Microsoft.Network','Microsoft.Storage','Microsoft.KeyVault','Microsoft.ManagedIdentity',
  'Microsoft.Authorization','Microsoft.Insights','Microsoft.OperationalInsights','Microsoft.EventGrid',
  'Microsoft.DataFactory','Microsoft.DataProtection','Microsoft.Sql','Microsoft.RecoveryServices',
  'Microsoft.Fabric','Microsoft.CognitiveServices','Microsoft.ApiManagement','Microsoft.DocumentDB',
  'Microsoft.Search','Microsoft.Cache','Microsoft.ContainerRegistry','Microsoft.App','Microsoft.ContainerService'
)
foreach ($rp in $rps) { az provider register -n $rp --only-show-errors 2>&1 | Out-Null }
Ok "Requested registration for $($rps.Count) providers (async)."

# ---------------------------------------------------------------------------
# 2. Terraform state backend
# ---------------------------------------------------------------------------
Say "Terraform state backend"
az group create -n $StateResourceGroup -l $Location --only-show-errors -o none
if (-not $StateStorageAccount) {
  $StateStorageAccount = 'sttflz' + -join ((97..122)+(48..57) | Get-Random -Count 6 | ForEach-Object {[char]$_})
}
$saExists = az storage account show -n $StateStorageAccount -g $StateResourceGroup --query name -o tsv 2>$null
if (-not $saExists) {
  az storage account create -n $StateStorageAccount -g $StateResourceGroup -l $Location `
    --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 --https-only true `
    --allow-blob-public-access false --only-show-errors -o none
}
az storage container create --name $StateContainer --account-name $StateStorageAccount `
  --auth-mode login --only-show-errors -o none 2>$null | Out-Null
Ok "State: RG=$StateResourceGroup SA=$StateStorageAccount container=$StateContainer"

# ---------------------------------------------------------------------------
# 3. GitHub OIDC service principal + federated credentials + RBAC
# ---------------------------------------------------------------------------
Say "GitHub OIDC service principal"
$appId = az ad app list --display-name $SpnName --query "[0].appId" -o tsv
if (-not $appId) {
  $appId = az ad app create --display-name $SpnName --query appId -o tsv
  Ok "Created app $SpnName ($appId)"
} else { Ok "App exists ($appId)" }

$spObjId = az ad sp show --id $appId --query id -o tsv 2>$null
if (-not $spObjId) { $spObjId = az ad sp create --id $appId --query id -o tsv }

# Federated credentials: classic subject + immutable subject (numeric ids).
function Ensure-Fic($name,$subject){
  $exists = az ad app federated-credential list --id $appId --query "[?name=='$name'].name" -o tsv
  if (-not $exists) {
    $tmp = [IO.Path]::GetTempFileName() -replace '\.tmp$','.json'
    @{ name=$name; issuer='https://token.actions.githubusercontent.com'; subject=$subject;
       audiences=@('api://AzureADTokenExchange') } | ConvertTo-Json | Set-Content -Path $tmp -Encoding ascii
    az ad app federated-credential create --id $appId --parameters "@$tmp" --only-show-errors -o none
    Remove-Item $tmp -Force
    Ok "FIC '$name' -> $subject"
  } else { Ok "FIC '$name' exists" }
}
Ensure-Fic 'github-main' "repo:$GitHubOwner/${GitHubRepo}:ref:refs/heads/$Branch"

# GitHub now presents an IMMUTABLE subject with numeric owner/repo ids. Look
# them up from the public API and register a matching credential.
try {
  $ownerId = (Invoke-RestMethod -Uri "https://api.github.com/users/$GitHubOwner" -Headers @{'User-Agent'='bootstrap'}).id
  $repoId  = (Invoke-RestMethod -Uri "https://api.github.com/repos/$GitHubOwner/$GitHubRepo" -Headers @{'User-Agent'='bootstrap'}).id
  Ensure-Fic 'github-main-immutable' "repo:$GitHubOwner@$ownerId/$GitHubRepo@${repoId}:ref:refs/heads/$Branch"
} catch { Write-Warning "Could not resolve immutable GitHub ids ($($_.Exception.Message)). Classic FIC only." }

Say "RBAC for the SPN"
$subScope = "/subscriptions/$SubscriptionId"
foreach ($role in @('Contributor','User Access Administrator','Key Vault Administrator')) {
  az role assignment create --assignee $spObjId --role $role --scope $subScope --only-show-errors -o none 2>$null
  Ok "sub scope: $role"
}
$saId = az storage account show -n $StateStorageAccount -g $StateResourceGroup --query id -o tsv
az role assignment create --assignee $spObjId --role 'Storage Blob Data Contributor' --scope $saId --only-show-errors -o none 2>$null
Ok "state SA: Storage Blob Data Contributor"

# ---------------------------------------------------------------------------
# 4. Hub network: VNet, subnets, DNS resolver, Private DNS zones + links
# ---------------------------------------------------------------------------
Say "Hub network"
az extension add --name dns-resolver --only-show-errors 2>&1 | Out-Null
az group create -n $netRg -l $Location --only-show-errors -o none
az network vnet create -g $netRg -n $vnetName -l $Location --address-prefixes $VnetCidr `
  --only-show-errors -o none
az network vnet subnet create -g $netRg --vnet-name $vnetName -n $inSubnet `
  --address-prefixes $InboundDnsSubnetCidr `
  --delegations Microsoft.Network/dnsResolvers --only-show-errors -o none
az network vnet subnet create -g $netRg --vnet-name $vnetName -n $peSubnet `
  --address-prefixes $PeSubnetCidr --only-show-errors -o none
$vnetId = az network vnet show -g $netRg -n $vnetName --query id -o tsv

Say "Private DNS Resolver (inbound $ResolverInboundIp)"
$resExists = az dns-resolver show -g $netRg -n $resolver --query id -o tsv 2>$null
if (-not $resExists) {
  az dns-resolver create -g $netRg -n $resolver -l $Location --id $vnetId --only-show-errors -o none
}
$inExists = az dns-resolver inbound-endpoint show -g $netRg --dns-resolver-name $resolver -n $inEndpoint --query id -o tsv 2>$null
if (-not $inExists) {
  $inSubnetId = az network vnet subnet show -g $netRg --vnet-name $vnetName -n $inSubnet --query id -o tsv
  az dns-resolver inbound-endpoint create -g $netRg --dns-resolver-name $resolver -n $inEndpoint -l $Location `
    --ip-configurations "[{private-ip-address:$ResolverInboundIp,private-ip-allocation-method:Static,id:$inSubnetId}]" `
    --only-show-errors -o none
}
Ok "Resolver inbound IP: $(az dns-resolver inbound-endpoint show -g $netRg --dns-resolver-name $resolver -n $inEndpoint --query 'ipConfigurations[0].privateIpAddress' -o tsv)"

Say "Private DNS zones + VNet links"
$zones = @(
  'privatelink.vaultcore.azure.net','privatelink.database.windows.net',
  'privatelink.blob.core.windows.net','privatelink.dfs.core.windows.net',
  'privatelink.queue.core.windows.net','privatelink.file.core.windows.net',
  'privatelink.table.core.windows.net','privatelink.datafactory.azure.net',
  'privatelink.adf.azure.com',"privatelink.$RegionCode.backup.windowsazure.com",
  'privatelink.cognitiveservices.azure.com','privatelink.openai.azure.com',
  'privatelink.services.ai.azure.com','privatelink.azurecr.io',
  'privatelink.documents.azure.com','privatelink.search.windows.net',
  'privatelink.redis.azure.net','privatelink.redis.cache.windows.net',
  'azure-api.net'
)
foreach ($z in $zones) {
  az network private-dns zone create -g $netRg -n $z --only-show-errors -o none 2>$null
  az network private-dns link vnet create -g $netRg -z $z -n "link-$vnetName" `
    --virtual-network $vnetId --registration-enabled false --only-show-errors -o none 2>$null
}
Ok "$($zones.Count) private DNS zones present + linked to $vnetName"

# ---------------------------------------------------------------------------
# 5. Management: Log Analytics Workspace
# ---------------------------------------------------------------------------
Say "Management (Log Analytics)"
az group create -n $mgmtRg -l $Location --only-show-errors -o none
az monitor log-analytics workspace create -g $mgmtRg -n $law -l $Location --only-show-errors -o none 2>$null | Out-Null
Ok "LAW: $law"

# ---------------------------------------------------------------------------
# 6. (optional) Runner VM
# ---------------------------------------------------------------------------
if ($CreateRunnerVm) {
  Say "Runner VM $runnerVm (deps via cloud-init; register the runner manually after)"
  $ci = Join-Path $PSScriptRoot 'runner-cloud-init.yaml'
  az vm create -g $netRg -n $runnerVm --image Ubuntu2204 --size $RunnerVmSize `
    --admin-username $RunnerAdminUser --generate-ssh-keys --vnet-name $vnetName --subnet $peSubnet `
    --public-ip-sku Standard --nsg-rule SSH --custom-data "@$ci" --only-show-errors `
    --query "{name:name, privateIp:privateIps, publicIp:publicIps}" -o json
} else {
  Ok "Skipping runner VM (kept across teardowns; use -CreateRunnerVm to build one)."
}

# ---------------------------------------------------------------------------
# Summary: values to put into GitHub Secrets / Variables
# ---------------------------------------------------------------------------
Say "DONE. GitHub configuration values:"
Write-Host ""
Write-Host "  Secrets:" -ForegroundColor Yellow
Write-Host "    AZURE_CLIENT_ID          = $appId"
Write-Host "    AZURE_TENANT_ID          = $tenantId"
Write-Host "    TFSTATE_SUBSCRIPTION_ID  = $SubscriptionId"
Write-Host "    GH_TOKEN                 = <a classic PAT with 'repo' scope>"
Write-Host ""
Write-Host "  Variables:" -ForegroundColor Yellow
Write-Host "    WORKLOAD_SUBSCRIPTION_ID = $SubscriptionId"
Write-Host "    TFSTATE_STORAGE_ACCOUNT  = $StateStorageAccount"
Write-Host "    TFSTATE_CONTAINER        = $StateContainer"
Write-Host "    TFSTATE_RESOURCE_GROUP   = $StateResourceGroup"
Write-Host "    DNS_RESOLVER_IP          = $ResolverInboundIp"
Write-Host "    BASTION_CIDR             = <a /26 inside $VnetCidr, e.g. 10.247.130.128/26>"
Write-Host "    SQL_ADMIN_UPN / FABRIC_ADMIN_UPN  = <your user UPN>"
Write-Host "    SQL_ADMIN_OBJECT_ID      = <your user object id>"
