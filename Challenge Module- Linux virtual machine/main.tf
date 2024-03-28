module "Resourcegroup" {
  source              = "C:/Reciprocal/Technical/Azure/Terraform/TFModules/Resourcegroup"
  resource_group_name = var.rgname
  location            = var.location
}

# data "azurerm_resource_group" "resgrp" {
#   name = "devrg"
# }

module "VirtualNetwork" {
  source   = "C:/Reciprocal/Technical/Azure/Terraform/TFModules/Virtual Network"
  vnetname = var.vnetname
  location = module.Resourcegroup.location
  # location = data.azurerm_resource_group.resgrp.location
  resgrpname = module.Resourcegroup.resource_group_name
  # resgrpname = data.azurerm_resource_group.resgrp.name
  addspace   = var.addspace
  dnsservers = var.dnsservers
}

module "linuxsubnet" {
  source     = "C:/Reciprocal/Technical/Azure/Terraform/TFModules/Linux Subnet"
  subnet     = var.subnet
  resgrpname = module.Resourcegroup.resource_group_name
  vnet       = module.VirtualNetwork.vnetname
  addprefix  = var.addprefix
}
module "publicip" {
  count = length(var.linuxmachinename)
  source     = "C:/Reciprocal/Technical/Azure/Terraform/TFModules/PublicIPAddress"
  pip        = "var.pip.${count.index}"
  resgrpname = module.Resourcegroup.resource_group_name
  location   = module.Resourcegroup.location
  allocation_method = var.allocation_method
}

module "net-int" {
  source        = "C:/Reciprocal/Technical/Azure/Terraform/TFModules/NetworkInterface"
  count = length(var.linuxmachinename)
  net-int       = "var.net-inet.${count.index}"
  location      = module.Resourcegroup.location
  resgrpname    = module.Resourcegroup.resource_group_name
  ipname        = var.ipname
  subnetid      = module.linuxsubnet.subnetid
  addallocation = var.addallocation
  pip           = "module.publicip.linuxpip.${count.index}"
}

locals {
  machinesize = ["Standard_F4","Standard_F2"]
}

module "linuxvm" {
  source           = "C:/Reciprocal/Technical/Azure/Terraform/TFModules/Linux Virtual Machine"
  for_each = toset(var.linuxmachinename)
  linuxmachinename = each.key
  location         = module.Resourcegroup.location
  resgrpname       = module.Resourcegroup.resource_group_name
  machinesize      = each.key == "ControlPlane" ? "Standard_F4" : "Standard_F2"
  netintid         = module.net-int[each.key].netintid
  username         = var.username
  password         = var.password
  caching          = var.caching
  accnttype        = var.accnttype
  ospublisher      = var.ospublisher
  offer            = var.offer
  sku              = var.sku
  osrelease        = var.release
}