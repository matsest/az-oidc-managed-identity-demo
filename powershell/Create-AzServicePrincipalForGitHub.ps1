#requires -Modules Az.Resources

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $AppName = 'demo-oidc-app-gh',

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

#* Create service principal
Write-Host "Creating service principal..."
$sp = New-AzADServicePrincipal -DisplayName $AppName
$app = Get-AzADApplication -ApplicationId $sp.AppId

#* Create credentials for user assigned managed identity
Write-Host "Creating federated credential for repo:env ${GhRepoName}:${GhEnvName} for service principal..."
$null = New-AzAdAppFederatedCredential -ApplicationObjectId $app.Id  -Audience api://AzureADTokenExchange `
    -Name "${GhRepoName}${GhEnvName}" -Issuer "https://token.actions.githubusercontent.com" -Subject "repo:${GhUserName}/${GhRepoName}:environment:${GhEnvName}"

#* Output subscription id, client id and tenant id
$out = [ordered]@{
    SUBSCRIPTION_ID = $(Get-AzContext).Subscription.Id
    CLIENT_ID = $sp.AppId
    TENANT_ID = $(Get-AzContext).Subscription.TenantId
}
Write-Host ($out | ConvertTo-Json | Out-String)