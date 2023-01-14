terraform {

#  cloud {
#    organization = "magicskunk"
#
#    workspaces {
#      name = "seventh-dev"
#    }
#  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50.0"
    }
  }

  required_version = ">= 1.3.7"
}
