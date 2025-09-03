resource "volterra_namespace" "hace" {
  name = var.environment
}

resource "volterra_virtual_k8s" "hace" {
  name      = "${var.environment}-vk8s"
  namespace = volterra_namespace.hace.name
  vsite_refs {
    name      = volterra_virtual_site.hace.name
    namespace = volterra_namespace.hace.name
    tenant    = volterra_namespace.hace.tenant_name
  }  

  vsite_refs {
    name      = volterra_virtual_site.hace_vk8s.name
    namespace = volterra_namespace.hace.name
    tenant    = volterra_namespace.hace.tenant_name
  }

  depends_on = [
    volterra_namespace.hace
  ]
}

resource "volterra_api_credential" "hace" {
  created_at            = timestamp()
  name                  = "${var.environment}-kubeconfig"
  api_credential_type   = "KUBE_CONFIG"
  virtual_k8s_namespace = volterra_namespace.hace.name
  virtual_k8s_name      = volterra_virtual_k8s.hace.name

  lifecycle {
    ignore_changes = [ 
      created_at 
    ]
  }
}

resource "volterra_virtual_site" "hace" {
  name      = "${var.environment}-vs"
  namespace = volterra_namespace.hace.name

  site_selector {
    expressions = ["ves.io/siteName in (hace)"]
  }

  site_type = "CUSTOMER_EDGE"

  depends_on = [ 
    volterra_namespace.hace
   ]
}

resource "volterra_virtual_site" "hace_vk8s" {
  name      = "${var.environment}-vs-vk8s"
  namespace = volterra_namespace.hace.name

  site_selector {
    expressions = ["ves.io/region in (ves-io-dallas, ves-io-frankfurt, ves-io-newyork)"]
  }

  site_type = "REGIONAL_EDGE"

  depends_on = [ 
    volterra_namespace.hace
   ]
}

resource "local_file" "kubeconfig" {
  content_base64 = volterra_api_credential.hace.data
  filename        = "${var.kubeconfig_path}"
}

output "kubecofnig_path" {
 value       = "${var.kubeconfig_path}"
 sensitive   = false
 description = "Kubeconfig path"
 depends_on = [ local_file.kubeconfig ]
}

output "tenant_name" {
 value       = volterra_namespace.hace.tenant_name
 sensitive   = false
 description = "XC Tenant name"
}

output "cluster_domain" {
  description = "Cluster Domain"
  value       = "aws-${var.environment}.${volterra_namespace.hace.tenant_name}.tenant.local"
}
