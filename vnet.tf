resource "azurerm_virtual_network" "aks-petclinic" {
  name                = "aks-petclinic"
  resource_group_name = data.azurerm_resource_group.aks-petclinic.name 
  location            = data.azurerm_resource_group.aks-petclinic.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = data.azurerm_resource_group.aks-petclinic.name 
  virtual_network_name = azurerm_virtual_network.aks-petclinic.name
  address_prefixes     = ["10.254.0.0/22"]
}