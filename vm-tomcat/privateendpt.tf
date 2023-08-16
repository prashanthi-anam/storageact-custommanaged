

resource "azurerm_private_endpoint" "storage_endpoint" {
  name                = "storage-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.example.id

  private_service_connection {
    name                             = "storage-connection"
    private_connection_resource_id   = azurerm_storage_account.example.id
    subresource_names                = ["blob"]
    is_manual_connection_assignment = false
  }
}
