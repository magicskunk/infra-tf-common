output "nat_gateway_public_ip" {
  value = aws_nat_gateway.main[*].public_ip
}

output "container_repositories" {
  description = "Urls to provisioned container repositories"
  value = [for repository in aws_ecr_repository.repository : repository.repository_url]
}
