resource "azurerm_kubernetes_cluster" "aks-petclinic" {
  name                = "aks-petclinic"
  dns_prefix          = "aks-petclinic"
  resource_group_name = data.azurerm_resource_group.aks-petclinic.name
  location            = data.azurerm_resource_group.aks-petclinic.location

  role_based_access_control_enabled = true

  default_node_pool {
    name                = "app"
    vm_size             = "Standard_D4as_v4"
    enable_auto_scaling = false
    node_count          = 3
    vnet_subnet_id      = azurerm_subnet.app.id
  }

  network_profile {
    network_plugin     = "kubenet"
    pod_cidr           = "172.16.0.0/16"
    service_cidr       = "172.29.100.0/24"
    dns_service_ip     = "172.29.100.10"
    docker_bridge_cidr = "172.29.101.0/24"  
  }

  storage_profile {
    blob_driver_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_role_assignment" "aks-subnet" {
  scope                = azurerm_virtual_network.aks-petclinic.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks-petclinic.identity.0.principal_id
}

resource "azurerm_role_assignment" "aks-resource-group" {
  scope                = data.azurerm_resource_group.aks-petclinic.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks-petclinic.identity.0.principal_id
}