# Configure the Microsoft Azure Provider
provider "azurerm" {

  skip_provider_registration = true 
  features = {}

}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet Public
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet Private
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group for VM
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  resource_group_name = azurerm_resource_group.example.name
}

# Network Interface for VM
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "example-nic-configuration"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "example" {
  name                  = "example-vm"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "AdminPassword1234!"
  network_interface_ids = [azurerm_network_interface.example.id]

  os_profile {
    computer_name  = "example-vm"
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# Apache VM Extension
resource "azurerm_virtual_machine_extension" "apache" {
  name                 = "customScript"
  virtual_machine_id   = azurerm_virtual_machine.example.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "./install_apache_php.sh"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {}
PROTECTED_SETTINGS
}

# Custom Script for Apache and PHP installation
resource "azurerm_storage_account" "script_storage" {
  name                     = "scriptstorage${random_string.random_suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_container" "script_container" {
  name                  = "scriptcontainer"
  storage_account_name  = azurerm_storage_account.script_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "install_script" {
  name                   = "install_apache_php.sh"
  storage_account_name   = azurerm_storage_account.script_storage.name
  storage_container_name = azurerm_storage_container.script_container.name
  type                   = "Block"
  content                = file("${path.module}/install_apache_php.sh")
}

# Network Security Group Rule for Apache
resource "azurerm_network_security_rule" "allow_apache" {
  name                        = "allow_apache"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 80
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}
