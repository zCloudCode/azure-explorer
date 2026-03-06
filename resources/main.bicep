targetScope = 'resourceGroup'

// var location = resourceGroup().location

module network './network.bicep' = {
	name: 'networkDeploy'
	params: {
		env: 'dev'
		location: 'westeurope'
	}
}
