output "container_repository_id" {
  value = aws_ecr_repository.main.id
}

output "container_repository_arn" {
  value = aws_ecr_repository.main.arn
}

output "container_repository_registry_id" {
  value = aws_ecr_repository.main.registry_id
}

output "container_repository_url" {
  value = aws_ecr_repository.main.repository_url
}
