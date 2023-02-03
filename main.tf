locals {
  cluster_name           = lookup(var.cluster_name, var.env_code)
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

module "eks" {
  count = contains(lookup(var.deployment_flag, "eks"), var.env_code) ? 1 : 0

  source                   = "./modules/eks"
  env_code                 = var.env_code
  aws_region               = lookup(var.aws_region, var.env_code)
  cluster_name             = lookup(var.cluster_name, var.env_code)
  cluster_subnet_ids       = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  cluster_nodes_subnet_ids = aws_subnet.private[*].id
}
