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

#module "container_repository" {
#  source                 = "./modules/container-repository"
#  project_name           = var.project_name
#  container_repositories = lookup(var.container_repositories, var.env_code)
#  env_code               = var.env_code
#  github_role_name       = "github_actions_${var.organization_name}"
#}

#module "vpc" {
#  source                   = "./modules/vpc"
#  project_name             = var.project_name
#  env_code                 = var.env_code
#  vpc_cidr                 = "10.1.0.0/16"
#  availability_zones_count = 2
#  public_subnet_cidr       = ["10.1.0.0/20", "10.1.16.0/20"]
#  private_subnet_cidr      = ["10.1.32.0/20", "10.1.48.0/20"]
#  public_subnet_tags       = {
#    "kubernetes.io/role/elb"                      = "1"
#    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
#  }
#}

#module "eks" {
#  source = "./modules/eks"
#
#}
