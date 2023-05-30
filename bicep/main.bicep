targetScope = 'subscription'

param baseName string = 'demo-mi-gh'
param location string = 'eastus'

param ghUserName string
param ghRepoName string = 'az-oidc-managed-identity-demo'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
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
  }
}

output clientId string = managedIdentity.outputs.clientId
output tenantId string = subscription().tenantId
output subscriptionId string = subscription().subscriptionId
