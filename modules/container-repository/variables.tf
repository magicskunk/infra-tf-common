variable "organization_name" {
  type    = string
}

variable "project_name" {
  type    = string
}

variable "tags" {
  description = "Map of tags to set."
  type        = map(string)
  default     = {}
}

variable "container_repository_name" {
  type = string
  description = "Name of the container repository"
}
