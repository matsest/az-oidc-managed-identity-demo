targetScope = 'subscription'

@description('The baseName used for resource group and managed dentity names.')
param baseName string = 'demo-mi-gh'
@description('The location used for resource group and managed identity.')
param location string = 'norwayeast'

@description('The Role definition ID used to assign to the Managed Identity. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles for values. The default is the Contributor role.')
param roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('The GitHub username that holds the repository the Managed Identity will be used with.')
param ghUserName string
@description('The GitHub repository name the Managed Identity will be used with.')
param ghRepoName string = 'az-oidc-managed-identity-demo'
@description('The GitHub environment name the Managed Identity will be used with.')
param ghEnvName string = 'Azure'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${baseName}-rg'
  location: location
}

module managedIdentity 'managedIdentity.bicep' = {
  scope: rg
  name: 'managedIdentity-demo'
  params: {
    name: '${baseName}-uaid'
    location: location
    ghUserName: ghUserName
    ghRepoName: ghRepoName
    ghEnvName: ghEnvName
    roleDefinitionId: roleDefinitionId
  }
}

output clientId string = managedIdentity.outputs.clientId
output tenantId string = subscription().tenantId
output subscriptionId string = subscription().subscriptionId
