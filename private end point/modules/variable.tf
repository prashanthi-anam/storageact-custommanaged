#Variable file used to store details of repetitive references
variable "location" {
  description = "availability zone that is a string type variable"
  type        = string
  default     = "East US"
}
variable "resourcegrp" {
  description = "name of the resource group"
  type        = string
  default     = "rg1"
}

  

variable "vnet_address_space" {
  description = "adress space for vnet"
  type = string
  
}
variable "vm_subnet_address_prefix" {
  description = "adress space for subnet"
  type = string
}
variable "storage_subnet_address_prefix" {
  description = "adress space for subnet"
  type = string
}

variable "kv_enabled_for_deployment" {
  description = "Azure Key Vault Enabled for Deployment"
  type        = string
  
}
variable "kv_enabled_for_disk_encryption" {
  description = "Azure Key Vault Enabled for Disk Encryption"
  type        = string
  
}
variable "kv_enabled_for_template_deployment" {
  description = "Azure Key Vault Enabled for Deployment"
  type        = string
  
}
variable "account_tier" {
  description = "storage account of account tier"
  type = string
  
}
variable "account_replication_type" {
  description = "account_replication_type"
  type = string
  
}
