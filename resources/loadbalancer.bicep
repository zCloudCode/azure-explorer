@description('Project environment')
@allowed([
	'dev'
	'prod'
	'sbx'
])
param env string = 'dev'

@description('Project location')
param location string

var locationLabel string = take(location, 6)
var lbName string = 'lbe-explorer-${env}-${locationLabel}-001'
var frontendName string = 'fic-explorer-${env}-${locationLabel}-001'
var backendName string = 'bep-explorer-${env}-${locationLabel}-001'
var probeName string = 'hp-explorer-${env}-${locationLabel}-001'

resource lbPublicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
	name: 'pip-explorer-${env}-${locationLabel}-lbe-001'
	location: location
	properties: {
		publicIPAddressVersion: 'IPv4'
		publicIPAllocationMethod: 'Static'
	}
	sku: {
		name: 'Standard'
		tier: 'Regional'
	}
}

resource lbe 'Microsoft.Network/loadBalancers@2025-05-01' = {
	name: lbName 
	location: location
	properties: {
		backendAddressPools: [
			{
				name: backendName
			}
		]
		frontendIPConfigurations: [
			{
				name: frontendName
				properties: {
					publicIPAddress: {
						id: lbPublicIp.id
					}
				}
			}
		]
		loadBalancingRules: [
			{
				name: 'lbr-explorer-${env}-${locationLabel}-001'
				properties: {
					backendPort: 80
					frontendPort: 80
					enableFloatingIP: false
					disableOutboundSnat: true
					loadDistribution: 'Default'
					enableTcpReset: true
					protocol: 'Tcp'
					backendAddressPool: {
						id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, backendName)
					}
					frontendIPConfiguration: {
						id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, frontendName)
					}
					probe: {
						id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, probeName)
					}
				}
			}
		]
		probes: [
			{
				name: probeName
				properties: {
					intervalInSeconds: 15
					noHealthyBackendsBehavior: 'AllProbedUp'
					port: 80
					probeThreshold: 2
					protocol: 'Http'
					requestPath: '/'
				}
			}
		]
	}
	sku: {
		name: 'Standard'
		tier: 'Regional'
	}
}

output lbBackendPoolId string = lbe.properties.backendAddressPools[0].id
