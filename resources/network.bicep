metadata description = 'Creates the network resouces for the explorer project'

@description('Project environment')
@allowed([
	'dev'
	'prod'
	'sbx'
])
param env string

@description('Project location')
@allowed([
	'westeurope'
])
param location string

@description('Project subnet count of each type (1 means 2 subnets: 1 public and 1 private)')
@minValue(1)
@maxValue(2)
param subnetCount int = 1

var locationLabel = take(location, 6)

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
	name: 'vnet-explorer-${env}-${locationLabel}-001'
	location: location
	properties: {
		addressSpace: {
			addressPrefixes: [
				'10.0.0.0/16'
			]
		}
	}
}

resource publicSubnets 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = [for subnet in range(0, subnetCount) : {
	name: 'snet-explorer-${env}-${locationLabel}-public-00${subnet+1}'
	parent: vnet
	properties: {
		addressPrefix: cidrSubnet(vnet.properties.addressSpace.addressPrefixes[0], 24, subnet)
		networkSecurityGroup: {
			id: publicNSG.id
		}
	}
}]

resource privateSubnets 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = [for subnet in range(0, subnetCount) : {
	name: 'snet-explorer-${env}-${locationLabel}-private-00${subnet+1}'
	parent: vnet
	properties: {
		addressPrefix: cidrSubnet(vnet.properties.addressSpace.addressPrefixes[0], 24, subnet+2)
		defaultOutboundAccess: false
		networkSecurityGroup: {
			id: privateNSG.id
		}
		natGateway: {
			id: natGateway.id
		}
	}
}]

resource publicNSG 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
	name: 'nsg-explorer-${env}-${locationLabel}-public-001'
	location: location
	properties: {
		securityRules: []
	}
}

resource privateNSG 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
	name: 'nsg-explorer-${env}-${locationLabel}-private-001'
	location: location
	properties: {
		securityRules: []
	}
}
resource natGateway 'Microsoft.Network/natGateways@2025-05-01' = {
	name: 'ng-explorer-${env}-${locationLabel}-001'
	location: location
	properties: {
		publicIpAddresses: [
			{
				id: natPublicIp.id 
			}
		]
	}
	sku: {
		name: 'StandardV2'
	}
}

resource natPublicIp 'Microsoft.Network/publicIPAddresses@2025-05-01' = {
	name: 'pip-explorer-${env}-${locationLabel}-nat-001'
	location: location
	properties: {
		publicIPAddressVersion: 'IPv4'
		publicIPAllocationMethod: 'Static'
	}
	sku: {
		name: 'StandardV2'
		tier: 'Regional'
	}
}
