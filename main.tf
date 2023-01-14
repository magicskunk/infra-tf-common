provider "aws" {
  region = lookup(var.aws_region, var.env_code)

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
  container_repository_name = lookup(var.container_repository_name, var.env_code)
}
