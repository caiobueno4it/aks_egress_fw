resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  location            = var.location
  resource_group_name = var.rg
  address_space       = [var.vnet_address]
}

resource "azurerm_subnet" "snet_fw" {
  name                 = var.snet_fw
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_fw_address]

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet" "snet_aks" {
  name                 = var.snet_aks
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_aks_address]

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_public_ip" "pip_fw" {
  name                = var.pip_fw
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Obter o IP público do host que executa o Terraform
data "http" "pip_my" {
  url = "https://api.ipify.org?format=text"
}