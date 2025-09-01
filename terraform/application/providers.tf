terraform {
  required_version = ">= 1.4.0"

  required_providers {
    volterra = {
        source  = "volterraedge/volterra"
        version = "=0.11.44"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=3.0.2"
    }
  }
}

provider "volterra" {
  api_p12_file = var.xc_api_p12_file
  url          = var.xc_api_url
}

provider "kubernetes" {
  config_path = "${var.kubeconfig_path}"
}

provider "helm" {
  kubernetes = {
    config_path = "${var.kubeconfig_path}"
  }
}