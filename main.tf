# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "tfserver" {
  name     = "tfserver"
  location = "Canada East"
}

resource "azurerm_virtual_network" "tfserver" {
  name                = "tfserver-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tfserver.location
  resource_group_name = azurerm_resource_group.tfserver.name
}

resource "azurerm_subnet" "tfserver" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.tfserver.name
  virtual_network_name = azurerm_virtual_network.tfserver.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "tfserver" {
  name                = "tfserver-nic"
  location            = azurerm_resource_group.tfserver.location
  resource_group_name = azurerm_resource_group.tfserver.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tfserver.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfserver.id
  }
}

resource "azurerm_public_ip" "tfserver" {
  name                = "tfserver-public-nic"
  resource_group_name = azurerm_resource_group.tfserver.name
  location            = azurerm_resource_group.tfserver.location
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "tfserver" {
  name                = "tfserver-machine"
  resource_group_name = azurerm_resource_group.tfserver.name
  location            = azurerm_resource_group.tfserver.location
  size                = "Standard_F2"
  admin_username      = "tfadmin"
  network_interface_ids = [
    azurerm_network_interface.tfserver.id,
  ]

  admin_ssh_key {
    username   = "tfadmin"
    public_key = file("./.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "60"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "tfserver" {
  name                = "tfserver_security_group"
  location            = azurerm_resource_group.tfserver.location
  resource_group_name = azurerm_resource_group.tfserver.name
}

resource "azurerm_network_security_rule" "ssh_port" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfserver.name
  network_security_group_name = azurerm_network_security_group.tfserver.name
}

resource "azurerm_network_security_rule" "tfe_https" {
  name                        = "TFE HTTPS"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfserver.name
  network_security_group_name = azurerm_network_security_group.tfserver.name
}

resource "azurerm_network_security_rule" "tfe_dashboard" {
  name                        = "TFE Dashboard"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8800"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.tfserver.name
  network_security_group_name = azurerm_network_security_group.tfserver.name
}
