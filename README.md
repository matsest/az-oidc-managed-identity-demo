# GitHub Actions with federated credentials to user-assigned managed identity

Demo project to test the viability of using user-assigned managed identites instead of service principals for authentication for GitHub Actions.

## Motivation

- Managed identities can't have secrets as credentials 🔒
- Managed identities can be created declaratively with Bicep / via resource manager API 😎
- Federated credentials allows for more granular restrictions on the identity's use (e.g. specific branches or environments) ✅
- Avoid issues with short-lived tokens for federated credentials on service principals (for long running jobs) 🕥

## Steps

1. Fork this repo

2. Run this deployment locally:

```powershell
Connect-AzAccount

$ghUserName = '<your github user name>'

New-AzSubscriptionDeployment -Name "demo-mi-gh" -Location norwayeast `
    -TemplateFile ./bicep/main.bicep -ghUserName $ghUserName
```

This will deploy the [main.bicep](./bicep/main.bicep) that contains a resource group with a managed identity with a federated credential and a role assignment. Make note of the output values for subscription id, client id and tenant id.

3. Add these values as secrets to your GitHub repository with the secret names `SUBSCRIPTION_ID`, `CLIENT_ID`, `TENANT_ID`.

4. Trigger workflow by navigating to Actions and choosing the "Run Azure Login" workflow

## Cleanup

Delete the resource group including the managed identity and its credentials by running:

```powershell
Remove-AzResourceGroup -Name "demo-mi-gh-rg"
```

## Learn more

- [Workload Identity Federation](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)
- [Configure a user-assigned managed identity to trust an external identity provider ](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-create-trust-user-assigned-managed-identity?pivots=identity-wif-mi-methods-azp)
- [Manage user-assigned managed identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-powershell
