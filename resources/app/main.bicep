@description('Project environment')
@allowed([
  'dev'
  'prod'
  'sbx'
])
param env string

@description('Project location')
param location string

@description('App Service Plan SKU')
@allowed([
  'Basic'
  'Standard'
])
param appServicePlanSKU string

@description('Code repo URL')
param repoUrl string

var servicePlanSKUs object = {
  Basic: 'B1'
  Standard: 'S1'
}
var locationLabel = take(location, 6)

resource serverFarm 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: 'asp-explorer-${env}-${locationLabel}-001'
  location: location
  properties: {
    reserved: true 
    zoneRedundant: false
  }
  kind: 'app,linux'
  sku: {
    name: servicePlanSKUs[appServicePlanSKU]
  }
}

resource site 'Microsoft.Web/sites@2025-03-01' = {
  name: 'app-explorer-${env}-${locationLabel}-001'
  location: location
  properties: {
    enabled: true
    httpsOnly: true
    serverFarmId: serverFarm.id
  }
  kind: 'app,linux'
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2025-03-01' = {
  name: 'web'
  parent: site
  properties: {
    repoUrl: repoUrl
    isGitHubAction: true
    gitHubActionConfiguration: {
      isLinux: true
      codeConfiguration: {
        runtimeStack: 'Python'
        runtimeVersion: '3.14'
      }
    }
  }
}
