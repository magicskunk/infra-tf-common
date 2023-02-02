data "aws_eks_cluster" "eks_cluster" {
  count      = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? 1 : 0
  name       = lookup(var.cluster_name, var.env_code)
#  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks_cluster" {
  count      = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? 1 : 0
  name       = lookup(var.cluster_name, var.env_code)
#  depends_on = [module.eks]
}

locals {
  cluster_name           = lookup(var.cluster_name, var.env_code)
  cluster_host           = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? data.aws_eks_cluster.eks_cluster[0].endpoint : ""
  cluster_ca_certificate = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? base64decode(data.aws_eks_cluster.eks_cluster[0].certificate_authority[0].data) : ""
  cluster_token          = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? data.aws_eks_cluster_auth.eks_cluster[0].token : ""
}

provider "aws" {
  region = lookup(var.aws_region, var.env_code)

  default_tags {
    tags = {
      Org         = var.organization_name
      Project     = var.project_name
      Environment = var.env_code
      Terraform   = "true"
      Source      = "infra-tf-common"
    }
  }
}

provider "kubernetes" {
  host                   = local.cluster_host
  cluster_ca_certificate = local.cluster_ca_certificate
  token                  = local.cluster_token
  load_config_file       = false
#  exec {
#    api_version = "client.authentication.k8s.io/v1beta1"
#    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
#    command     = "aws"
#  }
}

provider "kubectl" {
  # this should have same config options as official "kubernetes" provider. But let's try a different way
  host                   = local.cluster_host
  cluster_ca_certificate = local.cluster_ca_certificate
  token                  = local.cluster_token
  load_config_file       = false
}

module "eks" {
  count = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? 1 : 0

  source                   = "./modules/eks"
  env_code                 = var.env_code
  aws_region               = lookup(var.aws_region, var.env_code)
  cluster_name             = lookup(var.cluster_name, var.env_code)
  cluster_subnet_ids       = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  cluster_nodes_subnet_ids = aws_subnet.private[*].id
}

# this and "eks" module cannot be within same repo. TODO Extract to separate repo
module "eks_setup" {
  count = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? 1 : 0

  source     = "./modules/eks-setup"
  depends_on = [module.eks]

  env_code = var.env_code
}
