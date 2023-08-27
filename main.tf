//Creating a resource group in azure using terraform
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

#before you can create a vm you need to create the vnet

#Creates virtual networks
resource "azurerm_virtual_network" "vnet" {
  name     = "tf-vnet-eastus"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space = ["10.0.0.0/16"]
}

#Create a subnet
resource "azurerm_subnet" "subnet" {
    name = "tf-subnet-eastus"
    virtual_network_name = azurerm_virtual_network.vnet.name
    resource_group_name = var.resource_group_name
    address_prefixes = [ "10.0.0.0/24" ]
}

#create network interface card (NIC)
resource "azurerm_network_interface" "internal" {
    name = "tf-nic-int-eastus"
    location = var.resource_group_location
    resource_group_name = var.resource_group_name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.subnet.id
      private_ip_address_allocation = "Dynamic"
    }
}

#Create virtual Machine
resource "azurerm_windows_virtual_machine" "name" {
    name = "tf-vm-eastus"
    location = var.resource_group_location
    resource_group_name = var.resource_group_name
    size = "Standard_B1s"

    admin_username = "useradmin"
    admin_password      = "******"  # Placeholder password

    network_interface_ids = [
        azurerm_network_interface.internal.id
    ]

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "MicrosoftwindowsServer"
      offer ="WindowsServer"
      sku = "2016-DataCenter"
      version = "latest"
    }
}