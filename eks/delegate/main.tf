data "harness_platform_current_account" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "harness_platform_delegatetoken" "this" {
  name       = var.delegate_name ? var.delegate_name : var.cluster_name
  account_id = data.harness_platform_current_account.current.id
  org_id     = var.org_id
  project_id = var.project_id
}

module "delegate" {
  source  = "harness/harness-delegate/kubernetes"
  version = "0.1.8"

  account_id       = data.harness_platform_current_account.current.id
  delegate_token   = harness_platform_delegatetoken.this.value
  delegate_name    = var.delegate_name ? var.delegate_name : var.cluster_name
  deploy_mode      = "KUBERNETES"
  namespace        = "harness-delegate-ng"
  manager_endpoint = var.manager_endpoint
  delegate_image   = var.delegate_image
  upgrader_enabled = var.upgrader_enabled
}

resource "harness_platform_connector_kubernetes" "this" {
  identifier = replace(var.cluster_name, "-", "_")
  name       = var.cluster_name
  org_id     = var.org_id
  project_id = var.project_id

  inherit_from_delegate {
    delegate_selectors = [
      module.delegate.values.delegate_name
    ]
  }
}

resource "harness_platform_connector_aws" "aws" {
  count      = var.oidc_role_arn ? 1 : 0
  identifier = replace(var.cluster_name, "-", "_")
  name       = var.cluster_name
  org_id     = var.org_id
  project_id = var.project_id

  oidc_authentication {
    iam_role_arn = var.oidc_role_arn
    delegate_selectors = [
      module.delegate.values.delegate_name
    ]
    region = data.aws_region.current.name
  }
}