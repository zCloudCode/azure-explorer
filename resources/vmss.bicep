@description('Project environment')
@allowed([
	'dev'
	'prod'
	'sbx'
])
param env string = 'dev'

@description('Project location')
param location string

@description('Virtual Machine count')
@minValue(1)
@maxValue(5)
param vmCount int

@description('Virtual Machine NSG Id')
param vmNSGId string

@description('Virual Machine Subnet Id')
param vmSubnetId string

@description('Public SSH key data')
param sshKeyData string

@description('Load Balancer Backend Pool Id')
param lbBackendPoolId string

var locationLabel = take(location, 6)
var vmUserData string = loadFileAsBase64('./cloud-init.yml')
var vmSize string = 'Standard_D2als_v7'
var vmImage object = {
	publisher: 'Canonical'
	offer: 'ubuntu-24_04-lts'
	version: 'latest'
	sku: 'server'
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2025-04-01' = {
	name: 'vmss-explorer-${env}-${locationLabel}-001'
	location: location
	properties: {
		orchestrationMode: 'Flexible'
		platformFaultDomainCount: 2
		virtualMachineProfile: {
			osProfile: {
				adminUsername: 'azureuser'
				computerNamePrefix: 'vm-explorer-${env}-${locationLabel}'
				customData: vmUserData
				linuxConfiguration: {
					disablePasswordAuthentication: true
					provisionVMAgent: true
					ssh: {
						publicKeys: [
							{
								keyData: sshKeyData
								path: '/home/azureuser/.ssh/authorized_keys'
							}
						]
					}
				}
			}
			networkProfile: {
				networkApiVersion: '2022-11-01'
				networkInterfaceConfigurations: [
					{
						name: 'nic-explorer-${env}-${locationLabel}-001'
						properties: {
							ipConfigurations: [
								{
									name: 'ipc-explorer-${env}-${locationLabel}-001'
									properties: {
										primary: true
										privateIPAddressVersion: 'IPv4'
										subnet: {
											id: vmSubnetId
										}
										loadBalancerBackendAddressPools: [
											{
												id: lbBackendPoolId
											}
										]
									}
								}
							]
							networkSecurityGroup: {
								id: vmNSGId
							}
						}
					}
				]
			}
			securityProfile: {
				securityType: 'TrustedLaunch'
			}
			storageProfile: {
				imageReference: vmImage
				osDisk: {
					osType: 'Linux'
					managedDisk: {
						storageAccountType: 'Premium_LRS'
					}
					diskSizeGB: 30
					createOption: 'FromImage'
					deleteOption: 'Delete'
				}
				diskControllerType: 'NVMe'
			}
		}
	}
	sku: {
		name: vmSize
		capacity: vmCount
		tier: 'Standard'
	}
}

