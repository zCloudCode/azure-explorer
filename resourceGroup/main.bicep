targetScope = 'subscription'

@description('Project environment')
@allowed([
	'dev'
	'prod'
	'sbx'
])
param env string = 'dev'

var location = deployment().location
var locationLabel = take(location, 6)

resource explorerRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
	name: 'rg-explorer-${env}-${locationLabel}-001'
	location: location
	tags: {
		environment: env
		project: 'explorer'
	}
}
