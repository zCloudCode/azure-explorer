targetScope = 'resourceGroup'

@description('Path to SSH public key data')
param sshKeyData string

var env = 'dev'
var location = resourceGroup().location

module network './network.bicep' = {
	name: 'networkDeploy'
	params: {
		env: env
		location: location
	}
}

module loadBalancer './loadbalancer.bicep' = {
	name: 'loadBalancerDeploy'
	params: {
		env: env
		location: location
	}
}

module vmss './vmss.bicep' = {
	name: 'vmDeploy'
	params: {
		env: env
		location: location
		vmCount: 2
		vmNSGId: network.outputs.privateNSGId
		vmSubnetId: network.outputs.privateSubnetId
		lbBackendPoolId: loadBalancer.outputs.lbBackendPoolId
		sshKeyData: sshKeyData
	}
}

module bastion './bastion.bicep' = {
	name: 'bastionDeploy'
	params: {
		env: env
		location: location
		bastionSubnetId: network.outputs.bastionSubnetId
	}
}

