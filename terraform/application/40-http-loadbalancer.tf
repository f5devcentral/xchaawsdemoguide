resource "volterra_http_loadbalancer" "nginx" {
  name      = "${var.environment}-nginx-lb"
  namespace = var.environment

  domains = ["${var.environment}.nginx.domain"]

  http {
    dns_volterra_managed = false
    port                 = "80"
  }

  default_route_pools {
    pool {
      name      = volterra_origin_pool.http_hace.name
      namespace = var.environment
      tenant    = data.volterra_namespace.hace.tenant_name
    }
    priority = 1
    weight   = 1
  }

  default_sensitive_data_policy    = true
  disable_api_testing              = true
  disable_malware_protection       = true
  disable_threat_mesh              = true
  advertise_on_public_default_vip  = true
  disable_api_definition           = true
  disable_api_discovery            = true
  no_challenge                     = true
  source_ip_stickiness             = true
  disable_malicious_user_detection = true
  disable_rate_limit               = true
  service_policies_from_namespace  = true
  disable_trust_client_ip_headers  = true
  user_id_client_ip                = true
  disable_waf                      = true

  l7_ddos_protection {
    ddos_policy_none = true
    mitigation_block = true
  }
}

resource "volterra_origin_pool" "http_hace" {
  name      = "${var.environment}-nginx-rp-op"
  namespace = var.environment

  origin_servers {
    k8s_service {
      service_name = "nginx-rp.${var.environment}"
      site_locator {
        virtual_site {
          name      = var.virtual_site_name_vk8s
          namespace = data.volterra_namespace.hace.name
          tenant    = data.volterra_namespace.hace.tenant_name
        }
      }
      vk8s_networks = true
    }
  }

  healthcheck {
    name      = volterra_healthcheck.nginx.name
    namespace = data.volterra_namespace.hace.name
    tenant    = data.volterra_namespace.hace.tenant_name
  }

  no_tls                 = true
  port                   = 9080
  endpoint_selection     = "LOCAL_PREFERRED"
  loadbalancer_algorithm = "LB_OVERRIDE"
}

resource "volterra_healthcheck" "nginx" {
  name      = "${var.environment}-nginx-hc"
  namespace = var.environment

  http_health_check {
    path = "/probe"
  }

  unhealthy_threshold = 5
  healthy_threshold   = 2
  interval            = 30
  timeout             = 5
}