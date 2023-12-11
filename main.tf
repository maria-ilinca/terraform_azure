# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true 
  features = {}
}

# Create a resource group
resource "azurerm_resource_group" "ilinca" {
  name     = "ilinca"
  location = "East Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "ilinca" {
  name                = "ilinca-vnet"
  resource_group_name = azurerm_resource_group.ilinca.name
  location            = azurerm_resource_group.ilinca.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet Public
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.ilinca.name
  virtual_network_name = azurerm_virtual_network.ilinca.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Subnet Private
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.ilinca.name
  virtual_network_name = azurerm_virtual_network.ilinca.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group for VM
resource "azurerm_network_security_group" "ilinca" {
  name                = "ilinca-nsg"
  resource_group_name = azurerm_resource_group.ilinca.name
}

# Network Interface for VM
resource "azurerm_network_interface" "ilinca" {
  name                = "ilinca-nic"
  resource_group_name = azurerm_resource_group.ilinca.name

  ip_configuration {
    name                          = "ilinca-nic-configuration"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Database Server in Subnet Private
resource "azurerm_virtual_machine" "ilinca_database" {
  name                  = "ilinca-database-vm"
  resource_group_name   = azurerm_resource_group.ilinca.name
  location              = azurerm_resource_group.ilinca.location
  size                  = "Standard_DS1_v2"
  admin_username        = "dbadmin"
  admin_password        = "DBPassword1234!" 
  network_interface_ids = [azurerm_network_interface.ilinca_database.id]

  os_profile {
    computer_name  = "ilinca-database-vm"
    admin_username = "dbadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# Network Interface for Database VM
resource "azurerm_network_interface" "ilinca_database" {
  name                = "ilinca-database-nic"
  resource_group_name = azurerm_resource_group.ilinca.name

  ip_configuration {
    name                          = "ilinca-database-nic-configuration"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

# SQL Server
resource "azurerm_sql_server" "ilinca_sql_server" {
  name                         = "ilinca-sql-server"
  resource_group_name          = azurerm_resource_group.ilinca.name
  location                     = azurerm_resource_group.ilinca.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "SqlAdminPassword1234!"
}

# SQL Database
resource "azurerm_sql_database" "ilinca_sql_db" {
  name                        = "ilinca-sql-db"
  resource_group_name         = azurerm_resource_group.ilinca.name
  location                    = azurerm_resource_group.ilinca.location
  server_name                 = azurerm_sql_server.ilinca_sql_server.name
  edition                     = "Standard"
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = 1
  requested_service_objective = "S0"
}

# Virtual Machine
resource "azurerm_virtual_machine" "ilinca" {
  name                  = "ilinca-vm"
  resource_group_name   = azurerm_resource_group.ilinca.name
  location              = azurerm_resource_group.ilinca.location
  size                  = "Standard_DS1_v2"
  admin_username        = "admin"
  admin_password        = "AdminPassword1234!"
  network_interface_ids = [azurerm_network_interface.ilinca.id]

  os_profile {
    computer_name  = "ilinca-vm"
    admin_username = "admin"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# Apache VM Extension
resource "azurerm_virtual_machine_extension" "phpmyadmin" {
  name                 = "customScript"
  virtual_machine_id   = azurerm_virtual_machine.ilinca.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "script": "./install_phpmyadmin.sh"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {}
PROTECTED_SETTINGS
}

# Custom Script for PHPMyAdmin installation
resource "azurerm_storage_blob" "install_phpmyadmin_script" {
  name                   = "install_phpmyadmin.sh"
  storage_account_name   = azurerm_storage_account.script_storage.name
  storage_container_name = azurerm_storage_container.script_container.name
  type                   = "Block"
  content                = file("${path.module}/install_phpmyadmin.sh")
}
