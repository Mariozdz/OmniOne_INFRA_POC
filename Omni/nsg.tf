resource "azurerm_network_security_group" "web_nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Permite tráfico de App Gateway (HTTP/HTTPS)
#   security_rule {
#     name                       = "AllowAppGateway"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_ranges    = ["80","443"]
#     source_address_prefix      = "AzureLoadBalancer"
#     destination_address_prefix = "*"
#   }

  # Permite tráfico desde Bastion (SSH en Linux)
  security_rule {
    name                       = "AllowBastionSSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_subnet.bastion_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }


security_rule {
  name                       = "AllowAppGatewayTraffic"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_ranges    = ["80"]
  source_address_prefix      = azurerm_subnet.app_gateway.address_prefixes[0] # AG subnet
  destination_address_prefix = "*"
}

    security_rule {
    name                       = "AllowAGRequiredPorts"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }

  # Bloquea todo lo demás
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# resource "azurerm_network_security_group" "db_nsg" {
#   name                = "nsg-db"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   security_rule {
#     name                       = "AllowAppSubnet"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = azurerm_subnet.app_subnet.address_prefixes[0]
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "DenyAllInbound"
#     priority                   = 200
#     direction                  = "Inbound"
#     access                     = "Deny"
#     protocol                   = "*"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "db_assoc" {
#   subnet_id                 = azurerm_subnet.db_subnet.id
#   network_security_group_id = azurerm_network_security_group.db_nsg.id
# }