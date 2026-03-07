@description('Project environment')
@allowed([
	'dev'
	'prod'
	'sbx'
])
param env string = 'dev'

@description('Project location')
param location string

@description('Bastion Subnet Id')
param bastionSubnetId string

var locationLabel string = take(location, 6)

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
	name: 'pip-explorer-${env}-${locationLabel}-bastion-001'
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

resource bastion 'Microsoft.Network/bastionHosts@2025-05-01' = {
	name: 'bas-explorer-${env}-${locationLabel}-001'
	location: location
	properties: {
		ipConfigurations: [
			{
				name: 'ipc-explorer-${env}-${locationLabel}-bastion-001'
				properties: {
					publicIPAddress: {
						id: bastionPublicIp.id
					}
					subnet: {
						id: bastionSubnetId
					}
				}
			}
		]
	}
	sku: {
		name: 'Basic'
	}
}
