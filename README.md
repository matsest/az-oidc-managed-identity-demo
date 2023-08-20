# GitHub Actions with federated credentials to user-assigned managed identity

Demo project to showcase the ability to use user-assigned managed identites and federated credentials instead of service principals with secrets for authentication for GitHub Actions. See the [learn more section](#learn-more) for more details about the background.

## Motivation

- Use managed identities instead of service principals in GitHub Actions? ❓
- Managed identities can't have secrets as credentials 🔒
- Managed identities can be created declaratively with Bicep / via resource manager API 😎
  - No Azure AD-setup required
  - Follows the lifecycle of resource created in a subscription
- Federated credentials allows for more granular restrictions on the identity's use (e.g. specific repos, branches and environments) ✅
- Avoid issues with short-lived tokens for federated credentials on service principals (1hr vs 24hrs when using managed identities, for long running jobs) 🕥

## Prerequisites

- [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- [Azure PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps) (9.0+)
- [Azure Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) (install with `az bicep install` or upgrade with `az bicep upgrade`) (0.12+)
- An Azure subscription with Owner permissions

## Steps

1. [Fork this repo](https://github.com/matsest/az-oidc-managed-identity-demo/fork)

2. Clone your repository locally and open a terminal running PowerShell in it

3. Run the deployment locally:

```powershell
Connect-AzAccount

$ghUserName = '<your github user name>'

New-AzSubscriptionDeployment -Name "demo-mi-gh" -Location norwayeast `
    -TemplateFile ./bicep/main.bicep -ghUserName $ghUserName
```

This will deploy the [main.bicep](./bicep/main.bicep) that contains a resource group with a managed identity with a federated credential and a role assignment. Make note of the output values for subscription id, client id and tenant id.

4. Add these values as secrets to your GitHub repository with the secret names `SUBSCRIPTION_ID`, `CLIENT_ID`, `TENANT_ID`.

> If you have GitHub CLI installed you can do this with
>
> ```bash
> gh secret set SUBSCRIPTION_ID --body "<sub id>" --env Azure
> gh secret set CLIENT_ID --body "<client id>" --env Azure
> gh secret set TENANT_ID --body "<tenant id>" --env Azure
> ```

5. Trigger the GitHub Actions workflow by navigating to **Actions** and choosing the "Run Azure Login" workflow. View the details of the 'demo' job in the workflow and inspect the steps.

This will demonstrate that the workflow is able to login with the managed identity using federated credentials and it will list the resource groups it has access to! ✅

![workflow](./.github/workflow.png)

## Summary

1. You have deployed a managed identity and federated credentials declaratively using Bicep - without any Azure AD or Graph-related tasks.
1. You've authenticated from GitHub to Azure in a GitHub Actions workflow using a managed identity to do this instead of a service principal - which means no secrets to manage or rotate!
1. You are logging in using a federated credential for the managed identity _specifically scoped_ to your GitHub repository (and environment) to authenticate. This means there's no method this credential can be used to login from other sources.
1. The managed identity is authorized in Azure to a specific scope (Contributor on the resource group in this case). This is default behaviour for identities in Azure.

## Cleanup

Delete the resource group including the managed identity and its credentials by running:

```powershell
Remove-AzResourceGroup -Name "demo-mi-gh-rg"
```

## Considerations

For a non-demo setup of this you should consider:

- There's no need for permissions in Azure AD to set this up. Azure AD is permission-wise a separate plane from the resource manager (RM) plane. With service principals you would need permissions in both Azure AD and Azure RM to configure an identity and a role assignment. In this scenario you only need access to Azure RM.
    - Note: you can add an [Azure Policy to block creation of federated credentials](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-block-using-azure-policy) if your security baseline requires it.
- In this demo, the user-assigned managed identity has a role assigned to the resource group it is located in. This means that it also has access to alter its own federated credentials. This is just for demo purposes and can be avoided in a real-life scenario if needed.

In summary, use Azure RBAC to give proper access to your user-assigned managed identities, and audit the usage of federated credentials to make sure only allowed external providers are added. Consider using Azure Policy to deny specific configurations.

## Learn more

- [Workload Identity Federation](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation)
- [Configure a user-assigned managed identity to trust an external identity provider ](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-create-trust-user-assigned-managed-identity)
- [Manage user-assigned managed identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-powershell)
- [Azure/login Actions doc for OIDC](https://github.com/Azure/login#github-action-for-azure-login)

This repository (other branches than main) has also been used to debug an known error with client assertion timeouts for federated credentials for _service principals_. See more info in [Azure/login/issues/180](https://github.com/Azure/login/issues/180)