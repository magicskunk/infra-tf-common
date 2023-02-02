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
