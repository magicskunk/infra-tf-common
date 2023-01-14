output "container_repositories" {
  description = "Provisioned container repositories"
  value       = module.container_repository.repositories
}

output "github_provider_arn" {
  value = module.container_repository.github_provider
}
