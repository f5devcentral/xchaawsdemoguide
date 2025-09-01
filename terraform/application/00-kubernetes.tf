resource "kubernetes_secret" "secret" {
  metadata {
    name = "registry-secret"
    namespace = var.environment
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "docker.io" = {
          "username" = var.registry_username
          "password" = var.registry_password
          "email"    = var.registry_email
          "auth"     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
}

data "volterra_namespace" "hace" {
  name = var.environment
}

locals {
  cluster_domain = var.cluster_domain != "" ? var.cluster_domain : "aws-${var.environment}.${data.volterra_namespace.hace.tenant_name}.tenant.local"
}