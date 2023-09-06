/*terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.49.0"
    }
  }
}*/
provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_keys_on_destroy = true
      recover_soft_deleted_keys          = true
    }
  }

}

/*terraform {
  backend "azurerm" {
    resource_group_name   = "rg1"   # Name of the Azure Resource Group where the Storage Account is located
    storage_account_name  = "teststorageacnt18"  # Name of the Azure Storage Account
    container_name        = "tfstate"           # Name of the Blob container to store the state file
    key                   = "terraform.tfstate" # Name of the state file within the container
    
  }
    
}*/


