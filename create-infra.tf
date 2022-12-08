resource "azurerm_resource_group" "alpha" {
  name     = "alpha-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "alpha" {
  name                = "alpha-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.alpha.location
  resource_group_name = azurerm_resource_group.alpha.resource_group_name
}

resource "azurerm_subnet" "alpha" {
  name                 = "webapp-subnet"
  resource_group_name  = azurerm_resource_group.alpha.resource_group_name
  virtual_network_name = azurerm_virtual_network.alpha.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "alpha" {
  name                = "alpha-nic"
  location            = azurerm_resource_group.alpha.location
  resource_group_name = azurerm_resource_group.alpha.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.alpha.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "alpha" {
  name                = "alpha-machine"
  resource_group_name = azurerm_resource_group.alpha.resource_group_name
  location            = azurerm_resource_group.alpha.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.alpha.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}