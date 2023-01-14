output "repositories" {
  value = aws_ecr_repository.repository
}

output "github_provider" {
  value = aws_iam_openid_connect_provider.github
}
