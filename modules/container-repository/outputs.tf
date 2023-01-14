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

output "github_role_arn" {
  value = aws_iam_role.github_role.arn
}

output "github_role_assume_role_policy" {
  value = aws_iam_role.github_role.assume_role_policy
}
