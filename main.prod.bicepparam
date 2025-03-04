using 'main.bicep'

param resourceGroupName = 'VPNGW-RG'
param resourceGroupLocation = 'japaneast'

// ---- param for Hub ----
param existingHubVNetName = 'Hub-VNet'
param existingHubVNetAddress = '10.0.0.0/16'
// for VPN Gateway
param hubVPNGWName = 'azure-vpngw'
param hubLngName = 'Azure-LNG'

// ---- param for Onpre ----
param existingOnpreVNetName = 'Onpre-VNet' 
param existingOnpreVNetAddress = '172.16.0.0/16'
param onpreVPNGWName = 'onpre-vpngw'
param onpreLngName = 'Onpre-LNG'

// ---- Common param for VPNGW ----
param connectionsharedkey = 'msjapan1!msjapan1!'
