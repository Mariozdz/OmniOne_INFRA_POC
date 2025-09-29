# resource "azurerm_frontdoor_profile" "fd" {
#   name                = "examplefd"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = "Global"
#   sku_name            = "Standard_AzureFrontDoor"
# }

# resource "azurerm_frontdoor_backend" "appgw_backend" {
#   name                = "appgw-backend"
#   resource_group_name = azurerm_resource_group.rg.name
#   frontdoor_profile_name = azurerm_frontdoor_profile.fd.name
#   backend_address     = "appgw-public-ip"
#   backend_host_header = "appgw-public-ip"
#   backend_port        = 443
#   enabled             = true
# }

# resource "azurerm_frontdoor_backend_pool_load_balancing" "appgw_lb" {
#   name                = "appgw-lb"
#   resource_group_name = azurerm_resource_group.rg.name
#   frontdoor_profile_name = azurerm_frontdoor_profile.fd.name
#   sample_size         = 4
#   successful_samples_required = 2
# }

# resource "azurerm_frontdoor_backend_pool_health_probe" "appgw_health_probe" {
#   name                = "appgw-health-probe"
#   resource_group_name = azurerm_resource_group.rg.name
#   frontdoor_profile_name = azurerm_frontdoor_profile.fd.name
#   protocol            = "Https"
#   path                = "/"
#   interval_in_seconds = 30
#   health_probe_method = "GET"
# }

# resource "azurerm_frontdoor_routing_rule" "route_to_appgw" {
#   name                     = "route-to-appgw"
#   resource_group_name      = azurerm_resource_group.rg.name
#   frontdoor_profile_name   = azurerm_frontdoor_profile.fd.name
#   accepted_protocols       = ["Https"]
#   patterns_to_match        = ["/*"]
#   frontend_endpoints       = ["default"]
#   forwarding_configuration {
#     backend_pool_name      = azurerm_frontdoor_backend_pool.appgw_backend_pool.name
#     forwarding_protocol    = "HttpsOnly"
#   }
# }