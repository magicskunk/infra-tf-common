variable "organization_name" {
  type    = string
  default = "magicskunk"
}

variable "project_name" {
  type = string
}

variable "env_code" {
  type        = string
  description = "Environment code. E.g. sandbox, dev, stage, qa, prod"
}

variable "tags" {
  description = "Map of additional tags to set."
  type        = map(string)
  default     = {}
}

# useful tools ->
# https://cidr.xyz/
# https://www.davidc.net/sites/default/subnets/subnets.html
variable "vpc_cidr" {
  description = "The CIDR block for the VPC. 10.1.0.0/22 value is a valid CIDR, but not acceptable by AWS and different value should be provided"
  type        = string
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
#  default     = ["10.1.32.0/20", "10.1.48.0/20", "10.1.64.0/20", "10.1.80.0/20"]
}

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
}
