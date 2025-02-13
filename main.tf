provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "ad_rg" {
  name     = "ADResourceGroup"
  location = "East US"
}

resource "azurerm_virtual_network" "ad_vnet" {
  name                = "ADVirtualNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ad_rg.location
  resource_group_name = azurerm_resource_group.ad_rg.name
}

resource "azurerm_subnet" "ad_subnet" {
  name                 = "ADSubnet"
  resource_group_name  = azurerm_resource_group.ad_rg.name
  virtual_network_name = azurerm_virtual_network.ad_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "ad_nsg" {
  name                = "ADNSG"
  location            = azurerm_resource_group.ad_rg.location
  resource_group_name = azurerm_resource_group.ad_rg.name
}

resource "azurerm_network_interface" "dc_nic" {
  name                = "DCNIC"
  location            = azurerm_resource_group.ad_rg.location
  resource_group_name = azurerm_resource_group.ad_rg.name

  ip_configuration {
    name                          = "DCIPConfig"
    subnet_id                     = azurerm_subnet.ad_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dc_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "dc_nic_nsg_assoc" {
  network_interface_id = azurerm_network_interface.dc_nic.id
  network_security_group_id = azurerm_network_security_group.ad_nsg.id
}

resource "azurerm_virtual_machine" "dc_vm" {
  name                  = "DomainController"
  location              = azurerm_resource_group.ad_rg.location
  resource_group_name   = azurerm_resource_group.ad_rg.name
  network_interface_ids = [azurerm_network_interface.dc_nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "dc_os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "dc"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

resource "azurerm_network_security_rule" "allow_rdp" {
  name                        = "AllowRDP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ad_rg.name
  network_security_group_name = azurerm_network_security_group.ad_nsg.name
}

resource "azurerm_public_ip" "dc_public_ip" {
  name                = "DCPublicIP"
  location            = azurerm_resource_group.ad_rg.location
  resource_group_name = azurerm_resource_group.ad_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "dc_public_ip_address" {
  value = azurerm_public_ip.dc_public_ip.ip_address
}

# Repeat similar blocks for Windows 10 and Windows 11 VMs 