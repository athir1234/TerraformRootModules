

variable "location" {
  type = list(string)
  description = "(optional) describe your variable"
}

variable "dnsservers" {
  type = list(string)
  description = "(optional) describe your variable"
}

variable "addspace" {
  type = list(string)
  description = "(optional) describe your variable"
}

# variable "subnetname" {
#     type = string
#     description = "(optional) describe your variable"
#  }

# variable "vnet" {
#     type = string
#     description = "(optional) describe your variable"
# }

variable "address_prefix" {
  type = list(string)
}

variable "security_rule" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = number
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [{
    name                       = "ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    },
    {
    name                       = "Http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
    ]
}