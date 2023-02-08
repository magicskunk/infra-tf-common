output "nat_gateway_public_ip" {
  value = aws_nat_gateway.main[*].public_ip
}

output "container_repositories" {
  description = "Urls to provisioned container repositories"
  value       = [for repository in aws_ecr_repository.repository : repository.repository_url]
}

output "cluster_name" {
  value = module.eks[0].cluster_name
}

output "cluster_endpoint" {
  value = module.eks[0].cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks[0].cluster_ca_certificate
}

output "autoscaler" {
  value = {
    role = module.eks[0].autoscaler.role
    oidc = module.eks[0].autoscaler.oidc
  }
}
