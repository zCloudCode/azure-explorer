metadata description = 'Creates the network resouces for the explorer project'

@description('Project environment')
@allowed([
	'dev'
	'prod'
	'sbx'
])
param env string

@description('Project location')
param location string

@description('Project subnet count of each type (1 means 2 subnets: 1 public and 1 private)')
@minValue(1)
@maxValue(2)
param subnetCount int = 1

var locationLabel = take(location, 6)
var vnetCIDR = '10.0.0.0/16'
var vnetName = 'vnet-explorer-${env}-${locationLabel}-001'
var snetNamePrefix = 'snet-explorer-${env}-${locationLabel}'

var publicSubnets = [
	for snet in range(0, subnetCount) : {
		name: '${snetNamePrefix}-public-00${snet+1}'
		properties: {
			addressPrefix: cidrSubnet(vnetCIDR, 24, snet) 
			networkSecurityGroup: {
				id: publicNSG.id
			}
		}
	}
]

var privateSubnets = [
	for snet in range(0, subnetCount): {
		name: '${snetNamePrefix}-private-00${snet+1}'
		properties: {
			addressPrefix: cidrSubnet(vnetCIDR, 24, snet+subnetCount)
			networkSecurityGroup: {
				id: privateNSG.id
			}
      natGateway: {
        id: natGateway.id
      }
      defaultOutboundAccess: false
		}
	}
]

var bastionSubnet = {
	name: 'AzureBastionSubnet'
	properties: {
		addressPrefix: cidrSubnet(vnetCIDR, 24, 2*subnetCount+1)
		privateEndpointNetworkPolicies: 'Disabled'
		privateLinkServiceNetworkPolicies: 'Disabled'
	}
}

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
	name: vnetName
	location: location
	properties: {
		addressSpace: {
			addressPrefixes: [
				vnetCIDR
			]
		}
		subnets: union(publicSubnets, privateSubnets, [bastionSubnet])
	}
}

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
		securityRules: [
      {
        name: 'AllowInboundHTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
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

output privateNSGId string = privateNSG.id
output privateSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, '${snetNamePrefix}-private-001')
output publicSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, '${snetNamePrefix}-public-001')
output bastionSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')

