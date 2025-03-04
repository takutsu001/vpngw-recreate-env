targetScope = 'subscription'

/*
------------------
param section
------------------
*/

// ---- param for Common ----
param resourceGroupName string
param resourceGroupLocation string

// ---- param for Hub ----
param existingHubVNetName string
param existingHubVNetAddress string

// ---- param for Onpre ----
param existingOnpreVNetName string
param existingOnpreVNetAddress string

// ---- param for VPN Gateway ----
// Azure VPN Gateway
param hubVPNGWName string
param hubLngName string
// Onpre VPN Gateway
param onpreVPNGWName string
param onpreLngName string
// VPN Connection shared key (PSK)
@secure()
param connectionsharedkey string

/*
------------------
resource section
------------------
*/

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = { 
  name: resourceGroupName 
  location: resourceGroupLocation 
} 

/*
---------------
module section
---------------
*/

// Create Hub Environment (VM-Linux VNet, Subnet, NSG, VNet Peering, VPN Gateway, Local Network Gateway)
module HubModule './modules/hubEnv.bicep' = { 
  scope: newRG 
  name: 'CreateHubEnv' 
  params: { 
    location: resourceGroupLocation
    existingHubVNetName: existingHubVNetName
    existingHubVNetAddress: existingHubVNetAddress
    hubVPNGWName: hubVPNGWName
    hubLngName: hubLngName
  } 
}

// Create Onpre Environment (VM-Linux VNet, Subnet, NSG, Vnet Peering, VPN Gateway, Local Network Gateway)
module OnpreModule './modules/onpreEnv.bicep' = { 
  scope: newRG 
  name: 'CreateOnpreEnv' 
  params: { 
    location: resourceGroupLocation
    existingOnpreVNetName: existingOnpreVNetName
    existingOnpreVNetAddress: existingOnpreVNetAddress
    onpreVPNGWName: onpreVPNGWName
    onpreLngName: onpreLngName
  } 
}

// Create Connection for Onpre VPN Gateway and Azure VPN Gateway
module VPNConnectionModule './modules/vpnConnection.bicep' = { 
  scope: newRG 
  name: 'CreateVPNConnection' 
  params: { 
    location: resourceGroupLocation
    hubVPNGWID: HubModule.outputs.hubVPNGWId
    hubLngID: HubModule.outputs.hubLngId
    onpreVPNGWID: OnpreModule.outputs.onpreVPNGWId
    onpreLngID: OnpreModule.outputs.onpreLngId
    connectionsharedkey: connectionsharedkey
  } 
  dependsOn: [
    HubModule
    OnpreModule
  ]
}
