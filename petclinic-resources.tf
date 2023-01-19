resource "random_string" "storage-account" {
  length           = 6
  special          = false
  upper            = false
}

resource "azurerm_storage_account" "appinsights-blob" {
  name                     = "appinsblob${random_string.storage-account.result}"
  resource_group_name      = data.azurerm_resource_group.aks-petclinic.name
  location                 = data.azurerm_resource_group.aks-petclinic.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "appinsights-blob" {
  name                  = "appinsights-blob"
  storage_account_name  = azurerm_storage_account.appinsights-blob.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "appinsights-agent" {
  name                   = "applicationinsights-agent-3.4.7.jar"
  storage_account_name   = azurerm_storage_account.appinsights-blob.name
  storage_container_name = azurerm_storage_container.appinsights-blob.name
  type                   = "Block"
  source                 = "applicationinsights-agent-3.4.7.jar"
}

resource "kubernetes_namespace" "spring-petclinic" {
  metadata {
    annotations = {
      name = "spring-petclinic"
    }

    name = "spring-petclinic"
  }
}

resource "kubernetes_secret" "appinsights-blob-secret" {
  metadata {
    name      = "appinsights-blob-secret"
    namespace = kubernetes_namespace.spring-petclinic.metadata.0.name
  }

  data = {
    azurestorageaccountname = azurerm_storage_account.appinsights-blob.name
    azurestorageaccountkey  = azurerm_storage_account.appinsights-blob.primary_access_key
  }

}

resource "kubernetes_secret" "app-insights-key" {
  metadata {
    name      = "app-insights-key"
    namespace = kubernetes_namespace.spring-petclinic.metadata.0.name
  }

  data = {
    instrumentation-key = azurerm_application_insights.petclinic.connection_string
  }

}

resource "kubernetes_manifest" "config-map" {
  manifest = yamldecode(file("manifests/services/config-map.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic
  ]
}

resource "kubernetes_manifest" "role" {
  manifest = yamldecode(file("manifests/services/role.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic
  ]
}

resource "kubernetes_manifest" "role-binding" {
  manifest = yamldecode(file("manifests/services/role-binding.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic,
    kubernetes_manifest.role
  ]
}

resource "kubernetes_manifest" "api-gateway-service" {
  manifest = yamldecode(file("manifests/services/api-gateway-service.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic
  ]
}

resource "kubernetes_manifest" "customers-service-service" {
  manifest = yamldecode(file("manifests/services/customers-service-service.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic
  ]
}

resource "kubernetes_manifest" "vets-service-service" {
  manifest = yamldecode(file("manifests/services/vets-service-service.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic
  ]
}

resource "kubernetes_manifest" "visits-service-service" {
  manifest = yamldecode(file("manifests/services/visits-service-service.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic
  ]
}

resource "kubernetes_manifest" "appinsights-blob-pv" {
  manifest = yamldecode(file("manifests/services/appinsights-blob-pv.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic,
    kubernetes_secret.appinsights-blob-secret
  ]
}

resource "kubernetes_manifest" "appinsights-blob-pvc" {
  manifest = yamldecode(file("manifests/services/appinsights-blob-pvc.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic,
    kubernetes_secret.appinsights-blob-secret,
    kubernetes_manifest.appinsights-blob-pv
  ]
}

resource "kubernetes_manifest" "api-gateway-deployment" {
  manifest = yamldecode(file("manifests/deployments/api-gateway-deployment.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic,
    kubernetes_secret.appinsights-blob-secret,
    kubernetes_manifest.appinsights-blob-pvc,
    kubernetes_manifest.config-map,
    kubernetes_manifest.role,
    kubernetes_manifest.role-binding,
    azurerm_storage_blob.appinsights-agent
  ]
}

resource "kubernetes_manifest" "vets-service-deployment" {
  manifest = yamldecode(file("manifests/deployments/vets-service-deployment.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic,
    kubernetes_secret.appinsights-blob-secret,
    kubernetes_manifest.appinsights-blob-pvc,
    kubernetes_manifest.config-map,
    kubernetes_manifest.role,
    kubernetes_manifest.role-binding,
    azurerm_storage_blob.appinsights-agent,
    helm_release.vets-db-mysql
  ]
}

resource "kubernetes_manifest" "visits-service-deployment" {
  manifest = yamldecode(file("manifests/deployments/visits-service-deployment.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic,
    kubernetes_secret.appinsights-blob-secret,
    kubernetes_manifest.appinsights-blob-pvc,
    kubernetes_manifest.config-map,
    kubernetes_manifest.role,
    kubernetes_manifest.role-binding,
    azurerm_storage_blob.appinsights-agent,
    helm_release.visits-db-mysql
  ]
}

resource "kubernetes_manifest" "customers-service-deployment" {
  manifest = yamldecode(file("manifests/deployments/customers-service-deployment.yaml"))
  depends_on = [
    kubernetes_namespace.spring-petclinic,
    kubernetes_secret.appinsights-blob-secret,
    kubernetes_manifest.appinsights-blob-pvc,
    kubernetes_manifest.config-map,
    kubernetes_manifest.role,
    kubernetes_manifest.role-binding,
    azurerm_storage_blob.appinsights-agent,
    helm_release.customers-db-mysql
  ]
}