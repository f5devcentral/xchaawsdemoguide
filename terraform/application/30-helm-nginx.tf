resource "helm_release" "nginx" {
  name      = "ha-nginx-reverse-proxy"
  chart     = "${var.helm_path}/nginx"
  wait      = false
  namespace = "${data.volterra_namespace.hace.name}"

  values = [
    "${file("${var.helm_path}/nginx/values.yaml")}"
  ]

  set =[
    {
      name  = "nginx.podAnnotations.ves\\.io\\/virtual-sites"
      value = "${data.volterra_namespace.hace.name}/${var.virtual_site_name_vk8s}"
    }
  ]
}