variable "project_name" {
  type = string
}

variable "env_code" {
  type        = string
  description = "Environment code. E.g. sandbox, dev, stage, qa, prod"
}

variable "tags" {
  description = "Map of tags to set."
  type        = map(string)
  default     = {}
}

variable "container_repositories" {
  type        = list(string)
  description = "List of the container repositories to provision"
}
