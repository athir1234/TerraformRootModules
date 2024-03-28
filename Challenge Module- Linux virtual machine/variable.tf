variable "vnetname" {
  type        = string
  description = "Vnet Name"
}

variable "rgname" {
  type        = string
  description = "Name of the rgname"
}

variable "location" {
  type        = string
  description = "Name of the location"
}

variable "addspace" {
  type        = list(string)
  description = "address space"
}

variable "dnsservers" {
  type        = list(string)
  description = "DNS servers"
}

variable "subnet" {
  type        = string
  description = "Linux subnet"
}

variable "addprefix" {
  type        = list(string)
  description = "address prefix"
}

variable "net-inet" {
  type        = string
  description = "(optional) describe your variable"
}

variable "ipname" {
  type        = string
  description = "(optional) describe your variable"
}

# variable "subnetid" {
#   type        = string
#   description = "(optional) describe your variable"
# }

variable "addallocation" {
  type        = string
  description = "(optional) describe your variable"
}


# variable "linuxmachinename" {
#   type        = string
#   description = "(optional) describe your variable"
# }

variable "linuxmachinename" {
  type        = list(string)
  description = "(optional) describe your variable"
}

# variable "machinesize" {
#   type        = string
#   description = "(optional) describe your variable"
# }

variable "machinesize" {
  type        = list(string)
  description = "(optional) describe your variable"
}
variable "username" {
  type        = string
  description = "(optional) describe your variable"
}

variable "password" {
  type        = string
  description = "(optional) describe your variable"
}

variable "caching" {
  type        = string
  description = "(optional) describe your variable"
}

variable "accnttype" {
  type        = string
  description = "(optional) describe your variable"
}

variable "ospublisher" {
  type        = string
  description = "(optional) describe your variable"
}

variable "offer" {
  type        = string
  description = "(optional) describe your variable"
}

variable "sku" {
  type        = string
  description = "(optional) describe your variable"
}

variable "release" {
  type        = string
  description = "(optional) describe your variable"
}

variable "pip" {
  type        = string
  description = "(optional) describe your variable"
}

variable "allocation_method" {
  type        = string
  description = "(optional) describe your variable"
}