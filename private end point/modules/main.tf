

resource "azurerm_resource_group" "example" {
  name     = var.resourcegrp
  location = var.location
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["${var.vnet_address_space}"]
  location            = var.location
  resource_group_name = var.resourcegrp
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "internal"
  resource_group_name  = var.resourcegrp
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["${var.vm_subnet_address_prefix}"]
  service_endpoints    = ["Microsoft.Storage"]
}
resource "azurerm_subnet" "storage" {
  name                                           = "st-subnet"
  resource_group_name                            = var.resourcegrp
  virtual_network_name                           = azurerm_virtual_network.vnet1.name
  address_prefixes                               = ["${var.storage_subnet_address_prefix}"]
  enforce_private_link_endpoint_network_policies = true
  service_endpoints                              = ["Microsoft.Storage"]
}
resource "azurerm_public_ip" "publicip" {

  name                = "publicip-tomcatvm"
  location            = var.location
  resource_group_name = var.resourcegrp
  allocation_method   = "Dynamic"
  depends_on = [ azurerm_resource_group.example ]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = var.location
  resource_group_name = var.resourcegrp

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg1"
  location            = var.location
  resource_group_name = var.resourcegrp

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [
    azurerm_network_interface.example
  ]
}

resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}
# Create (and display) an SSH key
resource "tls_private_key" "linuxsrvuserprivkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = var.resourcegrp
  location            = var.location

  size = "Standard_DC1ds_v3"

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    name                 = "corpwebservervm01disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "corporate-webserver-vm-01"
  admin_username                  = "linuxsrvuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "linuxsrvuser"
    public_key = tls_private_key.linuxsrvuserprivkey.public_key_openssh
  }
}
resource "azurerm_private_endpoint" "storage_endpoint" {
  name                = "storage-endpoint"
  location            = var.location
  resource_group_name = var.resourcegrp
  subnet_id           = azurerm_subnet.storage.id

  private_service_connection {
    name = "storage-connection"

    private_connection_resource_id = azurerm_storage_account.example.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resourcegrp
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "example-link"
  resource_group_name   = var.resourcegrp
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.vnet1.id
}
/*resource "null_resource" "install_tomcat" {
  triggers = {
    instance_id = azurerm_linux_virtual_machine.example.id
  }

  provisioner "remote-exec" {
    connection {
      type       = "ssh"
      host       = azurerm_linux_virtual_machine.example.public_ip_address
      #username   = "linuxsrvuser"
      #public_key = tls_private_key.linuxsrvuserprivkey.public_key_openssh # or use `private_key` if using SSH key authentication
    }

    inline = [
    "sudo apt-get update",
    "sudo apt-get install -y openjdk-8-jdk",
    
    "sudo apt-get install -y tomcat9",
    "sudo systemctl start tomcat9",
    "sudo systemctl enable tomcat9",

    "sudo mkdir /var/lib/tomcat9/webapps/mywebapp",
    "sudo mkdir -p /var/lib/tomcat9/webapps/sampleapp",
    "sudo touch /var/lib/tomcat9/webapps/sampleapp/index.html",
    
    # Deploy the sample application 
    "sudo sh -c 'echo \"<html><body><h2>Hello, World!</h2></body></html>\" > /var/lib/tomcat9/webapps/sampleapp/index.html'",
  ]
  }

  depends_on = [azurerm_linux_virtual_machine.example, azurerm_public_ip.publicip]
}*/
