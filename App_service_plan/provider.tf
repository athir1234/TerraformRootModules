terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "myfirstrg1"
    storage_account_name = "myfirstsa09022024231900"
    container_name       = "tfstate"
    key                  = "terraform.module.tfstate"
    use_oidc             = true
    }
}

provider "azurerm" {
  features {}
  use_oidc = true
}