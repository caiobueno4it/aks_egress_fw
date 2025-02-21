output "snet_fw_id" {
  value = azurerm_subnet.snet_fw.id
}

output "snet_aks_id" {
  value = azurerm_subnet.snet_aks.id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "pip_my" {
  value = data.http.pip_my.response_body
}

output "pip_fw_id" {
  value = azurerm_public_ip.pip_fw.id
}
output "pip_fw_address" {
  value = azurerm_public_ip.pip_fw.ip_address
}