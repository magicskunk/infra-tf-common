output "container_repositories" {
  description = "Urls to provisioned container repositories"
  value       = module.container_repository.repositories
}
