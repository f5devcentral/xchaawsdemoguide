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

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "aws_access_key" {
  type    = string
  default = ""
}

variable "aws_secret_key" {
  type    = string
  default = ""
}