# Output de la VM Web
output "web_vm_private_ip" {
  description = "IP privada de la VM Web"
  value       = azurerm_linux_virtual_machine.web_service_vm.private_ip_address
}

output "web_vm_id" {
  description = "ID de la VM Web"
  value       = azurerm_linux_virtual_machine.web_service_vm.id
}

# Output del Public IP del Application Gateway
output "appgw_public_ip" {
  description = "IP pública asignada al Application Gateway"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

# Output del Application Gateway
output "appgw_id" {
  description = "ID del Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "appgw_frontend_ip" {
  description = "IP frontend del Application Gateway"
  value       = azurerm_application_gateway.appgw.frontend_ip_configuration[0].private_ip_address
}
