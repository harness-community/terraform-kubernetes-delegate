variable "cluster_name" {
  type = string
}

variable "delegate_name" {
  type    = string
  default = null
}

variable "manager_endpoint" {
  type    = string
  default = "https://app.harness.io/gratis"
}

variable "delegate_image" {
  type = string
}

variable "upgrader_enabled" {
  type    = bool
  default = true
}

variable "org_id" {
  type    = string
  default = null
}

variable "project_id" {
  type    = string
  default = null
}

variable "oidc_role_arn" {
  type    = string
  default = null
}