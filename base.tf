provider "azurerm" {
  features {}
}

provider "kubernetes" {
    host = "${azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.host}"

    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.cluster_ca_certificate)}"
}

provider "helm" {
  kubernetes {
    host = "${azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.host}"

    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.aks-petclinic.kube_config.0.cluster_ca_certificate)}"
  }
}

variable "aks-petclinic-rg" {
  type    = string
  default = "petclinic"
}

data "azurerm_resource_group" "aks-petclinic" {
    name = var.aks-petclinic-rg
}