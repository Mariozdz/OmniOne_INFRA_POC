resource "azurerm_postgresql_flexible_server" "postgress_db" {
  name                = "postgress-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  version             = "15" # PostgreSQL version
  administrator_login    = "adminuser"
  administrator_password = var.db_pass
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  public_network_access_enabled = false
  delegated_subnet_id    = azurerm_subnet.private_db.id
}

resource "azurerm_private_endpoint" "db_pe" {
  name                = "db-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_db.id

  private_service_connection {
    name                           = "db-psc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgress_db.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
}