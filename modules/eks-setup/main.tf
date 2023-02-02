# In every module using the kubectl provider, we need to tell Terraform what is meant by the short kubectl name,
# by defining the provider source
terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "kubectl_manifest" "cluster_rbac" {
  #  yaml_body = templatefile("${path.module}/k8s-manifest/${var.env_code}/aws-eks-rbac.yaml.tftpl", {
  #    "account_id" : data.aws_caller_identity.current.account_id,
  #    "k8s_admin_username" : var.k8_admin
  #  })
  yaml_body = file("${path.module}/k8s-manifest/${var.env_code}/aws-eks-rbac.yaml")
}
