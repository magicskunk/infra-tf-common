variable "organization_name" {
  type    = string
  default = "magicskunk"
}

variable "env_code" {
  type        = string
  description = "Environment code. E.g. sandbox, dev, stage, qa, prod"
}

variable "aws_region" {
  type        = string
}

variable "tags" {
  description = "Map of tags to set."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "The name of the EKS Cluster"
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Ids of subnets where cluster will be provisioned"
  type        = list(any)
}

variable "cluster_nodes_subnet_ids" {
  description = "Ids of subnets where cluster nodes will be provisioned"
  type        = list(any)
}

