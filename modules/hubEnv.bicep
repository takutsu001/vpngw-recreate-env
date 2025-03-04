/*
------------------
param section
------------------
*/

// Common
param location string
param existingHubVNetName string 
param existingHubVNetAddress string
// for VPN Gateway
param hubVPNGWName string
param hubLngName string

/*
------------------
resource section
------------------
*/

resource existingHubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: existingHubVNetName
}

// 既存のGatewaySubnetを参照
resource existingHubGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: existingHubVnet
  name: 'GatewaySubnet'
}

// create public ip address for VPN Gateway
resource hubVPNGWpip 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: '${hubVPNGWName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// create VPN Gateway for hub (RouteBased)
resource hubVPNGW 'Microsoft.Network/virtualNetworkGateways@2023-06-01' = {
  name: hubVPNGWName
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: '${hubVPNGWName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: hubVPNGWpip.id
          }
          subnet: {
            id: existingHubGatewaySubnet.id
          }
        }
      }
    ]
    natRules: []
    virtualNetworkGatewayPolicyGroups: []
    enableBgpRouteTranslationForNat: false
    disableIPSecReplayProtection: false
    sku: {
      name: 'vpngw1'
      tier: 'vpngw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnGatewayGeneration: 'Generation1'
    allowRemoteVnetTraffic: false
    allowVirtualWanTraffic: false
  }
}

// create local network gateway for azure vpn connection
// 環境によっては、localNetworkAddressSpaceのaddressPrefixesを変更する必要がある
resource hubLng 'Microsoft.Network/localNetworkGateways@2023-06-01' = {
  name: hubLngName
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: ['${existingHubVNetAddress}']
    }
    gatewayIpAddress: hubVPNGWpip.properties.ipAddress
  }
}

/*
------------------
output section
------------------
*/

// return the vpn gateway ID and LNG ID to use from parent template
output hubVPNGWId string = hubVPNGW.id
output hubLngId string = hubLng.id
