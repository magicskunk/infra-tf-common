output "repositories" {
  value = [for repository in aws_ecr_repository.repository : repository.repository_url]
}
