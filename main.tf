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
  source                 = "./modules/container-repository"
  project_name           = var.project_name
  container_repositories = lookup(var.container_repositories, var.env_code)
  env_code               = var.env_code
}
