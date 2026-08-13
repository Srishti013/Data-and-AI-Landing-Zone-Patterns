#requires -Version 5.1
<#
.SYNOPSIS
  Tears down the DEPLOYED Data/AI landing-zone workload, while keeping the
  prerequisites (state backend, hub network + runner VM, management LAW, OIDC
  SPN) intact so you can redeploy without re-bootstrapping.

  Deletes every resource group in the subscription that matches the workload
  naming pattern EXCEPT the protected prerequisite groups. Then purges any
  soft-deleted Key Vaults (so names free up) and, optionally, clears the
  Terraform state blobs.

.NOTES
  Dry-run by default: prints what WOULD be deleted. Add -Force to actually delete.
  The runner VM lives in the network RG, which is PROTECTED - it is never deleted.
  Pause the runner separately by deallocating the VM (see README note).

.EXAMPLE
  ./teardown-workload.ps1 -SubscriptionId 05a4028e-... -WhatIfList
  ./teardown-workload.ps1 -SubscriptionId 05a4028e-... -Force -ClearState
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$SubscriptionId,
  [string]$Org        = 'test',
  [string]$Env        = 'pd',
  [string]$RegionCode = 'sea',

  # Prerequisite groups that must survive teardown.
  [string]$StateResourceGroup = 'rg-tfstate-lzdemo',
  [string]$StateStorageAccount= '',
  [string]$StateContainer     = 'tfstate',

  [switch]$Force,        # actually delete (otherwise dry-run)
  [switch]$ClearState,   # also delete tfstate blobs
  [switch]$NoWaitDelete  # don't block on RG deletion
)

$ErrorActionPreference = 'Stop'
function Say($m){ Write-Host "==> $m" -ForegroundColor Cyan }

az account set --subscription $SubscriptionId | Out-Null

$netRg  = "$Org-rg-private-network-$Env-$RegionCode-01"   # holds the runner - PROTECTED
$mgmtRg = "$Org-rg-mgmt-$Env-$RegionCode-01"              # LAW - PROTECTED
$protected = @($netRg, $mgmtRg, $StateResourceGroup)

# Workload RGs = anything named like a demo RG that is NOT protected.
$pattern = "^$Org-rg-.*-$Env-$RegionCode-\d+$"
$all = az group list --query "[].name" -o tsv
$targets = $all | Where-Object { $_ -match $pattern -and $protected -notcontains $_ }

Say "Protected (kept): $($protected -join ', ')"
if (-not $targets) { Write-Host "No workload resource groups match. Nothing to delete." -ForegroundColor Green }
else {
  Write-Host ""
  Write-Host "Workload resource groups to DELETE:" -ForegroundColor Yellow
  $targets | ForEach-Object { Write-Host "    $_" }
}

if (-not $Force) {
  Write-Host ""
  Write-Host "DRY-RUN. Re-run with -Force to delete the groups above." -ForegroundColor Magenta
} else {
  foreach ($rg in $targets) {
    Say "Deleting resource group $rg"
    if ($NoWaitDelete) { az group delete -n $rg --yes --no-wait --only-show-errors }
    else               { az group delete -n $rg --yes --only-show-errors }
  }

  # Purge soft-deleted Key Vaults so their names can be reused on redeploy.
  Say "Purging soft-deleted Key Vaults"
  $deleted = az keyvault list-deleted --query "[].name" -o tsv 2>$null
  foreach ($kv in $deleted) {
    if ($kv -like "$Org-*" -or $kv -like "*-$Env-$RegionCode-*") {
      az keyvault purge -n $kv --only-show-errors 2>$null
      Write-Host "    purged $kv"
    }
  }

  if ($ClearState) {
    Say "Clearing Terraform state blobs in $StateContainer"
    if (-not $StateStorageAccount) {
      $StateStorageAccount = az storage account list -g $StateResourceGroup --query "[0].name" -o tsv
    }
    $blobs = az storage blob list --account-name $StateStorageAccount --container-name $StateContainer `
               --auth-mode login --query "[].name" -o tsv 2>$null
    foreach ($b in $blobs) {
      az storage blob delete --account-name $StateStorageAccount --container-name $StateContainer `
        --name $b --auth-mode login --only-show-errors 2>$null
      Write-Host "    deleted state blob $b"
    }
  }
  Say "Teardown complete. Prerequisites and runner preserved."
}
