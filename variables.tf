# https://developer.hashicorp.com/terraform/cloud-docs/run/run-environment
# Terraform Cloud automatically injects the environment variables for each run:
# E.g. TFC_CONFIGURATION_VERSION_GIT_BRANCH
# variable "TFC_RUN_ID" {}

variable "organization_name" {
  type    = string
  default = "magicskunk"
}

variable "project_name" {
  type    = string
  default = "seventh"
}

variable "env_code" {
  type        = string
  description = "Environment code. E.g. sandbox, dev, stage, qa, prod"
}

variable "aws_region" {
  type        = map(any)
  description = "Map of {env, aws_region}"
}

variable "container_repository_name" {
  type        = map(any)
  description = "Map of {env, container_repo_name}"
}

