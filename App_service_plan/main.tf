module "rgname" {
  source = "git::https://github.com/athir1234/TerraformChildModules.git//Resourcegroup"
  resource_group_name = var.rgname
  location = var.location
}

module "linuxappserviceplan" {
  source          = "git::https://github.com/athir1234/TerraformChildModules.git//App service plan"
  serviceplanname = var.serviceplanname
  rgname          = module.rgname.resource_group_name
  location        = module.rgname.location
  ostype          = var.ostype
  skuname         = var.skuname
}

module "linuxwebapp" {
  source = "git::https://github.com/athir1234/TerraformChildModules.git//Linux Web App"
  linuxwebappname = var.linuxwebappname
  rgname = module.rgname.resource_group_name
  location = module.rgname.location
  serviceplanid = module.linuxappserviceplan.serviceplanid #output block name from the child module
}
