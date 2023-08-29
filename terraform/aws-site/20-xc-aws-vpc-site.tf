resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "volterra_cloud_credentials" "aws_cred" {
  name = var.environment
  namespace = "system"
  aws_secret_key {
    access_key = var.aws_access_key
    secret_key {
      clear_secret_info {
        url = "string:///${base64encode(var.aws_secret_key)}"
      }
    }
  }
}

resource "volterra_aws_vpc_site" "site" {
  name       = "aws-${var.environment}"
  namespace  = "system"
  aws_region = var.aws_region

  labels = {
    "ves.io/siteName": "hace"
  }

  blocked_services {
    blocked_sevice {
      dns = false
    }
  }

  aws_cred {
    name      = volterra_cloud_credentials.aws_cred.name
    namespace = volterra_cloud_credentials.aws_cred.namespace
  }

  vpc {
    vpc_id = element(aws_vpc.vpc.*.id, 0)
  }

  ssh_key                 = tls_private_key.key.public_key_openssh
  direct_connect_disabled = true
  instance_type           = "t3.xlarge"
  disable_internet_vip    = true
  logs_streaming_disabled = true
  egress_gateway_default  = true

  ingress_gw {
    aws_certified_hw = "aws-byol-voltmesh"
    allowed_vip_port {
      use_http_https_port = true
    }

    az_nodes {
      aws_az_name  = "${var.aws_region}a"
      disk_size    = 80
      local_subnet {
        existing_subnet_id = element(aws_subnet.subnet_a.*.id, 0)
      }
    }

    az_nodes {
      aws_az_name  = "${var.aws_region}b"
      disk_size    = 80
      local_subnet {
        existing_subnet_id = element(aws_subnet.subnet_b.*.id, 0)
      }
    }

    az_nodes {
      aws_az_name  = "${var.aws_region}c"
      disk_size    = 80
      local_subnet {
        existing_subnet_id = element(aws_subnet.subnet_c.*.id, 0)
      }
    }

    performance_enhancement_mode {
      perf_mode_l7_enhanced = true
    }
  }

  no_worker_nodes = true

  depends_on = [
    volterra_cloud_credentials.aws_cred,
    aws_subnet.subnet_a,
    aws_subnet.subnet_b,
    aws_subnet.subnet_c
  ]
}

resource "volterra_cloud_site_labels" "labels" {
  name             = volterra_aws_vpc_site.site.name
  site_type        = "aws_vpc_site"
  labels           = {}
  ignore_on_delete = true
}

resource "volterra_tf_params_action" "action_apply" {
  site_name        = volterra_aws_vpc_site.site.name
  site_kind        = "aws_vpc_site"
  action           = "apply"
  wait_for_action  = true
  ignore_on_update = true

  depends_on = [
    volterra_aws_vpc_site.site,
  ]
}

output "xc_private_key" {
  value     = tls_private_key.key.private_key_pem
  sensitive = true
}

output "xc_public_key" {
  value = tls_private_key.key.public_key_openssh
}