resource "azurerm_bastion_host" "bastion" {
  name                = "admin-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
  sku = "Standard"
}

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

resource "azurerm_linux_virtual_machine" "web_service_vm" {
  name                = "web-service-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"  # free-tier
  admin_username      = "webuser"
  network_interface_ids = [
    azurerm_network_interface.web_service_nic.id
  ]

  # SSH key para acceso
  admin_ssh_key {
    username   = "webuser"
    public_key = file(var.key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "20.04.202505200"
  }
}
