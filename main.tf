module "rg" {
  source   = "./modules/rg"
  rg       = var.rg
  location = var.location
}

module "network" {
  source           = "./modules/network"
  rg               = var.rg
  location         = var.location
  vnet             = var.vnet
  snet_aks         = var.snet_aks
  snet_fw          = var.snet_fw
  vnet_address     = var.vnet_address
  snet_aks_address = var.snet_aks_address
  snet_fw_address  = var.snet_fw_address
  pip_fw           = var.pip_fw

  depends_on = [
    module.rg
  ]
}

module "fw" {
  source   = "./modules/fw"
  rg       = var.rg
  location = var.location
  fw       = var.fw

  pip_my         = module.network.pip_my
  pip_fw_address = module.network.pip_fw_address
  pip_fw_id      = module.network.pip_fw_id
  snet_fw_id     = module.network.snet_fw_id
  snet_aks_id    = module.network.snet_aks_id

  depends_on = [
    module.network
  ]
}

module "aks" {
  source = "./modules/aks"

  rg              = var.rg
  location        = var.location
  subscription_id = var.subscription_id
  aks_infra       = var.aks_infra
  aks_name        = var.aks_name
  aks_dns         = var.aks_dns
  aks_spool       = var.aks_spool
  aks_npool_lnx   = var.aks_npool_lnx
  aks_npool_win   = var.aks_npool_win
  vm_size         = var.vm_size

  vnet_id        = module.network.vnet_id
  snet_aks_id    = module.network.snet_aks_id
  pip_fw_address = module.network.pip_fw_address
  pip_my         = module.network.pip_my

  depends_on = [
    module.fw
  ]
}

module "app" {
  source = "./modules/app"

  rg = var.rg

  vnet_id        = module.network.vnet_id
  aks_name       = module.aks.aks_name
  fw_name        = module.fw.fw_name
  pip_fw_address = module.network.pip_fw_address

  depends_on = [
    module.aks
  ]

}
