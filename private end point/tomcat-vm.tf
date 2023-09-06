terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.49.0"
    }
  }
}
module "vm" {
  source                             = "./modules"
  vnet_address_space                 = "10.0.0.0/16"
  vm_subnet_address_prefix           = "10.0.2.0/24"
  storage_subnet_address_prefix      = "10.0.3.0/24"
  resourcegrp                        = "rg1"
  location                           = "East Us"
  kv_enabled_for_deployment          = "true"
  kv_enabled_for_disk_encryption     = "true"
  kv_enabled_for_template_deployment = "true"
  account_replication_type           = "LRS"
  account_tier                       = "Standard"

}
