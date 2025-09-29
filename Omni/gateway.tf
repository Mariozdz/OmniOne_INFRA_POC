resource "azurerm_application_gateway" "appgw" {
  name                = "web-appgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.app_gateway.id  # subnet dedicada para AG
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  backend_address_pool {
    name         = "web-backend-pool"
    ip_addresses = [azurerm_linux_virtual_machine.web_service_vm.private_ip_address]
  }

  backend_http_settings {
    name                  = "default-http-settings"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    cookie_based_affinity = "Disabled"
    probe_name            = "web-probe"

  }
  

  http_listener {
    name                           = "web-listener"
    frontend_ip_configuration_name = "appgw-frontend"
    frontend_port_name             = "http-port"
    protocol                       = "Http"

  }

  request_routing_rule {
    name                      = "web-routing"
    rule_type                 = "Basic"
    http_listener_name        = "web-listener"
    backend_address_pool_name = "web-backend-pool"
    backend_http_settings_name = "default-http-settings"
    priority                  = 100
  }

  probe {
    name                = "web-probe"
    protocol            = "Http"
    host                = azurerm_linux_virtual_machine.web_service_vm.private_ip_address
    path                = "/"
    interval            = 30
    timeout             = 120
    unhealthy_threshold = 3
  }

  tags = {
    environment = "lab"
  }
}

# resource "azurerm_application_gateway_firewall_policy" "waf_policy" {
#   name                = "web-appgw-waf"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   # Activar reglas predefinidas
#    managed_rules {
#     managed_rule_set {
#       type             = "OWASP"
#       rule_set_version = "3.2"   # obligatorio
#     }
#   }

# #   custom_rules {
# #     name      = "AllowExample"
# #     priority  = 1
# #     rule_type = "MatchRule"
# #     action    = "Allow"

# #     match_conditions {
# #       match_variables {
# #         variable_name = "RequestHeaders"
# #       }
# #       operator     = "Contains"
# #       match_values = ["example"]
# #     }
# #   }
# }

# resource "azurerm_application_gateway" "appgw" {
#   name                = "web-appgw"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   sku {
#     name     = "WAF_v2"          # O Standard_v2 si no quieres WAF
#     tier     = "WAF_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "appgw-ipcfg"
#     subnet_id = azurerm_subnet.public_subnet.id
#   }

#   frontend_ip_configuration {
#     name                 = "appgw-frontend"
#     public_ip_address_id = azurerm_public_ip.appgw_pip.id
#   }

#   frontend_port {
#     name = "http-port"
#     port = 80
#   }

#   backend_address_pool {
#     name = "web-backend-pool"
#     ip_addresses = [azurerm_linux_virtual_machine.web_vm.private_ip_address]
#   }

#   backend_http_settings {
#     name                  = "default-http-settings"
#     port                  = 80
#     protocol              = "Http"
#     request_timeout       = 20
#     cookie_based_affinity = "Disabled"
#   }

#   http_listener {
#     name                           = "web-listener"
#     frontend_ip_configuration_name = "appgw-frontend"
#     frontend_port_name             = "http-port"
#     protocol                       = "Http"
#   }

#   request_routing_rule {
#     name                      = "web-routing"
#     rule_type                 = "Basic"
#     http_listener_name         = "web-listener"
#     backend_address_pool_name  = "web-backend-pool"
#     backend_http_settings_name = "default-http-settings"
#   }

#   probe {
#     name                = "web-probe"
#     protocol            = "Http"
#     host                = azurerm_linux_virtual_machine.web_service_vm.private_ip_address
#     path                = "/"
#     interval            = 30
#     timeout             = 30
#     unhealthy_threshold = 3
#     pick_host_name_from_backend_http_settings = true
#   }

#   # Optional WAF settings (si usas WAF_v2)
#    waf_configuration {
#     enabled            = true
#     firewall_mode      = "Prevention"
#     rule_set_version = "3.2"
#   }

#   tags = {
#     environment = "lab"
#   }

#     depends_on = [azurerm_application_gateway_firewall_policy.waf_policy]

# }