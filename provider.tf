terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.15.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22" # Ou a versão desejada
    }

  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}

  use_cli = true # Isso garante que as credenciais da Azure CLI sejam utilizadas
}
