

data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "example" {
}
resource "azurerm_role_assignment" "role_assignments" {

  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.example.object_id
  depends_on = [ azurerm_key_vault.key_vault ]
}
resource "azurerm_role_assignment" "role_assignments1" {

  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.example.object_id
  depends_on = [ azurerm_key_vault.key_vault ]
}

resource "azurerm_role_assignment" "example" {
  principal_id         = data.azurerm_client_config.example.object_id
  role_definition_name = "Contributor"
  scope                = azurerm_storage_account.example.id
}
resource "azurerm_role_assignment" "rbac_assignment_reader" {
   scope                = azurerm_key_vault.key_vault.id
   role_definition_name = "Key Vault Administrator"
   principal_id         = azurerm_storage_account.example.identity[0].principal_id
}



resource "azurerm_key_vault" "key_vault" {
  name                            = "kvstrkey23"
  location                        = var.location
  resource_group_name             = var.resourcegrp
  enabled_for_deployment          = var.kv_enabled_for_deployment
  enabled_for_disk_encryption     = var.kv_enabled_for_disk_encryption
  enabled_for_template_deployment = var.kv_enabled_for_template_deployment
  tenant_id                       = data.azurerm_client_config.example.tenant_id
  sku_name                        = "standard"
  purge_protection_enabled        = true
  enable_rbac_authorization  = true
  soft_delete_retention_days      = 7
    
  

 
  
  depends_on = [azurerm_resource_group.example]
}

resource "azurerm_key_vault_key" "generated" {
  name         = "custkey"
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_storage_account" "example" {
  name                          = "teststorageacnt18"
  resource_group_name           = var.resourcegrp
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
  depends_on = [azurerm_resource_group.example]
}
resource "azurerm_storage_account_network_rules" "example" {
  storage_account_id = azurerm_storage_account.example.id

  default_action = "Deny" # Set to "Allow" or "Deny" as needed

  # Define the allowed IP ranges
  ip_rules = [
    "0.0.0.0/0",   # Allow all IPs
    "49.204.2.89", # Example: Allow specific IP range
  ]

  # Define virtual network and subnet rules (if needed)
  virtual_network_subnet_ids = [
    azurerm_subnet.vm_subnet.id, azurerm_subnet.storage.id # Example: Allow traffic from a specific subnet
  ]
}

resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
  depends_on            = [azurerm_storage_account.example]
}


resource "azurerm_storage_account_customer_managed_key" "example" {
  storage_account_id = azurerm_storage_account.example.id
  key_vault_id       = azurerm_key_vault.key_vault.id
  key_name           = azurerm_key_vault_key.generated.name
  depends_on         = [azurerm_key_vault.key_vault, azurerm_storage_account.example]
}



