terraform {

  # "The cloud block only affects Terraform CLI's behavior. When Terraform Cloud uses a configuration
  # that contains a cloud block - for example, when a workspace is configured to use a VCS provider
  # directly - it ignores the block and behaves according to its own workspace settings."
  # Therefore, we plan & apply against sandbox env from the CLI
  cloud {
    organization = "magicskunk"

    workspaces {
      name = "infra-tf-common-shared-cli"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }

  required_version = ">= 1.3.6"
}
