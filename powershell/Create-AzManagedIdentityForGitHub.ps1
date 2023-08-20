#requires -Modules Az.ManagedServiceIdentity, Az.Resources

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ResourceGroupName = 'demo-mi-gh-rg',

    [Parameter()]
    [string]
    $Location = 'norwayeast',

    [Parameter()]
    [string]
    $IdentityName = 'demo-mi-gh-uaid',

    [Parameter(Mandatory)]
    [string]
    $GhUserName,

    [Parameter()]
    [string]
    $GhRepoName = 'az-oidc-managed-identity-demo',

    [Parameter()]
    [string]
    $GhEnvName = 'Azure'
)

$ErrorActionPreference = "Stop"

#* Create resource group
Write-Host "Creating resource group..."
$rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location

#* Create user assigned managed identity
Write-Host "Creating user-assigned managed identity..."
$identity = New-AzUserAssignedIdentity -ResourceGroupName $rg.ResourceGroupName -Name $IdentityName -Location $Location

#* Create role assignment for the managed identity
Write-Host "Creating role assignment..."
$null = New-AzRoleAssignment -PrincipalId $identity.PrincipalId -RoleDefinitionName "Contributor" -Scope $rg.ResourceId -ObjectType "ServicePrincipal"

#* Create credentials for user assigned managed identity
Write-Host "Creating federated credential for managed identity..."
$null = New-AzFederatedIdentityCredentials -ResourceGroupName $rg.ResourceGroupName -IdentityName $identity.Name `
    -Name $GhRepoName  -Issuer "https://token.actions.githubusercontent.com" -Subject "repo:${GhUserName}/${GhRepoName}:environment:${GhEnvName}"

#* Output subscription id, client id and tenant id
$out = [ordered]@{
    SUBSCRIPTION_ID = $(Get-AzContext).Subscription.Id
    CLIENT_ID = $identity.ClientId
    TENANT_ID = $identity.TenantId
}
Write-Host ($out | ConvertTo-Json | Out-String)