resource "helm_release" "vets-db-mysql" {
  name       = "vets-db-mysql"
  namespace  = "spring-petclinic"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"

  set {
    name  = "auth.database"
    value = "service_instance_db"
    type  = "string"
  }
}

resource "helm_release" "visits-db-mysql" {
  name       = "visits-db-mysql"
  namespace  = "spring-petclinic"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"

  set {
    name  = "auth.database"
    value = "service_instance_db"
    type  = "string"
  }
}

resource "helm_release" "customers-db-mysql" {
  name       = "customers-db-mysql"
  namespace  = "spring-petclinic"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"

  set {
    name  = "auth.database"
    value = "service_instance_db"
    type  = "string"
  }
}