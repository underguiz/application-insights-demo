resource "azurerm_log_analytics_workspace" "petclinic" {
  name                = "petclinic"
  location            = data.azurerm_resource_group.aks-petclinic.location
  resource_group_name = data.azurerm_resource_group.aks-petclinic.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1
}

resource "azurerm_application_insights" "petclinic" {
  name                = "petclinic"
  location            = data.azurerm_resource_group.aks-petclinic.location
  resource_group_name = data.azurerm_resource_group.aks-petclinic.name
  workspace_id        = azurerm_log_analytics_workspace.petclinic.id
  application_type    = "web"
}