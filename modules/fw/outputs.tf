output "fw_name" {
  value = azurerm_firewall.fw.name
}

output "fw_ip_address" {
  value = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

