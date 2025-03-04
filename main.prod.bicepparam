using 'main.bicep'

param resourceGroupName = 'Nikko-RG'
param resourceGroupLocation = 'japaneast'

// ---- param for Hub ----
param existingHubVNetName = 'Ni-Hub-VNet'
param existingHubVNetAddress = '10.0.0.0/16'
// for VPN Gateway
param hubVPNGWName = 'Ni-azure-vpngw'
param hubLngName = 'Ni-Azure-LNG'

// ---- param for Onpre ----
param existingOnpreVNetName = 'Ni-Onpre-VNet' 
param existingOnpreVNetAddress = '172.16.0.0/16'
param onpreVPNGWName = 'Ni-onpre-vpngw'
param onpreLngName = 'Ni-Onpre-LNG'

// ---- Common param for VPNGW ----
param connectionsharedkey = 'msjapan1!msjapan1!'
