resource "helm_release" "postgres" {
  name       = "ha-postgres"
  chart      = "${var.helm_path}/postgres"

  wait = false

  namespace = "${data.volterra_namespace.hace.name}"

  values = [
    "${file("${var.helm_path}/postgres/values.yaml")}"
  ]

  set =[
    {
      name  = "postgresql-ha.commonAnnotations.ves\\.io\\/virtual-sites"
      value = "${data.volterra_namespace.hace.name}/${var.virtual_site_name}"
    },
    {
      name  = "postgresql-ha.clusterDomain"
      value = "${local.cluster_domain}"
    }
  ]
}