provider "aws" {
  region = lookup(var.env_code, var.aws_region)

  default_tags {
    tags = {
      Org         = var.organization_name
      Project     = var.project_name
      Environment = var.env_code
    }
  }
}

module "container_repository" {
  source                    = "./modules/container-repository"
  organization_name         = var.organization_name
  project_name              = var.project_name
  container_repository_name = lookup(var.env_code, var.container_repository_name)
}
