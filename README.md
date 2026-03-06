# Azure Explorer

## Introduction

This projects creates Azure resources to explore how they work, these include the following:

- network
- compute
- storage
- security
- ...

## Deployment

### 0. Prerequisites

This deployment has the following requirements:

- Azure account with active subscription
- Azure CLI installed and authenticated

### 1. Create a resource group

```bash
cd resourceGroup
bash deploy.sh
```

### 2. Create resources

```bash
cd resources
bash deploy.sh
```

## Clean Up

This project uses Azure Bicep to deploy all the resources in the resource group `rg-explorer-dev-westeu-001`.
To clean up, delete this resource group.
