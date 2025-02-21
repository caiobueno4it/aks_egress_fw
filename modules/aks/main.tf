resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.rg
  dns_prefix          = var.aks_dns
  sku_tier            = "Free"
  node_resource_group = var.aks_infra

  default_node_pool {
    name                 = var.aks_spool
    vm_size              = var.vm_size
    node_count           = 1
    auto_scaling_enabled = false
    os_sku               = "Ubuntu"
    vnet_subnet_id       = var.snet_aks_id
  }

  identity {
    type = "SystemAssigned"
  }


  network_profile {
    network_plugin = "azure"
    outbound_type  = "userDefinedRouting"
  }

  api_server_access_profile {
    authorized_ip_ranges = [
      "${var.pip_fw_address}/32", # IP público do Firewall
      # "${data.http.pip_my.response_body}/32" # IP público do host local
      "${var.pip_my}/32" # IP público do host local
    ]
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "aks_nodepool_lnx" {
  name                  = var.aks_npool_lnx
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_size
  node_count            = 1
  auto_scaling_enabled  = false
  os_type               = "Linux"
  os_sku                = "AzureLinux"


  # Evitar recriações desnecessárias do nodepool
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

