variable "organization_name" {
  type    = string
  default = "magicskunk"
}

variable "env_code" {
  type        = string
  description = "Environment code. E.g. sandbox, dev, stage, qa, prod"
}

variable "k8_admin" {
  type = list(string)
  default = ["dejano"]
}
