######################################
# Load Balancer
######################################
resource "azurerm_lb" "was_lb" {
  name                = "was-loadbalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "was-lb-frontend"
    subnet_id                     = azurerm_subnet.private_app.id 
    private_ip_address_allocation = "Dynamic"
  }
}

######################################
# Backend Pool (WAS VMs)
######################################
resource "azurerm_lb_backend_address_pool" "was_pool" {
  name            = "was-backend-pool"
  loadbalancer_id = azurerm_lb.was_lb.id
}

######################################
# Health Probe
######################################
resource "azurerm_lb_probe" "was_probe" {
  name                = "http-probe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  loadbalancer_id     = azurerm_lb.was_lb.id
  interval_in_seconds = 5
  number_of_probes    = 2
}

######################################
# Load Balancer Rule
######################################
resource "azurerm_lb_rule" "was_rule" {
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "was-lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.was_pool.id]
  probe_id                       = azurerm_lb_probe.was_probe.id
  loadbalancer_id                = azurerm_lb.was_lb.id
}


resource "azurerm_network_interface_backend_address_pool_association" "was_nic_assoc" {
  count                   = var.was_app_quantity 
  network_interface_id    = azurerm_network_interface.was_nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.was_pool.id
}
