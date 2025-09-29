# VNET and subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "did-vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_app" {
  name                 = "private-app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Delegated subnet for Azure flexible postgress server
resource "azurerm_subnet" "private_db" {
  name                 = "private-db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  delegation {
    name = "db-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}


resource "azurerm_subnet" "app_gateway" {
  name                 = "app_gateway-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}


resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"   
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/27"] 
}

resource "azurerm_public_ip" "bastion_ip" {
  name                = "admin-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


# App gateway public IP for web public subnet
resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# public web subnet nic for front app
resource "azurerm_network_interface" "web_service_nic" {
  name                = "web-service-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.20"         
  }
}

# private was subnet nics for vms
resource "azurerm_network_interface" "was_nic" {
  count               = var.was_app_quantity
  name                = "was-nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.private_app.id
    private_ip_address_allocation = "Dynamic"
  }
}

# # Public IP for NAT Gateway - public - web subnet# 
# # Disabled to avois credit consumption during testing

# resource "azurerm_public_ip" "web_nat_ip" {
#   name                = "web-nat-gateway-ip"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# #NAT 
# resource "azurerm_nat_gateway" "web_nat" {
#   name                = "web-nat-gateway"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "Standard"

# }

# resource "azurerm_nat_gateway_public_ip_association" "web_nat_gateway_assoc" {
#   nat_gateway_id       = azurerm_nat_gateway.web_nat.id
#   public_ip_address_id = azurerm_public_ip.web_nat_ip.id
# }

# # Gateway ↔ Subnet
# resource "azurerm_subnet_nat_gateway_association" "web_subnet_nat" {
#   subnet_id      = azurerm_subnet.private_app.id
#   nat_gateway_id = azurerm_nat_gateway.web_nat.id
# }

# # Public IP for NAT Gateway - private - was - private app subnet# 
# resource "azurerm_public_ip" "was_nat_ip" {
#   name                = "was-nat-gateway-ip"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# #NAT 
# resource "azurerm_nat_gateway" "was_nat" {
#   name                = "was-nat-gateway"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "Standard"

# }

# resource "azurerm_nat_gateway_public_ip_association" "was_nat_gateway_assoc" {
#   nat_gateway_id       = azurerm_nat_gateway.was_nat.id
#   public_ip_address_id = azurerm_public_ip.was_nat_ip.id
# }

# # Gateway ↔ Subnet
# resource "azurerm_subnet_nat_gateway_association" "was_subnet_nat" {
#   subnet_id      = azurerm_subnet.private_app.id
#   nat_gateway_id = azurerm_nat_gateway.was_nat.id
# }

