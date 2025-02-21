resource "azurerm_firewall" "fw" {
  name                = var.fw
  location            = var.location
  resource_group_name = var.rg
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  dns_proxy_enabled   = true

  ip_configuration {
    name                 = "front_ip"
    subnet_id            = var.snet_fw_id
    public_ip_address_id = var.pip_fw_id
  }
}

resource "azurerm_route_table" "rt_fw" {
  name                = "rt-out-fw"
  location            = var.location
  resource_group_name = var.rg

  route {
    name                   = "out-vnet-to-fw"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }

  route {
    name           = "out-fw-to-internet"
    address_prefix = "${var.pip_fw_address}/32"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "rta_fw" {
  subnet_id      = var.snet_aks_id
  route_table_id = azurerm_route_table.rt_fw.id
}

resource "azurerm_firewall_network_rule_collection" "aksfwnr" {
  name                = "aksfwnr"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.rg
  priority            = 300
  action              = "Allow"

  rule {
    name                  = "apiudp"
    protocols             = ["UDP"]
    source_addresses      = ["*"]
    destination_addresses = ["AzureCloud.${var.location}"]
    destination_ports     = ["1194"]
  }

  rule {
    name                  = "apitcp"
    protocols             = ["TCP"]
    source_addresses      = ["*"]
    destination_addresses = ["AzureCloud.${var.location}"]
    destination_ports     = ["9000"]
  }

  rule {
    name              = "time"
    protocols         = ["UDP"]
    source_addresses  = ["*"]
    destination_fqdns = ["ntp.ubuntu.com"]
    destination_ports = ["123"]
  }

  rule {
    name = "terraform"

    # Endereço IP ou FQDN do servidor de API do AKS
    destination_addresses = ["*"]
    # source_addresses      = ["*"]
    # source_addresses      = [data.http.pip_my]
    source_addresses  = ["${var.pip_my}"]
    destination_ports = ["443"]
    protocols         = ["TCP"]
  }

}

resource "azurerm_firewall_application_rule_collection" "aksfwar" {
  name                = "aksfwar"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.rg
  priority            = 310
  action              = "Allow"

  rule {
    name             = "fqdn"
    source_addresses = ["*"]
    fqdn_tags        = ["AzureKubernetesService"]
  }
}

resource "azurerm_firewall_application_rule_collection" "aksfwarweb" {
  name                = "aksfwarweb"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.rg
  priority            = 320
  action              = "Allow"

  rule {
    name             = "storage"
    source_addresses = ["10.42.1.0/24"]
    protocol {
      type = "Https"
      port = 443
    }
    target_fqdns = [
      "*.blob.storage.azure.net",
      "*.blob.core.windows.net"
    ]
  }

  rule {
    name             = "website"
    source_addresses = ["10.42.1.0/24"]
    protocol {
      type = "Https"
      port = 443
    }
    target_fqdns = [
      "ghcr.io",
      "*.docker.io",
      "*.docker.com",
      "*.githubusercontent.com",
      "*.cloudflarestorage.com"
    ]
  }
}
