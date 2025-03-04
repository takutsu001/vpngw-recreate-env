/*
------------------
param section
------------------
*/

// Common
param location string
param existingOnpreVNetName string 
param existingOnpreVNetAddress string
// for VPN Gateway
param onpreVPNGWName string
param onpreLngName string

/*
------------------
resource section
------------------
*/

resource existingOnpreVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: existingOnpreVNetName
}

// 既存のGatewaySubnetを参照
resource existingOnpreGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: existingOnpreVnet
  name: 'GatewaySubnet'
}

// create public ip address for VPN Gateway
resource onpreVPNGWpip 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: '${onpreVPNGWName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// create VPN Gateway for Onpre (RouteBased)
resource onpreVPNGW 'Microsoft.Network/virtualNetworkGateways@2023-06-01' = {
  name: onpreVPNGWName
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: '${onpreVPNGWName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: onpreVPNGWpip.id
          }
          subnet: {
            id: existingOnpreGatewaySubnet.id
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
resource onpreLng 'Microsoft.Network/localNetworkGateways@2023-06-01' = {
  name: onpreLngName
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: ['${existingOnpreVNetAddress}']
    }
    gatewayIpAddress: onpreVPNGWpip.properties.ipAddress
  }
}


/*
------------------
output section
------------------
*/

// return the vpn gateway ID and LNG ID to use from parent template
output onpreVPNGWId string = onpreVPNGW.id
output onpreLngId string = onpreLng.id
