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
    clientAffinityEnabled: false
  }
  kind: 'app,linux'
}

resource config 'Microsoft.Web/sites/config@2025-03-01' = {
	name: 'web'
	parent: site
	properties: {
		alwaysOn: false
		numberOfWorkers: 1
		linuxFxVersion: 'PYTHON|3.14'
		scmType: 'GitHubAction'
	}
}

