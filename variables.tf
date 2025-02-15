# Define your variables here
variable "subscription_id" {
  description = "The Azure subscription ID where the resources will be created"
  type        = string
  sensitive   = true
}

variable "username" {
  description = "The username for the admin account"
  type        = string
}

variable "password" {
  description = "The password for the admin account"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
}

# Create a Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "ad-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a Subnet
resource "azurerm_subnet" "example" {
  name                 = "ad-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = "ad-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Create a Public IP for the Domain Controller
resource "azurerm_public_ip" "dc" {
  name                = "dc-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

# Create a Network Interface for the Domain Controller
resource "azurerm_network_interface" "dc" {
  name                = "dc-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "dc-ipconfig"
    subnet_id                    = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         = azurerm_public_ip.dc.id
  }
}

# Create the Domain Controller VM
resource "azurerm_windows_virtual_machine" "dc" {
  name                = "ad-dc"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [azurerm_network_interface.dc.id]

  os_disk {
    caching              = "ReadWrite"
    create_option        = "FromImage"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Create Windows 10 VM
resource "azurerm_windows_virtual_machine" "win10" {
  name                = "win10-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [azurerm_network_interface.dc.id]

  os_disk {
    caching              = "ReadWrite"
    create_option        = "FromImage"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "19h2-pro"
    version   = "latest"
  }
}

# Create Windows 11 VM
resource "azurerm_windows_virtual_machine" "win11" {
  name                = "win11-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [azurerm_network_interface.dc.id]

  os_disk {
    caching              = "ReadWrite"
    create_option        = "FromImage"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "21h2-pro"
    version   = "latest"
  }
}

# Create additional VMs (3 VMs)
resource "azurerm_windows_virtual_machine" "additional_vm" {
  count               = 3
  name                = "additional-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234"
  network_interface_ids = [azurerm_network_interface.dc.id]

  os_disk {
    caching              = "ReadWrite"
    create_option        = "FromImage"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
} 