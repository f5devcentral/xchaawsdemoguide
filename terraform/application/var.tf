variable "environment" {
  type        = string
  default     = "ha-services-ce"
  description = "Environment Name"
}

variable "xc_api_url" {
  type    = string
  default = "https://your_tenant_name.console.ves.volterra.io/api"
}

variable "xc_api_p12_file" {
  type    = string
  default = "../api-creds.p12"
}

variable "kubeconfig_path" {
  type    = string
  default = "../kubeconfig.conf"
}

variable "helm_path" {
  type    = string
  default = "../../helm"
}

variable "cluster_domain" {
  type    = string
  default = ""
}

variable "registry_username" {
  type    = string
  default = ""
}

variable "registry_password" {
  type    = string
  default = ""
}

variable "registry_email" {
  type    = string
  default = ""
}

variable "virtual_site_name" {
  type    = string
  default = "ha-services-ce-vs"
}

variable "virtual_site_name_vk8s" {
  type    = string
  default = "ha-services-ce-vs-vk8s"
}
