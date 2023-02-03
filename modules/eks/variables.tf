variable "organization_name" {
  type    = string
  default = "magicskunk"
}

variable "env_code" {
  type        = string
  description = "Environment code. E.g. sandbox, dev, stage, qa, prod"
}

variable "aws_region" {
  type = string
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

variable "node_group" {
  type    = map(any)
  default = {
    "shared" = {
      ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
      capacity_type  = "ON_DEMAND"  # ON_DEMAND, SPOT
      instance_types = ["t2.micro"]
      disk_size      = 20
      desired_size   = 3 # need 3 nodes because t2.micro instance type has # of pods per node limited to 4 (cuz of max # of ENIs attached)
      max_size       = 5
      min_size       = 1
    }
    "dev" = {
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"
      instance_types = ["t2.micro"]
      disk_size      = 20
      desired_size   = 2
      max_size       = 5
      min_size       = 1
    }
    "stage" = {
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"
      instance_types = ["t2.micro"]
      disk_size      = 20
      desired_size   = 2
      max_size       = 5
      min_size       = 1
    }
    "prod" = {
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"
      instance_types = ["t2.micro"]
      disk_size      = 20
      desired_size   = 2
      max_size       = 5
      min_size       = 1
    }
  }
}

