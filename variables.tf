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
  default     = "shared"
}

variable "aws_region" {
  type        = map(string)
  description = "Map of {env, aws_region}"
}

variable "aws_az_count" {
  type    = number
  default = 2
}

variable "container_repositories" {
  type        = map(list(string))
  description = "Map of {env, [container_repo_name]}"
}

variable "primary_domain" {
  type        = string
  description = "Root domain name"
}

variable "email_from_domain" {
  type        = map(string)
  description = "'email from' domain per env"
}

variable "github_oidc_role_name" {
  type    = string
  default = "github_actions_magicskunk"
}

variable "cluster_name" {
  type = map(string)
}

variable "deployment_flag" {
  type = map(list(string))
}
