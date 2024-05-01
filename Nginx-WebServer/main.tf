resource "azurerm_resource_group" "my_resource_group" {
  name     = "Neginx_Webserver"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  for_each = toset(var.location)
  name                = "Vnet_${each.value}"
  location            = each.value
  resource_group_name = azurerm_resource_group.my_resource_group.name
  address_space       = var.addspace
  dns_servers         = var.dnsservers
}

resource "azurerm_subnet" "linuxsubnet" {
  depends_on = [ azurerm_virtual_network.vnet ]
  for_each = toset(var.location)
  name                 = "subnet_${each.value}"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = var.address_prefix
}


resource "azurerm_public_ip" "pip" {
  for_each = toset(var.location)
  name                = "Pip_${each.value}"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = each.value
  allocation_method   = "Dynamic"
  domain_name_label = lower("Pip-${each.value}")
}


resource "azurerm_network_interface" "net-int" {
  depends_on = [ azurerm_virtual_network.vnet,azurerm_public_ip.pip ]
  for_each = toset(var.location)
  name                = "NginxNic-${each.value}"
  location            = each.key
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "NginxPrivateIp${each.value}"
    subnet_id                     = azurerm_subnet.linuxsubnet[each.key].id
    private_ip_address_allocation = "Dynamic"    
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "Nginx" {
  for_each = toset(var.location)
  name                = "NginxServer-${each.value}"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  location            = each.key
  custom_data = base64encode(file("init.sh"))
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password = "Password123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.net-int[each.key].id
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
resource "azurerm_network_security_group" "nsgnginx" {
  for_each = toset(var.location)
  name                = "NSG-${each.value}"
  location            = each.key
  resource_group_name = azurerm_resource_group.my_resource_group.name

  dynamic "security_rule" {
    for_each = var.security_rule
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgassociation" {
  for_each = toset(var.location)
  subnet_id = azurerm_subnet.linuxsubnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsgnginx[each.key].id
}

resource "random_string" "trafficmanager" {
  length = 5
  upper = false
  special = false
}

resource "azurerm_traffic_manager_profile" "TFLB" {
  name = "nginx-lb-${random_string.trafficmanager.result}"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  traffic_routing_method = "Weighted"
  
  dns_config {
    relative_name = "nginx-lb-${random_string.trafficmanager.result}"
    ttl = 100
  }
  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
  }
resource "azurerm_traffic_manager_azure_endpoint" "endpoint" {
  for_each = toset(var.location)
  name                 = "nginx-ep-${each.value}"
  profile_id           = azurerm_traffic_manager_profile.TFLB.id
  always_serve_enabled = true
  weight               = 100
  target_resource_id   = azurerm_public_ip.pip[each.key].id
}
